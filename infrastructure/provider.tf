terraform {
  required_version = ">= 1.9.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.2.0"
    }

    random = "~> 3.5.1"
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.53.1"
    }
  }
}

provider "azurerm" {
  features {}
  # Subscription Id to create the resources is passed in via TF variables
  subscription_id = var.TARGET_SUBSCRIPTION_ID
}
