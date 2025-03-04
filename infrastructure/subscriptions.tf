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
# locals {
#   subscription_ids = {
#     dev = "/subscriptions/${var.DEV_SUBSCRIPTION_ID}"
#     nft = "/subscriptions/${var.NFT_SUBSCRIPTION_ID}"
#     int = "/subscriptions/${var.INT_SUBSCRIPTION_ID}"
#   }
# }
locals {
  subscription_ids = {

    dev     = "/subscriptions/${var.SUBSCRIPTION_ID_DEV}"
    nft     = "/subscriptions/${var.SUBSCRIPTION_ID_NFT}"
    int     = "/subscriptions/${var.SUBSCRIPTION_ID_INT}"
    preprod = "/subscriptions/${var.SUBSCRIPTION_ID_PRE}"
    prod    = "/subscriptions/${var.SUBSCRIPTION_ID_PRD}"
  }

  alias_map = {
    dev = azurerm.dev
    nft = azurerm.nft
    int = azurerm.int
  }

}

module "diagnostic-settings" {
  source             = "../../dtos-devops-templates/infrastructure/modules/diagnostic-settings"
  for_each           = var.subscriptions
  name               = "${each.key}-diagnostic-setting"
  target_resource_id = local.subscription_ids[each.value.short_name]
  # target_resource_id         = data.azurerm_subscription.subscriptions[each.key].id
  log_analytics_workspace_id = module.log_analytics_workspace_hub[local.primary_region].id
  enabled_log                = local.monitor_diagnostic_setting_subscriptions_enabled_logs

  providers = {
    azurerm = lookup(local.alias_map, each.value.short_name, azurerm.dev)
  }
}
