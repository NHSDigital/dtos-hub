module "acr" {

  # only create in regions where is_primary_region is true and only when acr map is not empty
  for_each = {
    for key, value in var.regions : key => value
    if value.is_primary_region && var.acr != {}
  }

  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/azure-container-registry?ref=feat/DTOSS-3386-Private-Endpoint-Updates"

  name                = module.config[each.key].names.azure-container-registry
  resource_group_name = azurerm_resource_group.rg_hub[each.key].name
  location            = each.key

  admin_enabled                 = var.acr.admin_enabled
  uai_name                      = var.acr.uai_name
  sku                           = var.acr.sku
  public_network_access_enabled = var.features.public_network_access_enabled

  # Private Endpoint Configuration if enabled
  private_endpoint_properties = var.features.private_endpoints_enabled ? {
    private_dns_zone_ids                 = [module.private_dns_zone_acr[each.key].private_dns_zone.id]
    private_endpoint_enabled             = var.features.private_endpoints_enabled
    private_endpoint_subnet_id           = module.subnets_hub["${module.config[each.key].names.subnet}-acr"].id
    private_endpoint_resource_group_name = azurerm_resource_group.rg_base[each.key].name
    private_service_connection_is_manual = var.features.private_service_connection_is_manual
  } : null

  tags = var.tags

}