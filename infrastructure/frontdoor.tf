locals {
  frontdoor_profiles = {
    for k, v in var.projects : k => v if contains(keys(v), "frontdoor_profile") && v.frontdoor_profile != null
  }
}

module "frontdoor_profile" {
  for_each = local.frontdoor_profiles

  source = "../../dtos-devops-templates/infrastructure/modules/cdn-frontdoor-profile"

  # Front Door Profile is a global resource
  name                = "${module.config[local.primary_region].names.front-door-profile}-${each.value.short_name}"
  resource_group_name = azurerm_resource_group.rg_project["${each.key}-${local.primary_region}"].name
  sku_name            = each.value.frontdoor_profile.sku_name

  identity = each.value.frontdoor_profile.identity

  tags = var.tags
}

resource "azurerm_cdn_frontdoor_secret" "screening_wildcard" {
  for_each = local.frontdoor_profiles

  name                     = "pamo16test6"
  cdn_frontdoor_profile_id = module.frontdoor_profile[each.key].id

  secret {
    customer_certificate {
      key_vault_certificate_id = module.acme_certificate["pamo16test6"].key_vault_certificate[local.primary_region].versionless_id
    }
  }

  depends_on = [azurerm_key_vault_access_policy.frontdoor]
}
