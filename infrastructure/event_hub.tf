module "eventhub_law_export" {
  for_each = local.eventhubs_map

  source = "../../dtos-devops-templates/infrastructure/modules/event-hub"

  name                = "${module.config[each.value.region_key].names.event-hub-namespace}-law-export"
  resource_group_name = azurerm_resource_group.rg_base[each.value.region_key].name
  location            = each.value.region_key

  log_analytics_workspace_id                       = module.log_analytics_workspace_hub[local.primary_region].id
  monitor_diagnostic_setting_eventhub_enabled_logs = local.monitor_diagnostic_setting_eventhub_enabled_logs
  monitor_diagnostic_setting_eventhub_metrics      = local.monitor_diagnostic_setting_eventhub_metrics

  public_network_access_enabled = each.value.public_network_access_enabled

  auto_inflate             = each.value.auto_inflate
  capacity                 = each.value.capacity
  maximum_throughput_units = each.value.maximum_throughput_units
  minimum_tls_version      = each.value.minimum_tls_version
  sku                      = each.value.sku
  auth_rule                = each.value.auth_rule

  # Event Hubs Configuration per namespace
  event_hubs = each.value.event_hubs

  # Private Endpoint Configuration if enabled
  private_endpoint_properties = var.features.private_endpoints_enabled ? {
    private_dns_zone_ids_eventhub        = [module.private_dns_zones["${each.value.region_key}-event_hub"].id]
    private_endpoint_enabled             = var.features.private_endpoints_enabled
    private_endpoint_subnet_id           = module.subnets_hub["${module.config[each.value.region_key].names.subnet}-pep"].id
    private_endpoint_resource_group_name = azurerm_resource_group.rg_private_endpoints[each.value.region_key].name
    private_service_connection_is_manual = var.features.private_service_connection_is_manual
  } : null

  tags = var.tags
}

locals {
  eventhub_namespaces_flatlist = flatten([
    for region_key, region_val in var.regions : [
      for namespace_key, namespace_val in var.eventhub_namespaces : {
        name                          = "${namespace_key}-${region_key}"
        region_key                    = region_key
        auto_inflate                  = namespace_val.auto_inflate
        auth_rule                     = namespace_val.auth_rule
        capacity                      = namespace_val.capacity
        maximum_throughput_units      = namespace_val.maximum_throughput_units
        minimum_tls_version           = namespace_val.minimum_tls_version
        sku                           = namespace_val.sku
        public_network_access_enabled = namespace_val.public_network_access_enabled
        event_hubs                    = namespace_val.event_hubs
      }
    ]
  ])

  # Project the above list into a map with unique keys for consumption in a for_each meta argument
  eventhubs_map = { for eventhub in local.eventhub_namespaces_flatlist : eventhub.name => eventhub }
}
