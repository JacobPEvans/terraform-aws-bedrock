# Terraform AWS Bedrock Agent

Deploy an AWS Bedrock agent for text summarization (or whatever) with a public
API endpoint. This project sets up an AI-powered assistant that responds to
simple web requests—no AWS credentials or complex setup required to use it.
Just send text, get an AI response back.

## Try It

Once deployed, invoke the agent with a simple curl:

```bash
curl -X POST "https://<function-id>.lambda-url.<region>.on.aws/" \
  -H "Content-Type: application/json" \
  -d '{"text": "Your text to summarize..."}'
```

![Example chat with the Bedrock agent](.github/sample-bedrock-chat.jpg)

## Features

- **Public API** — No auth required, just curl
- **Rate Limited** — 5 concurrent requests max
- **Input Protection** — 20,000 character limit
- **Personality** — Responses include wit and puns

## Deploy Your Own

### Prerequisites

- AWS account with Bedrock access
- [aws-vault](https://github.com/99designs/aws-vault) configured
- [Nix](https://nixos.org/) with flakes (or OpenTofu/Terragrunt installed)

### Setup

```bash
# Configure credentials
aws-vault add terraform-bedrock

# Enter dev shell
nix develop

# Deploy
aws-vault exec terraform-bedrock --no-session -- terragrunt apply
```

### Direct SDK Access

```python
import boto3

client = boto3.client("bedrock-agent-runtime", region_name="<region>")

response = client.invoke_agent(
    agentId="<AGENT_ID>",
    agentAliasId="TSTALIASID",
    sessionId="test",
    inputText="Summarize: Your text here"
)

for event in response["completion"]:
    if "chunk" in event:
        print(event["chunk"]["bytes"].decode())
```

## Configuration

| Variable           | Default                     | Description          |
|--------------------|-----------------------------|----------------------|
| `aws_region`       | `us-east-2`                 | AWS region           |
| `agent_name`       | `text-summarizer`           | Bedrock agent name   |
| `foundation_model` | `us.amazon.nova-micro-v1:0` | Model inference ID   |
| `idle_session_ttl` | `600`                       | Session timeout (s)  |
