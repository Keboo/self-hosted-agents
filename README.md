# self-hosted-agents

Infrastructure and tooling for deploying self-hosted GitHub Actions runners on Azure Container Apps.

## Overview

This repository provides:
- Terraform infrastructure for Azure Container Apps environment
- Docker image for GitHub Actions self-hosted runners
- CI/CD pipeline for building and publishing runner images

## Components

### Terraform Infrastructure (`github/` folder)

Creates the following Azure resources:
- **Resource Group** - Container for all resources
- **Container App Environment** - Runtime environment for containers
- **Azure Container Registry (ACR)** - Stores runner images (Basic SKU with ARM audience tokens)
- **User Assigned Managed Identity** - For secure access to ACR
- **Log Analytics Workspace** - For monitoring and logging

### GitHub Actions Runner Image

- Based on Ubuntu 22.04 (matching GitHub's runner images)
- Includes Docker CLI and Azure CLI
- Configurable runner labels and settings
- Automatic registration and cleanup

## Quick Start

### 1. Deploy Infrastructure

```bash
cd github/
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your specific values
terraform init
terraform plan
terraform apply
```

### 2. Build Runner Image

The GitHub Actions workflow automatically builds and publishes the runner image to GitHub Container Registry when changes are pushed to the repository.

## Configuration

### Terraform Variables

All variables have sensible defaults but can be customized:

| Variable | Description | Default |
|----------|-------------|---------|
| `location` | Azure region | `East US` |
| `resource_group_name` | Resource group name | `rg-github-runners` |
| `container_app_environment_name` | Container App Environment name | `cae-github-runners` |
| `container_registry_name` | ACR name (globally unique) | `acrgithubrunners` |
| `user_assigned_identity_name` | Managed Identity name | `mi-github-runners` |

### Runner Environment Variables

The runner container accepts these environment variables:

| Variable | Description | Required |
|----------|-------------|----------|
| `GITHUB_REPOSITORY_URL` | GitHub repository URL | Yes |
| `RUNNER_TOKEN` | GitHub runner registration token | Yes |
| `RUNNER_NAME` | Custom runner name | No (defaults to hostname) |
| `RUNNER_LABELS` | Comma-separated labels | No (defaults to `azure,container-app`) |

## References

- [Azure Container Apps CI/CD Tutorial](https://learn.microsoft.com/en-us/azure/container-apps/tutorial-ci-cd-runners-jobs?tabs=bash&pivots=container-apps-jobs-self-hosted-ci-cd-github-actions)
- [GitHub Runner Images](https://github.com/actions/runner-images)
