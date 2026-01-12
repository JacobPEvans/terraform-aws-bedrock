# Terraform AWS Bedrock - Agent Instructions

Technical reference for AI assistants working on this repository.

## Prerequisites

- AWS credentials via `aws-vault` profile `terraform-bedrock`
- Nix with flakes enabled (for development shell)

**Important**: Use `--no-session` flag with aws-vault for IAM operations.

## Secrets

Configuration secrets are stored in macOS Keychain under the `aws-vault`
keychain:

| Account          | Service                    | Description              |
|------------------|----------------------------|--------------------------|
| `AWS_ACCOUNT_ID` | `terraform-bedrock-config` | AWS account ID           |
| `AWS_REGION`     | `terraform-bedrock-config` | AWS region               |

Retrieve secrets:

```bash
security find-generic-password -a "AWS_ACCOUNT_ID" \
  -s "terraform-bedrock-config" -w ~/Library/Keychains/aws-vault.keychain-db
```

Add/update secrets:

```bash
security add-generic-password -a "AWS_ACCOUNT_ID" \
  -s "terraform-bedrock-config" -w "<YOUR_ACCOUNT_ID>" -U \
  ~/Library/Keychains/aws-vault.keychain-db
```

## Development

Enter the development shell:

```bash
nix develop
```

## Terraform Commands

Run from `main/` directory:

```bash
# Plan
aws-vault exec terraform-bedrock --no-session -- terragrunt plan

# Apply
aws-vault exec terraform-bedrock --no-session -- terragrunt apply

# Destroy
aws-vault exec terraform-bedrock --no-session -- terragrunt destroy
```

## Architecture

- **State**: S3 bucket with DynamoDB locking
- **Agent**: Amazon Nova Micro via inference profile
- **IAM**: Least-privilege execution role with confused deputy protection

## Worktree Structure

This repo uses bare git with worktrees:

```text
~/git/terraform-aws-bedrock/
├── .git/     # Bare repo
└── main/     # Main branch worktree
```

Create feature branches:

```bash
cd ~/git/terraform-aws-bedrock
git worktree add <branch-name> -b <branch-name> main
```
