output "agent" {
  description = "The Bedrock agent object"
  value       = module.bedrock_agent.bedrock_agent
}

output "agent_resource_role_arn" {
  description = "The ARN of the agent execution IAM role"
  value       = module.bedrock_agent.agent_resource_role_arn
}

output "agent_resource_role_name" {
  description = "The name of the agent execution IAM role"
  value       = module.bedrock_agent.agent_resource_role_name
}
