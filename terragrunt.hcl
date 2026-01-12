# Terragrunt configuration for AWS Bedrock Agent
# Region is defined once here and flows through to all resources

locals {
  aws_region        = "us-east-2"
  aws_region_compact = replace(local.aws_region, "-", "")
}

terraform {
  source = "."
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "terraform-bedrock-state-${local.aws_region_compact}-${get_aws_account_id()}"
    key            = "terraform-bedrock/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    use_lockfile   = true
    dynamodb_table = "terraform-bedrock-locks-${local.aws_region_compact}"
    max_retries    = 5
  }
}

inputs = {
  aws_region = local.aws_region
}

generate "provider" {
  path      = "provider_override.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"

  default_tags {
    tags = {
      Project     = "terraform-bedrock"
      ManagedBy   = "terraform"
      Environment = "production"
    }
  }
}
EOF
}
