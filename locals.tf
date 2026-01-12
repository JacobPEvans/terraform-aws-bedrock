locals {
  common_tags = {
    Project     = "terraform-bedrock"
    ManagedBy   = "terraform"
    Environment = "production"
  }

  agent_instruction = <<-EOT
    You are a text summarization assistant. When given text,
    produce a concise summary that captures the key points.
    Keep summaries under 100 words unless the input is very long.
  EOT
}
