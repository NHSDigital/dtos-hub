data "azurerm_client_config" "current" {}

data "azuread_group" "avd_users" {
  display_name = var.avd_users_group_name
}

data "azuread_group" "avd_admins" {
  display_name = var.avd_admins_group_name
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
