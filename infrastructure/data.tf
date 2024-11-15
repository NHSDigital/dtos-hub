data "azurerm_client_config" "current" {}

data "azuread_group" "avd_users" {
  display_name = var.avd_users_group_name
}

data "azuread_group" "avd_admins" {
  display_name = var.avd_admins_group_name
}


data "azurerm_key_vault_secret" "this" {
  for_each     = toset(var.apim_config.aad.secrets)
  name         = each.key
  key_vault_id = module.key_vault.key_vault_id
}

