module "api-management" {
  for_each = var.regions

  source = "../../dtos-devops-templates/infrastructure/modules/api-management"

  name                          = module.config[each.key].names.api-management
  resource_group_name           = azurerm_resource_group.rg_hub[each.key].name
  location                      = each.key
  certificate_details           = []
  gateway_disabled              = var.apim_config.gateway_disabled
  public_ip_address_id          = length(var.apim_config.zones) > 0 ? module.apim-public-ip[each.key].id : null
  publisher_email               = var.apim_config.publisher_email
  publisher_name                = var.apim_config.publisher_name
  sku_capacity                  = var.apim_config.sku_capacity
  sku_name                      = var.apim_config.sku_name
  virtual_network_type          = var.apim_config.virtual_network_type
  virtual_network_configuration = [module.subnets_hub["${module.config[each.key].names.subnet}-api-mgmt"].id]
  zones                         = var.apim_config.zones

  log_analytics_workspace_id                   = module.log_analytics_workspace_hub[local.primary_region].id
  monitor_diagnostic_setting_apim_enabled_logs = local.monitor_diagnostic_setting_apim_enabled_logs
  monitor_diagnostic_setting_apim_metrics      = local.monitor_diagnostic_setting_apim_metrics
  metric_enabled                               = var.diagnostic_settings.metric_enabled

  custom_domains_developer_portal = [
    {
      host_name    = "portal.${var.dns_zone_name_private.nationalscreening}"
      key_vault_id = module.acme_certificate["nationalscreening_wildcard_private"].key_vault_certificate[each.key].versionless_secret_id
    }
  ]

  custom_domains_management = [
    {
      host_name    = "management.${var.dns_zone_name_private.nationalscreening}"
      key_vault_id = module.acme_certificate["nationalscreening_wildcard_private"].key_vault_certificate[each.key].versionless_secret_id
    }
  ]

  custom_domains_gateway = [
    {
      host_name           = "gateway.${var.dns_zone_name_private.nationalscreening}"
      key_vault_id        = module.acme_certificate["nationalscreening_wildcard_private"].key_vault_certificate[each.key].versionless_secret_id
      default_ssl_binding = true
    },
    {
      host_name    = "api.${var.dns_zone_name_private.nationalscreening}"
      key_vault_id = module.acme_certificate["nationalscreening_wildcard_private"].key_vault_certificate[each.key].versionless_secret_id
      # Technically there should only be a single default binding, however the 'gateway' and private 'api' bindings share the same wildcard certificate.
      # Configure both as defaults to match how Azure Portal will always report it, preventing Terraform reporting a change on every plan.
      default_ssl_binding = true
    },
    {
      host_name    = "api.${var.dns_zone_name_public.nationalscreening}"
      key_vault_id = module.acme_certificate["nationalscreening_wildcard"].key_vault_certificate[each.key].versionless_secret_id
    }
  ]

  custom_domains_scm = [
    {
      host_name    = "scm.${var.dns_zone_name_private.nationalscreening}"
      key_vault_id = module.acme_certificate["nationalscreening_wildcard_private"].key_vault_certificate[each.key].versionless_secret_id
    }
  ]

/* --------------------------------------------------------------------------------------------------
  API Management Portal Settings
-------------------------------------------------------------------------------------------------- */

  sign_in_enabled = var.apim_config.sign_in_enabled
  sign_up_enabled = var.apim_config.sign_up_enabled

/* --------------------------------------------------------------------------------------------------
  API Management Entra ID Integration
-------------------------------------------------------------------------------------------------- */

  client_id       = data.azurerm_key_vault_secret.object-id[each.key].value
  client_secret   = data.azurerm_key_vault_secret.secret[each.key].value
  allowed_tenants = [data.azurerm_client_config.current.tenant_id]

  tags = var.tags
}


module "apim-public-ip" {
  for_each = length(var.apim_config.zones) > 0 ? var.regions : {}

  source = "../../dtos-devops-templates/infrastructure/modules/public-ip"

  name                = "${module.config[each.key].names.public-ip-address}-api-mgmt"
  resource_group_name = azurerm_resource_group.rg_hub[each.key].name
  location            = each.key
  allocation_method   = var.apim_config.public_ip_allocation_method
  domain_name_label   = module.config[each.key].names.api-management
  sku                 = var.apim_config.public_ip_sku
  zones               = var.apim_config.zones

  tags = var.tags
}
