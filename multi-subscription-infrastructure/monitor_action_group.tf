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

locals {
  monitor_action_group_object_list = flatten([
    for region in keys(var.regions) : [
      for action_group_key, action_group_details in var.monitor_action_group : merge(
        {
          short_name       = substr(var.TARGET_SUBSCRIPTION_ID, 0, 3)
          region           = region
          name_suffix      = lower("${action_group_key}-${region}")
          action_group_key = action_group_key
        },
        action_group_details
      )
    ]
  ])

  monitor_action_group_map = {
    for object in local.monitor_action_group_object_list :
    "${object.action_group_key}-${object.region}" => object
  }

}
