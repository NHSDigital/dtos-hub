# Only create a resource group for the private DNS zone in the primary region
resource "azurerm_resource_group" "private_dns_rg" {
  for_each = { for key, region in var.regions : key => region if region.is_primary_region }

  name     = "${module.config[each.key].names.resource-group}-private-dns-zones"
  location = each.key
}

/*--------------------------------------------------------------------------------------------------
  Create the Private DNS Zone Resolver
--------------------------------------------------------------------------------------------------*/

module "private_dns_resolver" {
  for_each = { for key, region in var.regions : key => region if region.is_primary_region }

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/private-dns-zone-resolver?ref=6dbb0d4f42e3fd1f94d4b8e85ef596b7d01844bc"

  name                = "${module.config[each.key].names.resource-application}-private-dns-zone-resolver"
  resource_group_name = azurerm_resource_group.private_dns_rg[each.key].name
  location            = each.key
  vnet_id             = module.vnets_hub[each.key].vnet.id

  inbound_endpoint_config = {
    name                         = "private-dns-resolver-inbound-endpoint"
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = module.subnets_hub["${module.config[each.key].names.subnet}-dns-resolver-in"].id
  }

  tags = var.tags
}

/*--------------------------------------------------------------------------------------------------
  Create each private DNS zone if required to do so
--------------------------------------------------------------------------------------------------*/

module "private_dns_zone_acr" {
  for_each = {
    for key, region in var.regions :
    key => region if region.is_primary_region && var.private_dns_zones.is_acr_private_dns_zone_enabled
  }

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/private-dns-zone?ref=6dbb0d4f42e3fd1f94d4b8e85ef596b7d01844bc"

  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.private_dns_rg[each.key].name
  vnet_id             = module.vnets_hub[each.key].vnet.id

  tags = var.tags
}

module "private_dns_zone_app_insight" {
  for_each = {
    for key, region in var.regions :
    key => region if region.is_primary_region && var.private_dns_zones.is_app_insights_private_dns_zone_enabled
  }

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/private-dns-zone?ref=6dbb0d4f42e3fd1f94d4b8e85ef596b7d01844bc"

  name                = "privatelink.monitor.azure.com"
  resource_group_name = azurerm_resource_group.private_dns_rg[each.key].name
  vnet_id             = module.vnets_hub[each.key].vnet.id

  tags = var.tags
}

module "private_dns_zone_api_management" {
  for_each = {
    for key, region in var.regions :
    key => region if region.is_primary_region && var.private_dns_zones.is_apim_private_dns_zone_enabled
  }

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/private-dns-zone?ref=6dbb0d4f42e3fd1f94d4b8e85ef596b7d01844bc"

  name                = "privatelink.azure-api.net"
  resource_group_name = azurerm_resource_group.private_dns_rg[each.key].name
  vnet_id             = module.vnets_hub[each.key].vnet.id

  tags = var.tags
}

module "private_dns_zone_app_services" {
  for_each = {
    for key, region in var.regions :
    key => region if region.is_primary_region && var.private_dns_zones.is_app_services_enabled
  }

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/private-dns-zone?ref=6dbb0d4f42e3fd1f94d4b8e85ef596b7d01844bc"

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
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/private-dns-zone?ref=6dbb0d4f42e3fd1f94d4b8e85ef596b7d01844bc"

  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.private_dns_rg[each.key].name
  vnet_id             = module.vnets_hub[each.key].vnet.id

  tags = var.tags
}

module "private_dns_zone_key_vault" {
  for_each = {
    for key, region in var.regions :
    key => region if region.is_primary_region && var.private_dns_zones.is_key_vault_private_dns_zone_enabled
  }

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/private-dns-zone?ref=6dbb0d4f42e3fd1f94d4b8e85ef596b7d01844bc"

  name                = "privatelink.vaultcore.azure.net"
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
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/private-dns-zone?ref=6dbb0d4f42e3fd1f94d4b8e85ef596b7d01844bc"

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
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/private-dns-zone?ref=6dbb0d4f42e3fd1f94d4b8e85ef596b7d01844bc"

  name                = "privatelink.queue.core.windows.net"
  resource_group_name = azurerm_resource_group.private_dns_rg[each.key].name
  vnet_id             = module.vnets_hub[each.key].vnet.id

  tags = var.tags
}
