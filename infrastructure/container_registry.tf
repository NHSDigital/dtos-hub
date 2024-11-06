module "acr" {

  # only create in regions where is_primary_region is true and only when acr map is not empty
  for_each = local.acr_map

  source = "../../dtos-devops-templates/infrastructure/modules/container-registry"

  name                = "${module.config[each.value.region].names.azure-container-registry}${each.value.name_suffix}"
  resource_group_name = azurerm_resource_group.rg_project[each.value.project_key].name
  location            = each.value.region

  admin_enabled                 = each.value.admin_enabled
  uai_name                      = each.value.uai_name
  sku                           = each.value.sku
  public_network_access_enabled = var.features.public_network_access_enabled

  # Private Endpoint Configuration if enabled
  private_endpoint_properties = var.features.private_endpoints_enabled ? {
    private_dns_zone_ids                 = [module.private_dns_zone_acr[each.value.region].private_dns_zone.id]
    private_endpoint_enabled             = var.features.private_endpoints_enabled
    private_endpoint_subnet_id           = module.subnets_hub["${module.config[each.value.region].names.subnet}-acr"].id
    private_endpoint_resource_group_name = azurerm_resource_group.rg_project[each.value.project_key].name
    private_service_connection_is_manual = var.features.private_service_connection_is_manual
  } : null

  tags = each.value.tags
}

# Create a map of acrs to loop through
locals {
  acr_map = {
    for key, value in local.projects_map : key => {
      project_key                   = key
      name_suffix                   = value.short_name
      admin_enabled                 = value.acr.admin_enabled
      uai_name                      = value.acr.uai_name
      sku                           = value.acr.sku
      public_network_access_enabled = value.acr.public_network_access_enabled
      region                        = value.region_key
      tags                          = value.tags
    }
    if value.acr != {}         # only include acrs that are not empty
    && value.is_primary_region # only include acrs in primary regions
  }
}
