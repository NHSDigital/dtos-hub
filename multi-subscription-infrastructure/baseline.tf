resource "azurerm_resource_group" "rg_base" {
  for_each = var.regions

  name     = "${module.config[each.key].names.resource-group}-multi-subscription"
  location = each.key
}
