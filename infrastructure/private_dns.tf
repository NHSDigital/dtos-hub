# Only create a resource group for the private DNS zone in the primary region
resource "azurerm_resource_group" "private_dns_rg" {
  for_each = { for key, region in var.regions : key => region if region.is_primary_region }

  name     = "${module.config[each.key].names.resource-group}-private-dns-zones"
  location = each.key
}

/*--------------------------------------------------------------------------------------------------
  Create each private DNS zone if required to do so
--------------------------------------------------------------------------------------------------*/

module "private_dns_zone_app_services" {
  for_each = {
    for key, region in var.regions :
    key => region if region.is_primary_region && var.private_dns_zones.is_app_services_enabled
  }

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/private-dns-zone?ref=2296f761f4edc3b413e2629c98309df9c6fa0849"

  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.private_dns_rg[each.key].name
  vnet_id             = module.vnets_hub[each.key].vnet.id

  tags = var.tags
}

module "private_dns_zone_azure_sql" {
  for_each = {
    for key, region in var.regions :
    key => region if region.is_primary_region && var.private_dns_zones.is_azure_sql_private_dns_zone_enabled
  }

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/private-dns-zone?ref=2296f761f4edc3b413e2629c98309df9c6fa0849"

  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.private_dns_rg[each.key].name
  vnet_id             = module.vnets_hub[each.key].vnet.id

  tags = var.tags
}

module "private_dns_zone_storage_blob" {
  for_each = {
    for key, region in var.regions :
    key => region if region.is_primary_region && var.private_dns_zones.is_storage_private_dns_zone_enabled
  }

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/private-dns-zone?ref=2296f761f4edc3b413e2629c98309df9c6fa0849"

  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.private_dns_rg[each.key].name
  vnet_id             = module.vnets_hub[each.key].vnet.id

  tags = var.tags
}

module "private_dns_zone_storage_queue" {
  for_each = {
    for key, region in var.regions :
    key => region if region.is_primary_region && var.private_dns_zones.is_storage_private_dns_zone_enabled
  }

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/private-dns-zone?ref=2296f761f4edc3b413e2629c98309df9c6fa0849"

  name                = "privatelink.queue.core.windows.net"
  resource_group_name = azurerm_resource_group.private_dns_rg[each.key].name
  vnet_id             = module.vnets_hub[each.key].vnet.id

  tags = var.tags
}
