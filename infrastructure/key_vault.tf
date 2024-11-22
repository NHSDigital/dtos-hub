module "key_vault" {
  for_each = var.regions

  source = "../../dtos-devops-templates/infrastructure/modules/key-vault"

  name                = module.config[each.key].names.key-vault
  resource_group_name = azurerm_resource_group.rg_base[each.key].name
  location            = each.key

  log_analytics_workspace_id                       = module.log_analytics_workspace_hub[local.primary_region].id
  monitor_diagnostic_setting_keyvault_enabled_logs = local.monitor_diagnostic_setting_keyvault_enabled_logs
  monitor_diagnostic_setting_keyvault_metrics      = local.monitor_diagnostic_setting_keyvault_metrics

  disk_encryption          = var.key_vault.disk_encryption
  soft_delete_retention    = var.key_vault.soft_del_ret_days
  purge_protection_enabled = var.key_vault.purge_prot
  sku_name                 = var.key_vault.sku_name

  enable_rbac_authorization = true
  rbac_roles                = local.rbac_roles_key_vault

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
