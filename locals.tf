locals {
  common_tags = {
    Project     = "terraform-bedrock"
    ManagedBy   = "terraform"
    Environment = "production"
  }

  agent_instruction = file("${path.module}/INSTRUCTION.md")
}
