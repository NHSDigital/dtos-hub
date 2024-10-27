resource "azurerm_resource_group" "rg_base" {
  for_each = var.regions

  name     = "${module.config[each.key].names.resource-group}"
  location = each.key
}

resource "azurerm_resource_group" "rg_project" {
  # create a resource group for every project for every region:
  for_each = local.projects_map

  name     = "${module.config[each.key].names.resource-group}-${each.value.short_name}"
  location = each.value.region_key
  tags     = length(each.value.tags) > 0 ? each.value.tags : var.tags
}

locals {
  # Create a map of regions to projects:
  regions_to_projects = {
    for project in var.projects :
    project.name => project.regions
  }
}

# Get the primary region from the regions map:
locals {
  projects_flatlist = flatten([
    for region_key, region_val in var.regions : [
      for project_key, project_val in var.projects : {
        key                          = "${project_key}-${region_key}"
        region_key                    = region_key
        project_key                   = project_key
        full_name = project_val.full_name
        short_name = project_val.short_name
        tags = project_val.tags
      }
    ]
  ])

  # Project the above list into a map with unique keys for consumption in a for_each meta argument
  projects_map = { for project in local.projects_flatlist : project.key => project }
}
