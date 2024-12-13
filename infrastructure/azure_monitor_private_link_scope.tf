# This is a global resource, but it can have regional private endpoints
resource "azurerm_monitor_private_link_scope" "ampls" {
  name                = module.config[local.primary_region].names.private-link-scope
  resource_group_name = azurerm_resource_group.rg_private_endpoints[local.primary_region].name

  ingestion_access_mode = "PrivateOnly"
  query_access_mode     = "Open"

  tags = var.tags
}

module "private_endpoint_ampls" {
  for_each = var.features.private_endpoints_enabled ? var.regions : {}

  source = "../../dtos-devops-templates/infrastructure/modules/private-endpoint"

  name                = module.config[each.key].names.private-link-scope-private-endpoint
  resource_group_name = azurerm_resource_group.rg_private_endpoints[each.key].name
  location            = each.key
  subnet_id           = module.subnets_hub["${module.config[each.key].names.subnet}-pep"].id

  private_dns_zone_group = {
    name = "${module.config[each.key].names.private-link-scope-private-endpoint}-zone-group"
    private_dns_zone_ids = [
      module.private_dns_zones["${each.key}-app_insights"].id,
      module.private_dns_zones["${each.key}-automation"].id,
      module.private_dns_zones["${each.key}-operations_data_store"].id,
      module.private_dns_zones["${each.key}-operations_management_suite"].id,
      module.private_dns_zones["${each.key}-storage_blob"].id
    ]
  }

  private_service_connection = {
    name                           = "${module.config[each.key].names.private-link-scope-private-endpoint}-connection"
    private_connection_resource_id = azurerm_monitor_private_link_scope.ampls.id
    subresource_names              = ["azuremonitor"]
    is_manual_connection           = var.features.private_service_connection_is_manual
  }

  tags = var.tags
}
