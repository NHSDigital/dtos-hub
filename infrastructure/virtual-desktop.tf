resource "azurerm_resource_group" "avd" {
  for_each = var.regions

  name     = "${module.config[each.key].names.resource-group}-${var.application}-virtual-desktop"
  location = each.key
}

module "virtual-desktop" {
  for_each = var.regions

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/virtual-desktop?ref=e8fe1a888609a7060f1b88bfde65ebca6b853264"

  workspace_name      = module.config[each.key].names.avd-workspace
  dag_name            = module.config[each.key].names.avd-dag
  host_pool_name      = module.config[each.key].names.avd-host-pool
  resource_group_name = azurerm_resource_group.avd[each.key].name
  resource_group_id   = azurerm_resource_group.avd[each.key].id
  location            = each.key
  login_principal_id  = var.AVD_LOGIN_PRINCIPAL_ID

  #tags = var.tags
}
