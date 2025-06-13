# Terraform Deployment Pipeline Setup

This guide explains how to set up the automated Terraform deployment pipeline for GitHub Actions self-hosted runners.

## Prerequisites

- Azure subscription with appropriate permissions
- GitHub repository with Actions enabled
- Azure CLI installed (for manual setup steps)

## Azure Authentication Setup

### Option 1: Azure OIDC (Recommended)

OIDC authentication provides better security by eliminating the need to store long-lived credentials.

#### 1. Create Azure AD App Registration

```bash
# Create app registration
az ad app create --display-name "github-actions-terraform-runners"

# Get the application ID
APP_ID=$(az ad app list --display-name "github-actions-terraform-runners" --query "[0].appId" -o tsv)
echo "Application ID: $APP_ID"
```

#### 2. Create Service Principal

```bash
# Create service principal
az ad sp create --id $APP_ID

# Get the object ID of the service principal
SP_OBJECT_ID=$(az ad sp show --id $APP_ID --query "id" -o tsv)
echo "Service Principal Object ID: $SP_OBJECT_ID"
```

#### 3. Create Federated Credentials

```bash
# For main branch deployments
az ad app federated-credential create --id $APP_ID --parameters '{
    "name": "github-actions-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:YOUR_GITHUB_USERNAME/self-hosted-agents:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
}'

# For pull request validations  
az ad app federated-credential create --id $APP_ID --parameters '{
    "name": "github-actions-pr",
    "issuer": "https://token.actions.githubusercontent.com", 
    "subject": "repo:YOUR_GITHUB_USERNAME/self-hosted-agents:pull_request",
    "audiences": ["api://AzureADTokenExchange"]
}'
```

#### 4. Assign Azure Permissions

```bash
# Get your subscription ID
SUBSCRIPTION_ID=$(az account show --query "id" -o tsv)

# Assign Contributor role to the service principal
az role assignment create \
    --assignee $SP_OBJECT_ID \
    --role "Contributor" \
    --scope "/subscriptions/$SUBSCRIPTION_ID"
```

#### 5. Add GitHub Secrets

Add these secrets to your GitHub repository (Settings > Secrets and variables > Actions):

- `AZURE_CLIENT_ID`: The Application ID from step 1
- `AZURE_TENANT_ID`: Your Azure tenant ID (`az account show --query "tenantId" -o tsv`)
- `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID

### Option 2: Service Principal with Secret

If OIDC is not available, you can use a service principal with a client secret.

#### 1. Create Service Principal

```bash
az ad sp create-for-rbac \
    --name "github-actions-terraform-runners" \
    --role "Contributor" \
    --scopes "/subscriptions/$(az account show --query id -o tsv)" \
    --json-auth
```

#### 2. Add GitHub Secrets

Add these secrets to your GitHub repository:

- `AZURE_CLIENT_ID`: The `clientId` from the output
- `AZURE_CLIENT_SECRET`: The `clientSecret` from the output  
- `AZURE_TENANT_ID`: The `tenantId` from the output
- `AZURE_SUBSCRIPTION_ID`: The `subscriptionId` from the output

## Terraform Backend Setup (Optional)

For production use, configure remote state storage to enable team collaboration and state locking.

### 1. Create Storage Account

```bash
# Set variables
RESOURCE_GROUP="rg-terraform-state"
STORAGE_ACCOUNT="stterraformstate$(date +%s)"
LOCATION="East US"

# Create resource group
az group create --name $RESOURCE_GROUP --location "$LOCATION"

# Create storage account
az storage account create \
    --name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --kind StorageV2

# Create container
az storage container create \
    --name tfstate \
    --account-name $STORAGE_ACCOUNT
```

### 2. Configure Backend

Update `github/versions.tf` to use the remote backend:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate1234567890"
    container_name       = "tfstate"
    key                  = "github-runners.terraform.tfstate"
  }
}
```

### 3. Update Workflow

Add backend configuration to the GitHub Actions workflow by setting these environment variables:

```yaml
env:
  ARM_BACKEND_RESOURCE_GROUP_NAME: "rg-terraform-state" 
  ARM_BACKEND_STORAGE_ACCOUNT_NAME: "stterraformstate1234567890"
  ARM_BACKEND_CONTAINER_NAME: "tfstate"
  ARM_BACKEND_KEY: "github-runners.terraform.tfstate"
```

## Workflow Features

### Automatic Triggers

- **Push to main**: Runs `terraform plan` and `terraform apply` 
- **Pull requests**: Runs `terraform plan` and comments on the PR with results
- **Manual dispatch**: Allows running plan, apply, or destroy manually

### Security Features

- Uses OIDC authentication (no stored credentials)
- Plans are always run before apply
- Apply only runs on main branch or manual approval
- Terraform state is stored remotely with locking

### PR Integration

The workflow automatically comments on pull requests with:
- Terraform format check results
- Validation results  
- Plan output showing proposed changes

## Troubleshooting

### Common Issues

1. **OIDC Authentication Failure**
   - Verify federated credentials subject matches your repository
   - Check that the service principal has correct permissions
   - Ensure all required secrets are set in GitHub

2. **Terraform Backend Issues**
   - Verify storage account and container exist
   - Check service principal has access to storage account
   - Ensure backend configuration is correct

3. **Permission Errors**
   - Verify service principal has Contributor role on subscription
   - For specific resources, may need additional permissions

### Debugging

Enable debug logging by adding this to your workflow:

```yaml
env:
  TF_LOG: DEBUG
  ACTIONS_STEP_DEBUG: true
```

## Best Practices

1. **Use OIDC authentication** for better security
2. **Configure remote state** for team collaboration  
3. **Review plans carefully** before applying changes
4. **Use consistent naming** for Azure resources
5. **Tag all resources** for proper governance
6. **Monitor costs** and set up alerts
7. **Regular backup** of Terraform state (if using local storage)

## Security Considerations

- Service principal has minimal required permissions
- Secrets are stored securely in GitHub
- Terraform state may contain sensitive data - secure accordingly
- Consider using Azure Key Vault for sensitive configuration
- Regular rotation of service principal credentials (if using secrets)