module "key_vault" {
  # This Key Vault is used to store the SSL certificates for Application Gateway and APIM

  for_each = var.regions

  source = "../../dtos-devops-templates/infrastructure/modules/key-vault"

  name                = module.config[each.key].names.key-vault
  resource_group_name = azurerm_resource_group.rg_base[each.key].name
  location            = each.key

  log_analytics_workspace_id                       = module.log_analytics_workspace_hub[local.primary_region].id
  monitor_diagnostic_setting_keyvault_enabled_logs = local.monitor_diagnostic_setting_keyvault_enabled_logs
  monitor_diagnostic_setting_keyvault_metrics      = local.monitor_diagnostic_setting_keyvault_metrics
  metric_enabled                                   = var.diagnostic_settings.metric_enabled

  disk_encryption          = var.key_vault.disk_encryption
  soft_delete_retention    = var.key_vault.soft_del_ret_days
  purge_protection_enabled = var.key_vault.purge_prot
  sku_name                 = var.key_vault.sku_name

  # Application Gateway cannot use RBAC auth for Key Vault, unless by PowerShell. An Azure Policy exemption will be needed when this is forbidden by NHS
  # https://learn.microsoft.com/azure/application-gateway/key-vault-certs?WT.mc_id=Portal-Microsoft_Azure_HybridNetworking#key-vault-azure-role-based-access-control-permission-model

  # enable_rbac_authorization = true

  # Private Endpoint Configuration if enabled
  private_endpoint_properties = var.features.private_endpoints_enabled ? {
    private_dns_zone_ids_keyvault        = [module.private_dns_zones["${each.key}-key_vault"].id]
    private_endpoint_enabled             = var.features.private_endpoints_enabled
    private_endpoint_subnet_id           = module.subnets_hub["${module.config[each.key].names.subnet}-pep"].id
    private_endpoint_resource_group_name = azurerm_resource_group.rg_private_endpoints[each.key].name
    private_service_connection_is_manual = var.features.private_service_connection_is_manual
  } : null

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "terraform-mi" {
  for_each = var.regions

  key_vault_id = module.key_vault[each.key].key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "GetRotationPolicy",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Update"
  ]

  secret_permissions = [
    "Delete",
    "Get",
    "List",
    "Purge",
    "Set"
  ]

  certificate_permissions = [
    "Create",
    "Delete",
    "Get",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Update"
  ]
}

resource "azurerm_key_vault_access_policy" "apim" {
  for_each = var.regions

  key_vault_id = module.key_vault[each.key].key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = module.api-management[each.key].system_assigned_identity

  key_permissions = [
    "Get",
    "List"
  ]

  secret_permissions = [
    "Get",
    "List"
  ]

  certificate_permissions = [
    "Get",
    "List"
  ]
}

# For App Services Custom Domain certificate bindings - once only, hence in Hub state
resource "azurerm_key_vault_access_policy" "MicrosoftAzureAppService" {
  for_each = var.regions

  key_vault_id = module.key_vault[each.key].key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_service_principal.MicrosoftAzureAppService.object_id

  secret_permissions = [
    "Get"
  ]

  certificate_permissions = [
    "Get"
  ]
}

resource "azurerm_key_vault_access_policy" "frontdoor" {
  for_each = var.regions

  key_vault_id = module.key_vault[each.key].key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_service_principal.MicrosoftAzureFrontDoorCdn.object_id

  secret_permissions = [
    "Get",
  ]

  certificate_permissions = [
    "Get",
  ]
}
