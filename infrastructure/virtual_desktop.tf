resource "azurerm_resource_group" "avd" {
  for_each = var.regions

  name     = "${module.config[each.key].names.resource-group}-${var.application}-virtual-desktop"
  location = each.key
}

module "virtual-desktop" {
  for_each = var.regions

  source = "../../dtos-devops-templates/infrastructure/modules/virtual-desktop"

  custom_rdp_properties     = "drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;redirectwebauthn:i:1;use multimon:i:1;enablerdsaadauth:i:1;"
  computer_name_prefix      = "avd${var.env_type}"
  dag_name                  = module.config[each.key].names.avd-dag
  host_pool_name            = module.config[each.key].names.avd-host-pool
  location                  = each.key
  entra_users_group_id      = data.azuread_group.avd_users.id
  entra_admins_group_id     = data.azuread_group.avd_admins.id
  maximum_sessions_allowed  = var.avd_maximum_sessions_allowed
  resource_group_name       = azurerm_resource_group.avd[each.key].name
  resource_group_id         = azurerm_resource_group.avd[each.key].id
  scaling_plan_name         = module.config[each.key].names.avd-scaling-plan
  source_image_id           = var.AVD_SOURCE_IMAGE_ID
  source_image_reference    = var.avd_source_image_reference
  source_image_from_gallery = var.avd_source_image_from_gallery
  subnet_id                 = module.subnets_hub["${module.config[each.key].names.subnet}-virtual-desktop"].id
  vm_count                  = var.avd_vm_count
  vm_name_prefix            = module.config[each.key].names.avd-host
  vm_storage_account_type   = "StandardSSD_LRS"
  vm_size                   = var.avd_vm_size
  vm_license_type           = "Windows_Client"
  workspace_name            = module.config[each.key].names.avd-workspace

  tags = var.tags
}

module "route-table-virtual-desktop" {
  for_each = var.regions

  source = "../../dtos-devops-templates/infrastructure/modules/route-table"

  name                = "${module.config[each.key].names.route-table}-virtual-desktop"
  resource_group_name = azurerm_resource_group.rg_hub[each.key].name
  location            = each.key

  bgp_route_propagation_enabled = false

  routes = [
    {
      name           = "AVDSessionHostControl"
      address_prefix = "WindowsVirtualDesktop"
      next_hop_type  = "Internet"
    },
    {
      name           = "EntraAuthTraffic"
      address_prefix = "AzureActiveDirectory"
      next_hop_type  = "Internet"
    },
    {
      name                   = "EgressViaFirewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = module.firewall[each.key].private_ip_address
    }
  ]

  subnet_ids = [module.subnets_hub["${module.config[each.key].names.subnet}-virtual-desktop"].id]

  tags = var.tags
}
