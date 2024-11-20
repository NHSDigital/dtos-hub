module "api-management" {
  for_each = var.regions

  source = "../../dtos-devops-templates/infrastructure/modules/api-management"

  name                          = module.config[each.key].names.api-management
  resource_group_name           = azurerm_resource_group.rg_hub[each.key].name
  location                      = each.key
  certificate_details           = []
  gateway_disabled              = var.apim_config.gateway_disabled
  publisher_email               = var.apim_config.publisher_email
  publisher_name                = var.apim_config.publisher_name
  sku_capacity                  = var.apim_config.sku_capacity
  sku_name                      = var.apim_config.sku_name
  virtual_network_type          = var.apim_config.virtual_network_type
  virtual_network_configuration = [module.subnets_hub["${module.config[each.key].names.subnet}-api-mgmt"].id]
  zones                         = var.apim_config.zones

  /*________________________________
| API Management AAD Integration |
__________________________________*/
  client_id       = data.azurerm_key_vault_secret.object-id[each.key].value
  client_secret   = data.azurerm_key_vault_secret.secret[each.key].value
  allowed_tenants = [data.azurerm_client_config.current.tenant_id]

  tags = var.tags

}
