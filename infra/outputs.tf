output "resource_group_name" {
  description = "Name of the created Resource Group"
  value       = azurerm_resource_group.github_runners.name
}

output "resource_group_id" {
  description = "ID of the created Resource Group"
  value       = azurerm_resource_group.github_runners.id
}

output "container_app_environment_name" {
  description = "Name of the Container App Environment"
  value       = azurerm_container_app_environment.github_runners.name
}

output "container_app_environment_id" {
  description = "ID of the Container App Environment"
  value       = azurerm_container_app_environment.github_runners.id
}

output "container_registry_name" {
  description = "Name of the Azure Container Registry"
  value       = azurerm_container_registry.github_runners.name
}

output "container_registry_login_server" {
  description = "Login server URL of the Azure Container Registry"
  value       = azurerm_container_registry.github_runners.login_server
}

output "container_registry_id" {
  description = "ID of the Azure Container Registry"
  value       = azurerm_container_registry.github_runners.id
}

output "user_assigned_identity_name" {
  description = "Name of the User Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.github_runners.name
}

output "user_assigned_identity_id" {
  description = "ID of the User Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.github_runners.id
}

output "user_assigned_identity_principal_id" {
  description = "Principal ID of the User Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.github_runners.principal_id
}

output "user_assigned_identity_client_id" {
  description = "Client ID of the User Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.github_runners.client_id
}