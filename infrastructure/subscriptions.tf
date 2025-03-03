data "azurerm_subscription" "subscriptions" {
  for_each = var.subscriptions

  name = each.value.full_name
}

#To bring the output of each subscription_name in the /home/fahadbaig/git_repos/nhsapp-dtos/dtos-hub/infrastructure/environments/development.tfvars under the name: subscription_name{
#   development = "Digital Screening DToS - Core Services Dev"
#   nft = "Digital Screening DToS - Core Services NFT"
#   integration = "Digital Screening DToS - Core Services Int"
# }
# output "current_subscription_display_name" {
#   value = data.azurerm_subscription.subscription_name.id
# }

/* --------------------------------------------------------------------------------------------------
  Diagnostic Settings
-------------------------------------------------------------------------------------------------- */

module "diagnostic-settings" {
  source                     = "../../dtos-devops-templates/infrastructure/modules/diagnostic-settings"
  for_each                   = var.subscriptions
  name                       = "${each.key}-diagnostic-setting"
  target_resource_id         = data.azurerm_subscription.subscriptions[each.key].id
  log_analytics_workspace_id = module.log_analytics_workspace_hub[local.primary_region].id
  enabled_log                = local.monitor_diagnostic_setting_subscriptions_enabled_logs
}
