resource "azurerm_resource_group" "rg_hub" {
  for_each = var.regions

  name     = "${module.config[each.key].names.resource-group}-${var.application}-networking"
  location = each.key
}

resource "azurerm_resource_group" "rg_private_endpoints" {
  for_each = var.features.private_endpoints_enabled ? var.regions : {}

  name     = "${module.config[each.key].names.resource-group}-${var.application}-private-endpoints"
  location = each.key
}

module "vnets_hub" {
  for_each = var.regions

  source = "../../dtos-devops-templates/infrastructure/modules/vnet"

  log_analytics_workspace_id                   = module.log_analytics_workspace_hub[local.primary_region].id
  monitor_diagnostic_setting_vnet_enabled_logs = local.monitor_diagnostic_setting_vnet_hub_enabled_logs
  monitor_diagnostic_setting_vnet_metrics      = local.monitor_diagnostic_setting_vnet_hub_metrics

  name                = module.config[each.key].names.virtual-network
  resource_group_name = azurerm_resource_group.rg_hub[each.key].name
  location            = each.key
  vnet_address_space  = each.value.address_space

  tags = var.tags
}


locals {
  # Expand a flattened list of objects for all subnets (allows nested for loops)
  subnets_flatlist = flatten([
    for key, val in var.regions : [
      for subnet_key, subnet in val.subnets : merge({
        vnet_key = key
        # Ensure we have a region-dependent key even for subnets with user-specific names
        subnet_name_region_key = coalesce(
          subnet.name != null ? "${subnet.name}-${key}" : null, "${module.config[key].names.subnet}-${subnet_key}"
        )
        subnet_name      = coalesce(subnet.name, "${module.config[key].names.subnet}-${subnet_key}")
        nsg_name         = "${module.config[key].names.network-security-group}-${subnet_key}"
        nsg_rules        = lookup(var.network_security_group_rules, subnet_key, [])
        address_prefixes = cidrsubnet(val.address_space, subnet.cidr_newbits, subnet.cidr_offset)
      }, subnet) # include all the declared key/value pairs for a specific subnet
    ]
  ])
  # Project the above list into a map with unique keys for consumption in a for_each meta argument
  subnets_map = { for subnet in local.subnets_flatlist : subnet.subnet_name_region_key => subnet }
}

module "subnets_hub" {
  for_each = local.subnets_map

  source = "../../dtos-devops-templates/infrastructure/modules/subnet"

  log_analytics_workspace_id                                     = module.log_analytics_workspace_hub[local.primary_region].id
  monitor_diagnostic_setting_network_security_group_enabled_logs = local.monitor_diagnostic_setting_network_security_group_enabled_logs

  name                              = each.value.subnet_name
  location                          = module.vnets_hub[each.value.vnet_key].vnet.location
  network_security_group_name       = each.value.nsg_name
  network_security_group_nsg_rules  = each.value.nsg_rules
  create_nsg                        = coalesce(each.value.create_nsg, true)
  resource_group_name               = module.vnets_hub[each.value.vnet_key].vnet.resource_group_name
  vnet_name                         = module.vnets_hub[each.value.vnet_key].name
  address_prefixes                  = [each.value.address_prefixes]
  default_outbound_access_enabled   = true
  private_endpoint_network_policies = "Disabled" # Default as per compliance requirements
  delegation_name                   = each.value.delegation_name != null ? each.value.delegation_name : ""
  service_delegation_name           = each.value.service_delegation_name != null ? each.value.service_delegation_name : ""
  service_delegation_actions        = each.value.service_delegation_actions != null ? each.value.service_delegation_actions : []

  tags = var.tags
}


# Needed for Managed DevOps Pool
data "azuread_service_principal" "devops_infrastructure" {
  display_name = "DevOpsInfrastructure"
}

resource "azurerm_role_assignment" "devops" {
  for_each = var.regions

  scope                = module.vnets_hub[each.key].vnet.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azuread_service_principal.devops_infrastructure.id
}

resource "azurerm_role_assignment" "devops_reader" {
  for_each = var.regions

  scope                = module.vnets_hub[each.key].vnet.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_service_principal.devops_infrastructure.id
}
