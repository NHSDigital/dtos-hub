terraform {
  backend "azurerm" {}
  required_version = ">= 1.9.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.26"
    }

    random = "~> 3.5.1"

    azuread = {
      source  = "hashicorp/azuread"
      version = "2.53.1"
    }

    azapi = {
      source  = "azure/azapi"
      version = "2.0.1"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.TARGET_SUBSCRIPTION_ID
}

provider "azapi" {
  subscription_id = var.TARGET_SUBSCRIPTION_ID
  use_msi         = false # prevents 'ChainedTokenCredential authentication failed' when terraform uses AzureCLI auth
}

provider "azuread" {}
