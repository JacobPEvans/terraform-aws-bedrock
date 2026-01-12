# Lambda Function URL for public Bedrock agent access
# Includes rate limiting and input protection

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------
variable "enable_lambda_url" {
  description = "Enable public Lambda Function URL for agent access"
  type        = bool
  default     = true
}

variable "lambda_max_concurrency" {
  description = "Max concurrent Lambda executions (rate limiting)"
  type        = number
  default     = 5
}

variable "lambda_max_input_chars" {
  description = "Max input characters to protect against token abuse"
  type        = number
  default     = 20000
}

# -----------------------------------------------------------------------------
# Lambda IAM Role
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_policy" {
  # CloudWatch Logs
  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/lambda/bedrock-agent-${var.agent_name}:*"]
  }

  # Bedrock Agent Invocation
  statement {
    sid    = "BedrockAgentInvoke"
    effect = "Allow"
    actions = [
      "bedrock:InvokeAgent"
    ]
    resources = [
      "arn:aws:bedrock:${local.region}:${local.account_id}:agent-alias/*/TSTALIASID"
    ]
  }
}

resource "aws_iam_role" "lambda" {
  count = var.enable_lambda_url ? 1 : 0

  name               = "bedrock-agent-lambda-${var.agent_name}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json

  tags = local.common_tags
}

resource "aws_iam_role_policy" "lambda" {
  count = var.enable_lambda_url ? 1 : 0

  name   = "bedrock-agent-invoke"
  role   = aws_iam_role.lambda[0].id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

# -----------------------------------------------------------------------------
# Lambda Function
# -----------------------------------------------------------------------------
data "archive_file" "lambda" {
  count = var.enable_lambda_url ? 1 : 0

  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/.terraform/lambda.zip"
}

resource "aws_lambda_function" "agent_proxy" {
  count = var.enable_lambda_url ? 1 : 0

  function_name = "bedrock-agent-${var.agent_name}"
  description   = "Public proxy for Bedrock agent invocation"

  filename         = data.archive_file.lambda[0].output_path
  source_code_hash = data.archive_file.lambda[0].output_base64sha256
  handler          = "index.lambda_handler"
  runtime          = "python3.12"
  timeout          = 30
  memory_size      = 256

  # Rate limiting via reserved concurrency
  reserved_concurrent_executions = var.lambda_max_concurrency

  role = aws_iam_role.lambda[0].arn

  environment {
    variables = {
      AGENT_ID         = module.bedrock_agent.bedrock_agent[0].agent_id
      AGENT_ALIAS_ID   = "TSTALIASID"
      MAX_INPUT_CHARS  = tostring(var.lambda_max_input_chars)
    }
  }

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Lambda Function URL (Public Access)
# -----------------------------------------------------------------------------
resource "aws_lambda_function_url" "agent" {
  count = var.enable_lambda_url ? 1 : 0

  function_name      = aws_lambda_function.agent_proxy[0].function_name
  authorization_type = "NONE"

  cors {
    allow_origins = ["*"]
    allow_methods = ["POST"]
    allow_headers = ["Content-Type"]
    max_age       = 86400
  }
}

# Allow public access to Function URL (requires both permissions)
resource "aws_lambda_permission" "function_url_invoke" {
  count = var.enable_lambda_url ? 1 : 0

  statement_id           = "FunctionURLAllowPublicAccess"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.agent_proxy[0].function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------
output "lambda_function_url" {
  description = "Public URL to invoke the Bedrock agent"
  value       = var.enable_lambda_url ? aws_lambda_function_url.agent[0].function_url : null
}

output "curl_example" {
  description = "Example curl command to invoke the agent"
  value = var.enable_lambda_url ? join("", [
    "curl -X POST ",
    aws_lambda_function_url.agent[0].function_url,
    " -H 'Content-Type: application/json'",
    " -d '{\"text\": \"Summarize: Your text here...\"}'"
  ]) : null
}
