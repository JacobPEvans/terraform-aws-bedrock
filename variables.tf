variable "aws_region" {
  description = "AWS region for Bedrock resources"
  type        = string
  default     = "us-east-2"
}

variable "agent_name" {
  description = "Name for the Bedrock agent"
  type        = string
  default     = "text-summarizer"
}

variable "foundation_model" {
  description = "Bedrock foundation model or inference profile ID"
  type        = string
  default     = "us.amazon.nova-micro-v1:0"
}

variable "idle_session_ttl" {
  description = "Idle session timeout in seconds"
  type        = number
  default     = 600
}
