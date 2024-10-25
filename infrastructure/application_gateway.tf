resource "azurerm_resource_group" "agw" {
  for_each = var.regions

  name     = "${module.config[each.key].names.resource-group}-${var.application}-application-gateway"
  location = each.key
}

module "application-gateway-pip" {
  for_each = var.regions

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/public-ip?ref=f693566bc9d67bd8d7d5a196fb1a244ff7478ee2"

  name                 = "${module.config[each.key].names.public-ip-address}-AGW"
  resource_group_name  = azurerm_resource_group.rg_hub[each.key]
  location             = each.key
  allocation_method    = "Static"
  zones                = each.value.is_primary_region ? ["1", "2", "3"] : null
  sku                  = "Standard"

  tags = var.tags
}

module "application-gateway" {
  for_each = var.regions

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/application-gateway?ref=ce9858c0187d0e3e62ffbc2d594cd6a1d61270a4"

  name                 = module.config[each.key].names.application-gateway.name
  location             = each.key
  resource_group_name  = azurerm_resource_group.agw[each.key].name
  common_names         = module.config[each.key].names.application-gateway
  gateway_subnet       = module.subnets_hub["${module.config[each.key].names.subnet}-app-gateway"]
  public_ip_address_id = module.application-gateway-pip[each.key].id
  zones                = each.value.is_primary_region ? ["1", "2", "3"] : null

  tags = var.tags
}
