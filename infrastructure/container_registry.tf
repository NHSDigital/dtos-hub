module "acr" {

  # only create in regions where is_primary_region is true and only when acr map is not empty
  for_each = locals.acr_map

  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/azure-container-registry?ref=6dbb0d4f42e3fd1f94d4b8e85ef596b7d01844bc"

  name                = module.config[each.value.region_key].names.azure-container-registry
  resource_group_name = azurerm_resource_group.rg_base[each.value.region_key].name
  location            = each.value.region_key

  admin_enabled                 = each.value.admin_enabled
  uai_name                      = each.value.uai_name
  sku                           = each.value.sku
  public_network_access_enabled = var.features.public_network_access_enabled

  # Private Endpoint Configuration if enabled
  private_endpoint_properties = var.features.private_endpoints_enabled ? {
    private_dns_zone_ids                 = [module.private_dns_zone_acr[each.value.region_key].private_dns_zone.id]
    private_endpoint_enabled             = var.features.private_endpoints_enabled
    private_endpoint_subnet_id           = module.subnets_hub["${module.config[each.value.region_key].names.subnet}-acr"].id
    private_endpoint_resource_group_name = azurerm_resource_group.rg_base[each.value.region_key].name
    private_service_connection_is_manual = var.features.private_service_connection_is_manual
  } : null

  tags = each.value.tags
}

# Create a map of acrs to loop through
locals {
  acr_map = {
    for key, value in local.projects_map : key => {
      admin_enabled                 = value.acr.admin_enabled
      uai_name                      = value.acr.uai_name
      sku                           = value.acr.sku
      public_network_access_enabled = value.acr.public_network_access_enabled
      region                        = value.region_key
    }
    if value.acr != {} # only include acrs that are not empty
    && value.is_primary_region # only include acrs in primary regions
  }
}
