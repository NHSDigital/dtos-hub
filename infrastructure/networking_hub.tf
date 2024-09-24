resource "azurerm_resource_group" "rg_hub" {
  for_each = var.regions

  name     = "${module.config[each.key].names.resource-group}-${var.application}-networking"
  location = each.key
}

module "vnets_hub" {
  for_each = var.regions

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/vnet?ref=2296f761f4edc3b413e2629c98309df9c6fa0849"

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
        vnet_key                   = key
        subnet_name                = coalesce(subnet.name, "${module.config[key].names.subnet}-${subnet_key}")
        nsg_name                   = "${module.config[key].names.network-security-group}-${subnet_key}"
        nsg_rules                  = lookup(var.network_security_group_rules, subnet_key, [])
        address_prefixes           = cidrsubnet(val.address_space, subnet.cidr_newbits, subnet.cidr_offset)
      }, subnet) # include all the declared key/value pairs for a specific subnet
    ]
  ])
  # Project the above list into a map with unique keys for consumption in a for_each meta argument
  subnets_map = { for subnet in local.subnets_flatlist : subnet.subnet_name => subnet }
}

module "subnets_hub" {
  for_each = local.subnets_map

  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/subnet?ref=2fa836b230acff25c8626697fdf0e23cb598ca39"

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
