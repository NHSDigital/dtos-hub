resource "azurerm_resource_group" "avd" {
  for_each = var.regions

  name     = "${module.config[each.key].names.resource-group}-${var.application}-virtual-desktop"
  location = each.key
}

module "virtual-desktop" {
  for_each = var.regions

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/virtual-desktop?ref=301682d70bc1dda61bcb8d1309b6531eced516db"

  workspace_name      = module.config[each.key].names.avd-workspace
  dag_name            = module.config[each.key].names.avd-dag
  host_pool_name      = module.config[each.key].names.avd-host-pool
  resource_group_name = azurerm_resource_group.avd[each.key].name
  location            = each.key
  login_principal_id  = var.AVD_LOGIN_PRINCIPAL_ID

  #tags = var.tags
}
