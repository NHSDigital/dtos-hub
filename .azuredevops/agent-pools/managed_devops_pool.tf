module "managed_devops_pool" {
  for_each = var.regions

  source = "github.com/Azure/terraform-azurerm-avm-res-devopsinfrastructure-pool"

  resource_group_name                         = azurerm_resource_group.dev_center_rg[each.key].name
  location                                    = each.key
  name                                        = module.config[each.key].names.managed-devops-pool
  dev_center_project_resource_id              = azurerm_dev_center_project.this[each.key].id
  agent_profile_kind                          = var.agent_profile_kind
  agent_profile_max_agent_lifetime            = var.agent_profile_max_agent_lifetime
  agent_profile_resource_prediction_profile   = var.agent_profile_resource_prediction_profile
  agent_profile_resource_predictions_manual   = var.agent_profile_resource_predictions_manual
  enable_telemetry                            = false # sends telemetry data to Microsoft
  fabric_profile_images                       = var.fabric_profile_images
  fabric_profile_os_disk_storage_account_type = var.fabric_profile_os_disk_storage_account_type
  fabric_profile_sku_name                     = var.fabric_profile_sku_name
  maximum_concurrency                         = var.maximum_concurrency
  subnet_id                                   = data.terraform_remote_state.hub.outputs.subnets_hub["${module.config[each.key].names.subnet}-devops"].id
  version_control_system_organization_name    = var.version_control_system_organization_name
  version_control_system_project_names        = var.version_control_system_project_names
}
