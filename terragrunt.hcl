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
    bucket         = "terraform-bedrock-state-useast2-${get_aws_account_id()}"
    key            = "terraform-bedrock/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    use_lockfile   = true
    dynamodb_table = "terraform-bedrock-locks-useast2"
    max_retries    = 5
  }
}

inputs = {
  aws_region = "us-east-2"
}

generate "provider" {
  path      = "provider_override.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "us-east-2"

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
