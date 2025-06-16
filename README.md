# self-hosted-agents

Infrastructure and tooling for deploying self-hosted GitHub Actions runners and Azure DevOps agents on Azure Container Apps.

## Overview

This repository provides:
- Terraform infrastructure for Azure Container Apps environment
- Docker image for GitHub Actions self-hosted runners
- Docker image for Azure DevOps self-hosted agents
- CI/CD pipeline for building and publishing runner images
- **Automated Terraform deployment pipeline**

## Components

### Terraform Infrastructure (`infra/` folder)

Creates the following Azure resources:
- **Resource Group** - Container for all resources
- **Container App Environment** - Runtime environment for containers
- **Azure Container Registry (ACR)** - Stores runner images (Basic SKU with ARM audience tokens)
- **User Assigned Managed Identity** - For secure access to ACR
- **Log Analytics Workspace** - For monitoring and logging

### GitHub Actions Runner Image (`agent/github/`)

- Based on Ubuntu 22.04 (matching GitHub's runner images)
- Includes Docker CLI and Azure CLI
- Configurable runner labels and settings
- Automatic registration and cleanup

### Azure DevOps Agent Image (`agent/azuredevops/`)

- Based on Ubuntu 22.04 (matching Azure DevOps hosted agent images)
- Includes Azure CLI and common build tools
- Configurable agent pool and settings
- Automatic registration and cleanup
- Follows Microsoft's recommended configuration

### CI/CD Pipelines

1. **Runner Image Pipeline** (`build-runner-image.yml`) - Automatically builds and publishes runner images
2. **Terraform Deployment Pipeline** (`terraform-deploy.yml`) - Automatically deploys infrastructure changes

## Quick Start

### 1. Setup Azure Authentication for CI/CD

Before using the automated Terraform pipeline, you need to configure Azure authentication:

#### Option A: Using Azure OIDC (Recommended)

1. Create an Azure AD App Registration with federated credentials for GitHub
2. Grant it permissions to create resources in your subscription
3. Add these secrets to your GitHub repository:
   - `AZURE_CLIENT_ID`
   - `AZURE_TENANT_ID` 
   - `AZURE_SUBSCRIPTION_ID`

#### Option B: Using Service Principal

1. Create a service principal: `az ad sp create-for-rbac --name "github-actions-terraform"`
2. Add these secrets to your GitHub repository:
   - `AZURE_CLIENT_ID`
   - `AZURE_CLIENT_SECRET`
   - `AZURE_TENANT_ID`
   - `AZURE_SUBSCRIPTION_ID`

### 2. Configure Terraform Backend (Optional but Recommended)

For production use, configure remote state storage:

1. Create a storage account for Terraform state
2. Uncomment the backend configuration in `github/versions.tf`
3. Set backend configuration via environment variables in the workflow

### 3. Deploy Infrastructure

#### Automated (Recommended)
- Push changes to `github/` folder - automatically triggers `terraform plan`
- Merge to main branch - automatically runs `terraform apply`
- Manual deployment via GitHub Actions "Run workflow" button

#### Manual
```bash
cd github/
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your specific values
terraform init
terraform plan
terraform apply
```

### 4. Build Runner Image

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

## Terraform Pipeline Features

- **Automatic Planning**: Runs `terraform plan` on PRs to preview changes
- **Automatic Deployment**: Applies changes when merged to main branch
- **Manual Control**: Run workflow manually with plan/apply/destroy options
- **PR Comments**: Shows Terraform plan output directly in pull request comments
- **State Management**: Supports remote state storage for team collaboration
- **Security**: Uses OIDC authentication (no stored credentials)

## References

- [Azure Container Apps CI/CD Tutorial](https://learn.microsoft.com/en-us/azure/container-apps/tutorial-ci-cd-runners-jobs?tabs=bash&pivots=container-apps-jobs-self-hosted-ci-cd-github-actions)
- [GitHub Runner Images](https://github.com/actions/runner-images)
- [Azure OIDC for GitHub Actions](https://docs.microsoft.com/en-us/azure/active-directory/develop/workload-identity-federation-create-trust)
