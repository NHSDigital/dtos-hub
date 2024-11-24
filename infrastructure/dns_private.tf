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

  source = "../../dtos-devops-templates/infrastructure/modules/private-dns-zone-resolver"

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

  source = "../../dtos-devops-templates/infrastructure/modules/private-dns-zone"

  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.private_dns_rg[each.key].name
  vnet_id             = module.vnets_hub[each.key].vnet.id

  tags = var.tags
}

###### Note multiple DNS zones are all deployed via the is_app_insights_private_dns_zone_enabled flag: ######
module "private_dns_zone_app_insight" {
  for_each = {
    for key, region in var.regions :
    key => region if region.is_primary_region && var.private_dns_zones.is_app_insights_private_dns_zone_enabled
  }

  source = "../../dtos-devops-templates/infrastructure/modules/private-dns-zone"

  name                = "privatelink.monitor.azure.com"
  resource_group_name = azurerm_resource_group.private_dns_rg[each.key].name
  vnet_id             = module.vnets_hub[each.key].vnet.id

  tags = var.tags
}

module "private_dns_zone_azure_automation" {
  for_each = {
    for key, region in var.regions :
    key => region if region.is_primary_region && var.private_dns_zones.is_app_insights_private_dns_zone_enabled
  }

  source = "../../dtos-devops-templates/infrastructure/modules/private-dns-zone"

  name                = "privatelink.agentsvc.azure-automation.net"
  resource_group_name = azurerm_resource_group.private_dns_rg[each.key].name
  vnet_id             = module.vnets_hub[each.key].vnet.id

  tags = var.tags
}

module "private_dns_zone_od_insights" {
  for_each = {
    for key, region in var.regions :
    key => region if region.is_primary_region && var.private_dns_zones.is_app_insights_private_dns_zone_enabled
  }

  source = "../../dtos-devops-templates/infrastructure/modules/private-dns-zone"

  name                = "privatelink.ods.opinsights.azure.com"
  resource_group_name = azurerm_resource_group.private_dns_rg[each.key].name
  vnet_id             = module.vnets_hub[each.key].vnet.id

  tags = var.tags
}

module "private_dns_zone_op_insights" {
  for_each = {
    for key, region in var.regions :
    key => region if region.is_primary_region && var.private_dns_zones.is_app_insights_private_dns_zone_enabled
  }

  source = "../../dtos-devops-templates/infrastructure/modules/private-dns-zone"

  name                = "privatelink.oms.opinsights.azure.com"
  resource_group_name = azurerm_resource_group.private_dns_rg[each.key].name
  vnet_id             = module.vnets_hub[each.key].vnet.id

  tags = var.tags
}

###### End of Azure Monitor / Application Insights DNS Zone ######

module "private_dns_zone_api_management" {
  for_each = {
    for key, region in var.regions :
    key => region if region.is_primary_region && var.private_dns_zones.is_apim_private_dns_zone_enabled
  }

  source = "../../dtos-devops-templates/infrastructure/modules/private-dns-zone"

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

  source = "../../dtos-devops-templates/infrastructure/modules/private-dns-zone"

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

  source = "../../dtos-devops-templates/infrastructure/modules/private-dns-zone"

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

  source = "../../dtos-devops-templates/infrastructure/modules/private-dns-zone"

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

  source = "../../dtos-devops-templates/infrastructure/modules/private-dns-zone"

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

  source = "../../dtos-devops-templates/infrastructure/modules/private-dns-zone"

  name                = "privatelink.queue.core.windows.net"
  resource_group_name = azurerm_resource_group.private_dns_rg[each.key].name
  vnet_id             = module.vnets_hub[each.key].vnet.id

  tags = var.tags
}

module "private_dns_zone_private_nationalscreening_nhs_uk" {
  for_each = {
    for key, region in var.regions :
    key => region if region.is_primary_region
  }

  source = "../../dtos-devops-templates/infrastructure/modules/private-dns-zone"

  name                = var.dns_zone_name_private
  resource_group_name = azurerm_resource_group.private_dns_rg[each.key].name
  vnet_id             = module.vnets_hub[each.key].vnet.id

  tags = var.tags
}

/*--------------------------------------------------------------------------------------------------
  API Management Private DNS A Records
--------------------------------------------------------------------------------------------------*/

locals {
  apim_private_dns_a_records_obj_list = flatten([
    for region in keys(var.regions) : [
      for domain_obj in var.apim_config.custom_domains : [
        for type, value in domain_obj : {
          region = region
          type   = type
          name   = value.name
          ttl    = value.a_record_ttl
        }
      ]
    ]
  ])
  appim_private_dns_a_records_map = { for obj in local.apim_private_dns_a_records_obj_list : "${obj.region}-${obj.type}" => obj }
}

module "apim-private-dns-a-records" {
  for_each = local.appim_private_dns_a_records_map

  source = "../../dtos-devops-templates/infrastructure/modules/private-dns-a-record"

  name                = each.value.name
  resource_group_name = resource.azurerm_resource_group.private_dns_rg[each.value.region].name
  zone_name           = module.private_dns_zone_private_nationalscreening_nhs_uk[each.value.region].name
  ttl                 = each.value.ttl
  records             = [module.api-management[each.value.region].private_ip_address]

  tags = var.tags
}

/*--------------------------------------------------------------------------------------------------
  Application Gateway Private DNS A Records
--------------------------------------------------------------------------------------------------*/

locals {
  appgw_private_dns_a_records_obj_list = flatten([
    for region in keys(var.regions) : [
      for record in ["api", "portal"] : {
        region = region
        name   = record  # Use 'record' here, not 'name'
      }
    ]
  ])
  appgw_private_dns_a_records_map = { for obj in local.appgw_private_dns_a_records_obj_list : "${obj.region}-${obj.name}" => obj }
}

module "appgw-private-dns-a-records" {
  for_each = local.appgw_private_dns_a_records_map

  source = "../../dtos-devops-templates/infrastructure/modules/private-dns-a-record"

  name                = each.value.name
  resource_group_name = resource.azurerm_resource_group.private_dns_rg[each.value.region].name
  zone_name           = module.private_dns_zone_private_nationalscreening_nhs_uk[each.value.region].name
  ttl                 = 300
  records             = [module.application-gateway-pip.ip_address]

  tags = var.tags
}
