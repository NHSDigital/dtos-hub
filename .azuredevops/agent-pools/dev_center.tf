resource "azurerm_resource_group" "dev_center_rg" {
  for_each = var.regions

  name     = "${module.config[each.key].names.resource-group}-dev-center"
  location = each.key
}

resource "azurerm_dev_center" "this" {
  for_each = var.regions

  name                = module.config[each.key].names.dev-center
  resource_group_name = azurerm_resource_group.dev_center_rg[each.key].name
  location            = each.key
}

resource "azurerm_dev_center_project" "this" {
  for_each = var.regions

  name                = module.config[each.key].names.dev-center-project
  resource_group_name = azurerm_resource_group.dev_center_rg[each.key].name
  location            = each.key
  dev_center_id       = azurerm_dev_center.this[each.key].id
}
