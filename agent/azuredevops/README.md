# Azure DevOps Agent

This directory contains the Docker image for Azure DevOps self-hosted agents.

## Files

- `Dockerfile` - Basic image structure (for environments with network restrictions)
- `Dockerfile.working` - Full working image (generated by build-working.sh)
- `build-working.sh` - Script to create a working Dockerfile with agent download
- `entrypoint.sh` - Agent startup script
- `.env.example` - Environment variables template

## Building

### Basic Image (Development/Demo)

```bash
docker build . -t azuredevops-agent
```

### Working Image (Production)

```bash
./build-working.sh
docker build -f Dockerfile.working . -t azuredevops-agent
```

## Running

First, copy the example environment file and configure it:

```bash
cp .env.example .env
# Edit .env with your Azure DevOps organization details
```

Then run the agent:

```bash
docker run --env-file .env azuredevops-agent
```

## Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `AZP_URL` | Azure DevOps organization URL (e.g., https://dev.azure.com/myorg) | Yes | - |
| `AZP_TOKEN` | Personal Access Token with Agent Pool (read, manage) permissions | Yes | - |
| `AZP_AGENT_NAME` | Custom agent name | No | hostname |
| `AZP_POOL` | Agent pool name | No | Default |
| `AZP_WORK` | Work directory for builds | No | _work |

## Creating a Personal Access Token

1. Go to your Azure DevOps organization
2. Click on your profile picture → Personal access tokens
3. Create a new token with the following permissions:
   - Agent Pools: Read & manage
   - Deployment Groups: Read & manage (if using deployment groups)
4. Copy the token and use it as `AZP_TOKEN`

## Agent Pool Setup

Make sure the agent pool exists in your Azure DevOps organization:
1. Go to Project Settings → Agent pools
2. Create a new pool or use the Default pool
3. Ensure you have permissions to add agents to the pool

## Agent Registration

The agent will automatically:
1. Register itself with the specified Azure DevOps organization
2. Join the specified agent pool
3. Start listening for build jobs
4. Clean up and unregister when the container stops

## Included Tools

- Git
- Azure CLI
- Docker CLI (in working image)
- Common build tools (curl, wget, unzip, jq, etc.)
- sudo access for the azureuser