data "azurerm_client_config" "current" {}

data "azuread_group" "avd_users" {
  display_name = var.avd_users_group_name
}

data "azuread_group" "avd_admins" {
  display_name = var.avd_admins_group_name
}

data "azuread_group" "avd_platform_users" {
  display_name = "DToS-platform-team-Dev"
}

data "azuread_group" "avd_pentest_users" {
  display_name = "DToS-Penetration-Testers"
}

# This client id is the same for all Azure customers - it is not a secret.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_certificate
data "azuread_service_principal" "MicrosoftAzureAppService" {
  client_id = "abfa0a7c-a6b6-4736-8310-5855508787cd"
}

data "azuread_service_principal" "MicrosoftAzureFrontDoorCdn" {
  client_id = "205478c0-bd83-4e1b-a9d6-db63a3e1e1c8"
}

data "azurerm_key_vault_secret" "object-id" {
  for_each     = var.regions
  name         = "dtos-apim-object-id"
  key_vault_id = module.key_vault[each.key].key_vault_id

  depends_on = [azurerm_key_vault_access_policy.terraform-mi]
}

data "azurerm_key_vault_secret" "secret" {
  for_each     = var.regions
  name         = "dtos-apim-secret"
  key_vault_id = module.key_vault[each.key].key_vault_id

  depends_on = [azurerm_key_vault_access_policy.terraform-mi]
}
