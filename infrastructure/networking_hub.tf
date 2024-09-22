resource "azurerm_resource_group" "hub_rg" {
  for_each = var.regions

  name     = "${module.config[each.key].names.resource-group}-networking"
  location = each.key
}

module "vnets_hub" {
  for_each = var.regions

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/vnet?ref=feat/DTOSS-4393-Terraform-Modules"

  name                = module.config[each.key].names.virtual-network
  resource_group_name = azurerm_resource_group.hub_rg[each.key].name
  location            = each.key
  vnet_address_space  = each.value.address_space

  tags = var.tags
}

module "hub-subnets" {
  for_each = local.subnets

  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/subnet?ref=feat/DTOSS-4393-Terraform-Modules"

  name                              = each.value.subnet_name
  location                          = module.vnets_hub[each.value.vnet_key].vnet.location
  network_security_group_name       = each.value.nsg_name
  network_security_group_nsg_rules  = each.value.nsg_rules
  resource_group_name               = module.vnets_hub[each.value.vnet_key].vnet.resource_group_name
  vnet_name                         = module.vnets_hub[each.value.vnet_key].name
  address_prefixes                  = [each.value.address_prefixes]
  default_outbound_access_enabled   = true
  private_endpoint_network_policies = "Disabled" # Default as per compliance requirements

  tags = var.tags
}

# Create flattened map of VNets and their subnets to use in the Subnets module above
locals {
  subnets_flatlist = flatten([for key, val in var.regions : [
    for subnet_key, subnet in val.subnets : {
      vnet_key         = key
      subnet_name      = "${module.config[key].names.subnet}-${subnet_key}"
      nsg_name         = "${module.config[key].names.network-security-group}-${subnet_key}"
      nsg_rules        = var.network_security_group_rules[subnet_key]
      address_prefixes = cidrsubnet(val.address_space, subnet.cidr_newbits, subnet.cidr_offset)
    }
    ]
  ])

  subnets = { for subnet in local.subnets_flatlist : subnet.subnet_name => subnet }
}

output "subnets" {
  value = local.subnets
}
