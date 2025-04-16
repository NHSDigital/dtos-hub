data "azurerm_client_config" "current" {}

data "azuread_group" "avd_users" {
  display_name = var.avd_users_group_name
}

data "azuread_group" "avd_admins" {
  display_name = var.avd_admins_group_name
}

# This client id is the same for all Azure customers - it is not a secret.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_certificate
data "azuread_service_principal" "MicrosoftAzureAppService" {
  client_id = "abfa0a7c-a6b6-4736-8310-5855508787cd"
}

data "azurerm_key_vault_secret" "object-id" {
  for_each     = var.regions
  name         = "dtos-apim-object-id"
  key_vault_id = module.key_vault[each.key].key_vault_id
}

data "azurerm_key_vault_secret" "secret" {
  for_each     = var.regions
  name         = "dtos-apim-secret"
  key_vault_id = module.key_vault[each.key].key_vault_id
}
