resource "azurerm_resource_group" "event_grid_topic" {
  for_each = local.event_grid_resource_groups_map

  name     = "${module.config[each.value.region].names.resource-group}-${each.value.environment}-evgt"
  location = each.value.region
}

module "event_grid_topic" {
  for_each = local.event_grid_map

  source = "../../dtos-devops-templates/infrastructure/modules/event-grid-topic"

  topic_name = each.value.event_topic_name
  # resource_group_name = azurerm_resource_group.event_grid_topic[each.value.region].name
  resource_group_name = azurerm_resource_group.event_grid_topic["${each.value.environment}-${each.value.region}"].name
  location            = each.value.region
  identity_type       = each.value.identity_type
  inbound_ip_rules    = each.value.inbound_ip_rules

  # Private Endpoint Configuration if enabled
  private_endpoint_properties = var.features.private_endpoints_enabled ? {
    private_dns_zone_ids                 = [module.private_dns_zones["${each.value.region}-event_grid"].id]
    private_endpoint_enabled             = var.features.private_endpoints_enabled
    private_endpoint_subnet_id           = module.subnets_hub["${module.config[each.value.region].names.subnet}-pep"].id
    private_endpoint_resource_group_name = azurerm_resource_group.rg_private_endpoints[each.value.region].name
    private_service_connection_is_manual = var.features.private_service_connection_is_manual
  } : null

  tags = var.tags
}

locals {

  # Expand a flattened list of objects for all resource groups (allows nested for loops)
  event_grid_resource_groups_object_list = flatten([
    for key in keys(var.regions) : [
      for environment in var.attached_environments : merge(
        {
          region      = key         # 1st iterator
          environment = environment # 2nd iterator
        }
      )
    ]
  ])

  # ...then project the list of objects into a map with unique keys (combining the iterators), for consumption by a for_each meta argument
  event_grid_resource_groups_map = {
    for object in local.event_grid_resource_groups_object_list : "${object.environment}-${object.region}" => object
  }

  event_grids = {
    for event_grid_key, event_grid_details in var.event_grid_configs :
    event_grid_key => merge(var.event_grid_defaults, {
      event_topic_name = "event-grid-${event_grid_key}"
    }, event_grid_details) # event_grid_details will win merge conflicts
  }

  event_grid_config_object_list = flatten([
    for region in keys(var.regions) : [
      for event_grid_key, event_grid_details in local.event_grids : merge(
        {
          region         = region         # 1st iterator
          event_grid_key = event_grid_key # 2nd iterator
        },
        event_grid_details # the rest of the key/value pairs for a specific event_grids
      )
    ]
  ])

  # ...then project the list of objects into a map with unique keys (combining the iterators), for consumption by a for_each meta argument
  event_grid_map = {
    for object in local.event_grid_config_object_list : "${object.event_grid_key}-${object.region}" => object
  }
}
