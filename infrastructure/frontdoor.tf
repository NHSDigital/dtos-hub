locals {
  frontdoor_profiles = {
    for k, v in var.projects : k => v if contains(keys(v), "frontdoor_profile") && v.frontdoor_profile != null
  }
}

module "frontdoor_profile" {
  for_each = local.frontdoor_profiles

  source = "../../dtos-devops-templates/infrastructure/modules/cdn-frontdoor-profile"

  log_analytics_workspace_id                        = module.log_analytics_workspace_hub[local.primary_region].id
  monitor_diagnostic_setting_frontdoor_enabled_logs = local.monitor_diagnostic_setting_frontdoor_enabled_logs
  monitor_diagnostic_setting_frontdoor_metrics      = local.monitor_diagnostic_setting_frontdoor_metrics
  metric_enabled                                    = var.diagnostic_settings.metric_enabled

  # Front Door Profile is a global resource, hence the use of primary_region Key Vault
  certificate_secrets = { for k in each.value.frontdoor_profile.secrets : k => module.acme_certificate[k].key_vault_certificate[local.primary_region].versionless_id }
  name                = "${module.config[local.primary_region].names.front-door-profile}-${each.value.short_name}"
  resource_group_name = azurerm_resource_group.rg_project["${each.key}-${local.primary_region}"].name
  sku_name            = each.value.frontdoor_profile.sku_name

  identity = each.value.frontdoor_profile.identity

  tags = var.tags
}
