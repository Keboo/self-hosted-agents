variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-github-runners"
}

variable "container_app_environment_name" {
  description = "Name of the Container App Environment"
  type        = string
  default     = "cae-github-runners"
}

variable "container_registry_name" {
  description = "Name of the Azure Container Registry (must be globally unique)"
  type        = string
  default     = "acrgithubrunners"
}

variable "user_assigned_identity_name" {
  description = "Name of the User Assigned Managed Identity"
  type        = string
  default     = "mi-github-runners"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Purpose     = "github-runners"
    ManagedBy   = "terraform"
  }
}