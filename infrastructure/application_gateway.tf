module "application-gateway-pip" {
  for_each = var.regions

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/public-ip?ref=a97430c23c686fc16fa5cf387794c394aab01f54"

  name                 = "${module.config[each.key].names.public-ip-address}-app-gateway"
  resource_group_name  = azurerm_resource_group.rg_hub[each.key].name
  location             = each.key
  allocation_method    = "Static"
  zones                = each.value.is_primary_region ? ["1", "2", "3"] : null
  sku                  = "Standard"

  tags = var.tags
}

module "application-gateway" {
  for_each = var.regions

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/application-gateway?ref=a97430c23c686fc16fa5cf387794c394aab01f54"

  location             = each.key
  resource_group_name  = azurerm_resource_group.rg_hub[each.key].name
  common_names         = module.config[each.key].names.application-gateway
  gateway_subnet       = module.subnets_hub["${module.config[each.key].names.subnet}-app-gateway"]
  public_ip_address_id = module.application-gateway-pip[each.key].id
  zones                = each.value.is_primary_region ? ["1", "2", "3"] : null

  tags = var.tags
}
