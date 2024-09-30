locals {
  devops_subnet_id = {
    uksouth = var.SUBNET_ID_UKSOUTH
    ukwest  = var.SUBNET_ID_UKWEST
  }
}

module "managed_devops_pool" {
  for_each = var.regions

  source = "github.com/Azure/terraform-azurerm-avm-res-devopsinfrastructure-pool"

  resource_group_name                         = azurerm_resource_group.dev_center_rg[each.key].name
  location                                    = each.key
  name                                        = module.config[each.key].names.managed-devops-pool
  dev_center_project_resource_id              = azapi_resource.dev_center_project[each.key].id
  version_control_system_organization_name    = var.version_control_system_organization_name
  version_control_system_project_names        = var.version_control_system_project_names
  agent_profile_kind                          = var.agent_profile_kind
  agent_profile_max_agent_lifetime            = var.agent_profile_max_agent_lifetime
  agent_profile_resource_prediction_profile   = var.agent_profile_resource_prediction_profile
  agent_profile_resource_predictions_manual   = var.agent_profile_resource_predictions_manual
  enable_telemetry                            = false # sends telemetry data to Microsoft
  fabric_profile_images                       = var.fabric_profile_images
  fabric_profile_os_disk_storage_account_type = var.fabric_profile_os_disk_storage_account_type
  fabric_profile_sku_name                     = var.fabric_profile_sku_name
  maximum_concurrency                         = var.maximum_concurrency
  subnet_id                                   = local.devops_subnet_id[each.key]
}
