"""
Lambda function to invoke Bedrock agent via public Function URL.

Includes:
- Input token limiting (max 1000 chars ~250 tokens)
- Basic rate limiting via reserved concurrency
- Request validation
"""

import json
import os
import boto3

# Configuration from environment
AGENT_ID = os.environ.get("AGENT_ID")
AGENT_ALIAS_ID = os.environ.get("AGENT_ALIAS_ID", "TSTALIASID")
MAX_INPUT_CHARS = int(os.environ.get("MAX_INPUT_CHARS", "1000"))
REGION = os.environ.get("AWS_REGION", "us-east-2")

client = boto3.client("bedrock-agent-runtime", region_name=REGION)


def lambda_handler(event, context):
    """Handle incoming requests to invoke Bedrock agent."""
    # Parse request body
    try:
        if isinstance(event.get("body"), str):
            body = json.loads(event["body"])
        else:
            body = event.get("body") or event
    except json.JSONDecodeError:
        return response(400, {"error": "Invalid JSON body"})

    # Extract and validate input text
    input_text = body.get("text", "").strip()

    if not input_text:
        return response(400, {
            "error": "Missing 'text' field",
            "usage": {"text": "Your text to summarize here..."}
        })

    # Token protection: limit input length
    if len(input_text) > MAX_INPUT_CHARS:
        return response(400, {
            "error": f"Input too long. Max {MAX_INPUT_CHARS} characters.",
            "received": len(input_text)
        })

    # Invoke Bedrock agent
    try:
        agent_response = client.invoke_agent(
            agentId=AGENT_ID,
            agentAliasId=AGENT_ALIAS_ID,
            sessionId=context.aws_request_id,
            inputText=input_text
        )

        # Collect streaming response
        full_response = ""
        for event_chunk in agent_response.get("completion", []):
            if "chunk" in event_chunk:
                chunk_bytes = event_chunk["chunk"].get("bytes", b"")
                full_response += chunk_bytes.decode("utf-8")

        return response(200, {
            "response": full_response,
            "agent": "Jacob's Assistant",
            "input_length": len(input_text)
        })

    except client.exceptions.ValidationException as e:
        return response(400, {"error": "Validation error", "details": str(e)})
    except client.exceptions.AccessDeniedException as e:
        return response(403, {"error": "Access denied", "details": str(e)})
    except Exception as e:
        return response(500, {"error": "Internal error", "details": str(e)})


def response(status_code, body):
    """Format Lambda response for Function URL."""
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "X-Powered-By": "Jacob's Assistant"
        },
        "body": json.dumps(body)
    }
