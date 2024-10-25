resource "azurerm_resource_group" "agw" {
  for_each = var.regions

  name     = "${module.config[each.key].names.resource-group}-${var.application}-application-gateway"
  location = each.key
}

module "application-gateway-pip" {
  for_each = var.regions

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/public-ip?ref=f552c0ffe1f5991248266c1b37bca49084412df1"

  name                 = "${module.config[each.key].names.public-ip-address}-AGW"
  resource_group_name  = azurerm_resource_group.rg_hub[each.key]
  location             = each.key
  allocation_method    = "Static"
  zones                = each.value.is_primary_region ? ["1", "2", "3"] : null
  sku                  = "Standard"

  tags                 = var.tags
}

module "application-gateway" {
  for_each = var.regions

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/application-gateway?ref=f552c0ffe1f5991248266c1b37bca49084412df1"

  name                    = module.config[each.key].names.application-gateway.name
  location                = each.key
  resource_group_name     = azurerm_resource_group.agw.name
  gateway_subnet          = module.subnets_hub["${module.config[each.key].names.subnet}-app-gateway"]
  public_ip_address_id    = module.application-gateway-pip[each.key].id

  tags = var.tags
}
