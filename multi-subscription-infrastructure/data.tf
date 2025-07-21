data "azurerm_client_config" "current" {}

# This client id is the same for all Azure customers - it is not a secret.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_certificate
# data "azuread_service_principal" "MicrosoftAzureAppService" {
#   client_id = "abfa0a7c-a6b6-4736-8310-5855508787cd"
# }
