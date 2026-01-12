# Terraform AWS Bedrock Agent

Deploy an AWS Bedrock agent for text summarization using Terraform and
Terragrunt.

## Overview

This project provisions a production-ready Amazon Bedrock agent that
summarizes text using the Amazon Nova Micro model. Infrastructure is managed
with Terragrunt for remote state handling and consistent configuration.

### Features

- **Text Summarization Agent** - Concise summaries of input text
- **Amazon Nova Micro** - Cost-effective model via inference profile
- **Remote State** - S3 backend with DynamoDB locking
- **Least-Privilege IAM** - Confused deputy protection on execution role
- **GitHub Actions CI/CD** - Plan on PR, manual apply workflow

## Quick Start

### Prerequisites

- AWS account with Bedrock access enabled
- [aws-vault](https://github.com/99designs/aws-vault) configured
- [Nix](https://nixos.org/) with flakes (or install Terraform manually)

### Setup

1. **Configure AWS credentials**

   ```bash
   aws-vault add terraform-bedrock
   ```

2. **Enter development shell**

   ```bash
   nix develop
   ```

3. **Deploy infrastructure**

   ```bash
   aws-vault exec terraform-bedrock --no-session -- terragrunt apply
   ```

### Invoke the Agent

```python
import boto3

client = boto3.client("bedrock-agent-runtime", region_name="us-east-2")

response = client.invoke_agent(
    agentId="<AGENT_ID>",
    agentAliasId="TSTALIASID",
    sessionId="my-session",
    inputText="Summarize: Your text here..."
)

for event in response["completion"]:
    if "chunk" in event:
        print(event["chunk"]["bytes"].decode())
```

## Project Structure

```text
main/
├── main.tf           # Bedrock agent module configuration
├── variables.tf      # Input variables (region, model, TTL)
├── outputs.tf        # Agent ARN and role outputs
├── locals.tf         # Tags and agent instructions
├── versions.tf       # Provider version constraints
├── iam_policies.tf   # IAM policy documents (reference only)
├── terragrunt.hcl    # Remote state and provider configuration
└── .github/
    └── workflows/
        └── terraform.yml  # CI/CD pipeline
```

## Configuration

| Variable           | Default                     | Description            |
|--------------------|-----------------------------|------------------------|
| `aws_region`       | `us-east-2`                 | AWS region             |
| `agent_name`       | `text-summarizer`           | Bedrock agent name     |
| `foundation_model` | `us.amazon.nova-micro-v1:0` | Model inference ID     |
| `idle_session_ttl` | `600`                       | Session timeout (sec)  |

## IAM Requirements

The Terraform runner requires permissions documented in `iam_policies.tf`:

- Bedrock agent management
- IAM role creation for agent execution
- S3/DynamoDB for state management
- CloudFormation for AWSCC provider

## License

MIT
