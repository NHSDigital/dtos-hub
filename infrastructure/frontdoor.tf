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

# module "frontdoor_profile_hub" {
#   source = "../../dtos-devops-templates/infrastructure/modules/cdn-frontdoor-profile"

#   log_analytics_workspace_id                        = module.log_analytics_workspace_hub[local.primary_region].id
#   monitor_diagnostic_setting_frontdoor_enabled_logs = local.monitor_diagnostic_setting_frontdoor_enabled_logs
#   monitor_diagnostic_setting_frontdoor_metrics      = local.monitor_diagnostic_setting_frontdoor_metrics
#   metric_enabled                                    = var.diagnostic_settings.metric_enabled

#   name                = module.config[local.primary_region].names.front-door-profile
#   resource_group_name = azurerm_resource_group.rg_hub[local.primary_region].name
#   sku_name            = "Premium_AzureFrontDoor"

#   tags = var.tags
# }

# module "frontdoor_endpoint_apim" {
#   source = "../../dtos-devops-templates/infrastructure/modules/cdn-frontdoor-endpoint"

#   providers = {
#     azurerm     = azurerm
#     azurerm.dns = azurerm
#   }

#   cdn_frontdoor_profile_id = module.frontdoor_profile_hub.id
#   custom_domains = {
#     "apim-gateway" = {
#       host_name        = "api.${var.dns_zone_name_public.screening}"
#       dns_zone_name    = var.dns_zone_name_public.screening
#       dns_zone_rg_name = var.dns_zone_rg_name_public
#     }
#   }
#   name = "${var.env_type}-apim-gateway"
#   origin_group = {
#     session_affinity_enabled = false
#   }
#   origins = {
#     "${var.env_type}-${module.config[local.primary_region].names.location_code}-apim" = {
#       hostname           = "${module.api-management[local.primary_region].name}.azure-api.net"
#       origin_host_header = "${module.api-management[local.primary_region].name}.azure-api.net"
#       private_link = var.features.private_endpoints_enabled ? {
#         target_type            = "Gateway"
#         location               = local.primary_region
#         private_link_target_id = module.api-management[local.primary_region].id
#       } : null
#     }
#   }
#   security_policies = {
#     "Ingress" = {
#       cdn_frontdoor_firewall_policy_name    = "wafhub${var.env_type}apimgateway"
#       cdn_frontdoor_firewall_policy_rg_name = azurerm_resource_group.rg_hub[local.primary_region].name
#       associated_domain_keys                = ["apim-gateway"] # From custom_domains above. Use "endpoint" for the default domain (if linked in Front Door route).
#     }
#   }

#   tags = var.tags
# }
