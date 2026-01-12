module "bedrock_agent" {
  source  = "aws-ia/bedrock/aws"
  version = "~> 0.0.33"

  # Agent configuration
  create_agent      = true
  agent_name        = var.agent_name
  agent_description = "Summarizes input text using Amazon Nova"
  foundation_model  = var.foundation_model
  idle_session_ttl  = var.idle_session_ttl
  instruction       = local.agent_instruction

  # Disable knowledge base (not needed for basic summarization)
  create_default_kb = false

  # Tags
  tags = local.common_tags
}
