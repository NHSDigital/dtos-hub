terraform {
  required_version = ">= 1.9"

  backend "azurerm" {}

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = ">= 1.13, < 3" # managed_devops_pool module requires this
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.26"
    }
  }
}

provider "azurerm" {
  subscription_id = var.TARGET_SUBSCRIPTION_ID
  features {}
}

provider "azapi" {
  subscription_id = var.TARGET_SUBSCRIPTION_ID
  use_msi         = false # prevents 'ChainedTokenCredential authentication failed' when terraform uses AzureCLI auth
}
