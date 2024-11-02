module "api-management" {
  for_each = var.regions

  source = "../../dtos-devops-templates/infrastructure/modules/api-management"

  name                          = module.config[each.key].names.api-management
  resource_group_name           = azurerm_resource_group.rg_hub[each.key].name
  location                      = each.key
  certificate_details           = []
  gateway_disabled              = var.apim_config.gateway_disabled
  public_ip_address_id          = module.apim-public-ip[each.key].id
  publisher_email               = var.apim_config.publisher_email
  publisher_name                = var.apim_config.publisher_name
  sku_capacity                  = var.apim_config.sku_capacity
  sku_name                      = var.apim_config.sku_name
  virtual_network_type          = var.apim_config.virtual_network_type
  virtual_network_configuration = [module.subnets_hub["${module.config[each.key].names.subnet}-api-mgmt"].id]
  zones                         = var.apim_config.zones

  tags = var.tags

}

module "apim-public-ip" {
  for_each = var.regions

  source = "../../dtos-devops-templates/infrastructure/modules/public-ip"

  name                = "${module.config[each.key].names.public-ip-address}-api-mgmt"
  resource_group_name = azurerm_resource_group.rg_hub[each.key].name
  location            = each.key
  allocation_method   = var.apim_config.public_ip_allocation_method
  domain_name_label   = module.config[each.key].names.api-management
  sku                 = var.apim_config.public_ip_sku
  zones               = var.apim_config.zones

  tags = var.tags
}
