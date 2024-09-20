resource "azurerm_resource_group" "hub_rg" {
  for_each = var.regions

  name     = "${module.config[each.key].names.resource-group}-networking"
  location = each.key
}

module "hub_networking" {
  for_each = var.regions

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/vnet?ref=feat/DTOSS-4393-Terraform-Modules"

  name                = module.config[each.key].names.virtual-network
  resource_group_name = azurerm_resource_group.hub_rg[each.key].name
  location            = each.key
  vnet_address_space  = each.value.address_space

  tags = var.tags
}

# resource "azurerm_subnet" "subnets" {
#   for_each             = local.subnets

#   name                 = each.value.subnet_name
#   resource_group_name  = module.hub_networking[each.value.vnet_key].vnet.resource_group_name
#   virtual_network_name = module.hub_networking[each.value.vnet_key].name
#   address_prefixes     = [cidrsubnet(module.hub_networking[each.value.vnet_key].vnet.address_space, each.value.cidr_newbits, each.value.cidr_offset)]
# }

# Create flattened map of VNets and their subnets
locals {
  subnets_flatlist = flatten([for key, val in var.regions : [
    for subnet_key, subnet in val.subnets : {
      vnet_key    = key
      subnet_name = "${module.config[key].names.subnet}-${subnet_key}"
      address_prefixes = [cidrsubnet(module.hub_networking[key].vnet.address_space, subnet.cidr_newbits, subnet.cidr_offset)]
    }
    ]
  ])

  subnets = { for subnet in local.subnets_flatlist : subnet.subnet_name => subnet }
}

output "subnets" {
  value = local.subnets
}
