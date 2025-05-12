resource "azurerm_resource_group" "private_dns_rg" {
  for_each = var.regions

  name     = "${module.config[each.key].names.resource-group}-private-dns-zones"
  location = each.key
}

/*--------------------------------------------------------------------------------------------------
  Private DNS Zone Resolver
--------------------------------------------------------------------------------------------------*/

module "private_dns_resolver" {
  for_each = var.regions

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
  Private DNS zones
--------------------------------------------------------------------------------------------------*/

locals {
  private_dns_zones = {
    national_screening          = var.dns_zone_name_private.nationalscreening
    container_registry          = "privatelink.azurecr.io"
    app_insights                = var.private_dns_zones.is_app_insights_private_dns_zone_enabled ? "privatelink.monitor.azure.com" : null
    automation                  = var.private_dns_zones.is_app_insights_private_dns_zone_enabled ? "privatelink.agentsvc.azure-automation.net" : null
    operations_data_store       = var.private_dns_zones.is_app_insights_private_dns_zone_enabled ? "privatelink.ods.opinsights.azure.com" : null
    operations_management_suite = var.private_dns_zones.is_app_insights_private_dns_zone_enabled ? "privatelink.oms.opinsights.azure.com" : null
    api_management              = var.private_dns_zones.is_apim_private_dns_zone_enabled ? "privatelink.azure-api.net" : null
    app_services                = var.private_dns_zones.is_app_services_enabled ? "privatelink.azurewebsites.net" : null
    event_grid                  = var.private_dns_zones.is_event_grid_enabled_dns_zone_enabled ? "privatelink.eventgrid.azure.net" : null
    azure_sql                   = var.private_dns_zones.is_azure_sql_private_dns_zone_enabled ? "privatelink.database.windows.net" : null
    postgres_sql                = var.private_dns_zones.is_postgres_sql_private_dns_zone_enabled ? "privatelink.postgres.database.azure.com" : null
    key_vault                   = var.private_dns_zones.is_key_vault_private_dns_zone_enabled ? "privatelink.vaultcore.azure.net" : null
    storage_blob                = var.private_dns_zones.is_storage_private_dns_zone_enabled ? "privatelink.blob.core.windows.net" : null
    storage_queue               = var.private_dns_zones.is_storage_private_dns_zone_enabled ? "privatelink.queue.core.windows.net" : null
    storage_table               = var.private_dns_zones.is_storage_private_dns_zone_enabled ? "privatelink.table.core.windows.net" : null
    event_hub                   = var.private_dns_zones.is_event_hub_private_dns_zone_enabled ? "privatelink.servicebus.windows.net" : null
    container_apps              = var.private_dns_zones.is_container_apps_enabled_dns_zone_enabled ? "azurecontainerapps.io" : null
  }

  private_dns_zones_obj_list = flatten([
    for region in keys(var.regions) : [
      for description, zone in local.private_dns_zones : {
        region      = region
        description = description
        name        = zone
      } if zone != null
    ]
  ])
  private_dns_zones_map = { for obj in local.private_dns_zones_obj_list : "${obj.region}-${obj.description}" => obj }
}

module "private_dns_zones" {
  for_each = local.private_dns_zones_map

  source = "../../dtos-devops-templates/infrastructure/modules/private-dns-zone"

  name                = each.value.name
  resource_group_name = azurerm_resource_group.private_dns_rg[each.value.region].name
  vnet_id             = module.vnets_hub[each.value.region].vnet.id

  tags = var.tags
}

/*--------------------------------------------------------------------------------------------------
  Private DNS A Records for APIM and Application Gateway
--------------------------------------------------------------------------------------------------*/

locals {
  apim_private_custom_domains      = ["gateway", "portal", "scm"]
  appgw_private_listener_hostnames = ["api"]

  private_dns_a_records_obj_list = flatten([
    for region in keys(var.regions) : [
      [
        for hostname in local.apim_private_custom_domains : {
          region  = region
          name    = hostname
          records = module.api-management[region].private_ip_addresses
        }
      ],
      [
        for hostname in local.appgw_private_listener_hostnames : {
          region  = region
          name    = hostname
          records = [local.appgw_config[region].frontend_ip_configuration.private.private_ip_address]
        }
      ]
    ]
  ])
  private_dns_a_records_map = { for obj in local.private_dns_a_records_obj_list : "${obj.region}-${obj.name}" => obj }
}

module "private-dns-a-records" {
  for_each = local.private_dns_a_records_map

  source = "../../dtos-devops-templates/infrastructure/modules/private-dns-a-record"

  name                = each.value.name
  resource_group_name = resource.azurerm_resource_group.private_dns_rg[each.value.region].name
  zone_name           = var.dns_zone_name_private.nationalscreening
  ttl                 = 300
  records             = each.value.records

  tags = var.tags
}
