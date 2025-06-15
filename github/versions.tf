terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Backend configuration for remote state storage
  # Configure this by creating a terraform.tfvars file with your specific values
  # or by setting backend configuration during terraform init
  #backend "azurerm" {
    # Uncomment and configure these values in your terraform.tfvars or via environment variables:
    # resource_group_name  = "rg-terraform-state"
    # storage_account_name = "stterraformstate12345"
    # container_name       = "tfstate"
    # key                  = "github-runners.terraform.tfstate"
  #}
}

provider "azurerm" {
  features {}
}