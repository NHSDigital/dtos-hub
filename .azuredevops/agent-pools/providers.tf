terraform {
  required_version = "~> 1.9"

  backend "azurerm" {}

  required_providers {
    azapi = {
      version = "~> 1.14" # managed_devops_pool module requires this
      source  = "azure/azapi"
    }

    azurerm = {
      version = "~> 3.71" # managed_devops_pool module requires this
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  subscription_id = var.TARGET_SUBSCRIPTION_ID
  features {}
}
