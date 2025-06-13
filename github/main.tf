# Create Resource Group
resource "azurerm_resource_group" "github_runners" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Create User Assigned Managed Identity
resource "azurerm_user_assigned_identity" "github_runners" {
  name                = var.user_assigned_identity_name
  location            = azurerm_resource_group.github_runners.location
  resource_group_name = azurerm_resource_group.github_runners.name
  tags                = var.tags
}

# Create Azure Container Registry
resource "azurerm_container_registry" "github_runners" {
  name                = var.container_registry_name
  resource_group_name = azurerm_resource_group.github_runners.name
  location            = azurerm_resource_group.github_runners.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = var.tags

  # Enable ARM audience tokens
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.github_runners.id]
  }
}

# Grant ACR Pull access to the User Assigned Identity
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.github_runners.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.github_runners.principal_id
}

# Grant ACR Push access to the User Assigned Identity (needed for CI/CD)
resource "azurerm_role_assignment" "acr_push" {
  scope                = azurerm_container_registry.github_runners.id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_user_assigned_identity.github_runners.principal_id
}

# Create Log Analytics Workspace for Container Apps
resource "azurerm_log_analytics_workspace" "github_runners" {
  name                = "law-${var.container_app_environment_name}"
  location            = azurerm_resource_group.github_runners.location
  resource_group_name = azurerm_resource_group.github_runners.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# Create Container App Environment
resource "azurerm_container_app_environment" "github_runners" {
  name                       = var.container_app_environment_name
  location                   = azurerm_resource_group.github_runners.location
  resource_group_name        = azurerm_resource_group.github_runners.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.github_runners.id
  tags                       = var.tags
}