module "frontdoor_profile" {
  for_each = { for k, v in var.projects : k => v if contains(keys(v), "frontdoor_profile") && v.frontdoor_profile != null }

  source = "../../dtos-devops-templates/infrastructure/modules/cdn-frontdoor-profile"

  name                = module.config[local.primary_region].names.front-door-profile
  resource_group_name = azurerm_resource_group.rg_hub[local.primary_region].name
  sku_name            = each.value.frontdoor_profile.sku_name

  tags = var.tags
}
