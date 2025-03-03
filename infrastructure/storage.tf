module "storage" {
  for_each = local.storage_accounts_map

  source = "../../dtos-devops-templates/infrastructure/modules/storage"

<<<<<<< HEAD
  name                = substr("${module.config[each.value.region_key].names.storage-account}${lower(each.value.name_suffix)}", 0, 24)
  resource_group_name = azurerm_resource_group.rg_hub[each.value.region_key].name
  location            = each.value.region_key
=======
  name                = substr("${module.config[each.value.region].names.storage-account}${lower(each.value.name_suffix)}${lower(each.value.environment)}", 0, 24)
  resource_group_name = azurerm_resource_group.event_grid_topic["${each.value.environment}-${each.value.region}"].name
  location            = each.value.region
>>>>>>> f98c2d0 (feat: Add event grid hub (#71))

  containers = each.value.containers

  log_analytics_workspace_id                              = module.log_analytics_workspace_hub[local.primary_region].id
  monitor_diagnostic_setting_storage_account_enabled_logs = local.monitor_diagnostic_setting_storage_account_enabled_logs
  monitor_diagnostic_setting_storage_account_metrics      = local.monitor_diagnostic_setting_storage_account_metrics

  account_replication_type      = each.value.replication_type
  account_tier                  = each.value.account_tier
  public_network_access_enabled = each.value.public_network_access_enabled

  rbac_roles = local.rbac_roles_storage

  # Private Endpoint Configuration if enabled
  private_endpoint_properties = var.features.private_endpoints_enabled ? {
<<<<<<< HEAD
    # private_dns_zone_ids_blob            = [data.terraform_remote_state.hub.outputs.private_dns_zones["${each.value.region_key}-storage_blob"].id]
    # private_dns_zone_ids_queue           = [data.terraform_remote_state.hub.outputs.private_dns_zones["${each.value.region_key}-storage_queue"].id]
    private_dns_zone_ids_blob            = [module.private_dns_zones["${each.value.region_key}-storage_blob"].id]
    private_dns_zone_ids_queue           = [module.private_dns_zones["${each.value.region_key}-storage_queue"].id]
    private_endpoint_enabled             = var.features.private_endpoints_enabled
    private_endpoint_subnet_id           = module.subnets_hub["${module.config[each.value.region_key].names.subnet}-pep"].id
    private_endpoint_resource_group_name = azurerm_resource_group.rg_private_endpoints[each.value.region_key].name
=======
    private_dns_zone_ids_blob            = [module.private_dns_zones["${each.value.region}-storage_blob"].id]
    private_dns_zone_ids_queue           = [module.private_dns_zones["${each.value.region}-storage_queue"].id]
    private_endpoint_enabled             = var.features.private_endpoints_enabled
    private_endpoint_subnet_id           = module.subnets_hub["${module.config[each.value.region].names.subnet}-pep"].id
    private_endpoint_resource_group_name = azurerm_resource_group.rg_private_endpoints[each.value.region].name
>>>>>>> f98c2d0 (feat: Add event grid hub (#71))
    private_service_connection_is_manual = var.features.private_service_connection_is_manual
  } : null

  tags = var.tags
}

locals {
  storage_accounts_flatlist = flatten([
<<<<<<< HEAD
    for region_key, region_val in var.regions : [
      for storage_key, storage_val in var.storage_accounts : {
        name                          = "${storage_key}-${region_key}"
        region_key                    = region_key
        name_suffix                   = storage_val.name_suffix
        replication_type              = storage_val.replication_type
        account_tier                  = storage_val.account_tier
        public_network_access_enabled = storage_val.public_network_access_enabled
        containers                    = storage_val.containers
      }
=======
    for region, region_val in var.regions : [
      for environment in var.attached_environments : [
        for storage_key, storage_val in var.storage_accounts : {
          name                          = "${storage_key}-${environment}-${region}"
          region                        = region
          environment                   = environment
          name_suffix                   = storage_val.name_suffix
          replication_type              = storage_val.replication_type
          account_tier                  = storage_val.account_tier
          public_network_access_enabled = storage_val.public_network_access_enabled
          containers                    = storage_val.containers
        }
      ]
>>>>>>> f98c2d0 (feat: Add event grid hub (#71))
    ]
  ])

  # Project the above list into a map with unique keys for consumption in a for_each meta argument
  storage_accounts_map = { for storage in local.storage_accounts_flatlist : storage.name => storage }
}
