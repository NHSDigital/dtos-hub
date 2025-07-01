module "monitor_action_group" {
  for_each = local.monitor_action_group_map

  source = "../../dtos-devops-templates/infrastructure/modules/monitor-action-group"

  name                = "${module.config[each.value.region].names.monitor-action-group}-${lower(each.value.name_suffix)}"
  resource_group_name = azurerm_resource_group.rg_base[each.value.region].name
  location            = each.value.region
  short_name          = each.value.short_name
  email_receiver      = each.value.email_receiver
  event_hub_receiver  = each.value.event_hub_receiver
  sms_receiver        = each.value.sms_receiver
  voice_receiver      = each.value.voice_receiver
  webhook_receiver    = each.value.webhook_receiver
}

data "azurerm_resources" "all_app_insights" {
  type = "microsoft.insights/components"
}

locals {
  app_insights_ids_in_subscription = [
    for r in data.azurerm_resources.all_app_insights.resources : r.id
    if lower(split("/", r.id)[2]) == lower(var.TARGET_SUBSCRIPTION_ID)
  ]
}

module "azurerm_monitor_smart_detector_alert_rule" {
  for_each = local.monitor_action_group_map

  source = "../../dtos-devops-templates/infrastructure/modules/monitor-smart-detector-alert-rule"

  name                = "ServiceHealth-Incidents-${each.value.name_suffix}"
  resource_group_name = azurerm_resource_group.rg_base[each.value.region].name
  subscription_id     = var.TARGET_SUBSCRIPTION_ID
  action_group_id     = module.monitor_action_group[each.key].monitor_action_group.id
  scope_resource_ids  = [each.value.app_insights_id]

  detector_type       = "FailureAnomaliesDetector"
  description         = "FailureAnomaliesDetector"

}

locals {

  monitor_action_group_object_list = flatten([
    for region in keys(var.regions) : [
      for id in local.app_insights_ids_in_subscription : [
        for action_group_key, action_group_details in var.monitor_action_group : merge(
          {
            short_name       = substr(var.TARGET_SUBSCRIPTION_ID, 0, 3)
            region           = region
            app_insights_id  = id
            name_suffix      = replace(element(split("/", id), length(split("/", id)) - 1), "_", "-")
            action_group_key = action_group_key
          },
          action_group_details
        )
      ]
    ]
  ])

  # ...then project the list of objects into a map with unique keys (combining the iterators), for consumption by a for_each meta argument
  monitor_action_group_map = {
    for object in local.monitor_action_group_object_list : "${object.action_group_key}-${object.region}-${object.app_insights_id}" => object
  }
}
