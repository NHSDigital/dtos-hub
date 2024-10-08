resource "azurerm_resource_group" "rg_base" {
  for_each = var.regions

  name     = "${module.config[each.key].names.resource-group}-${var.application}"
  location = each.key
}

# Get the primary region from the regions map:
locals {
  primary_region = {
    for region_key, region in var.regions :
  region_key => region if region.is_primary_region }
}
