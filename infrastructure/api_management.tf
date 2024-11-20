module "api-management" {
  for_each = var.regions

  source = "../../dtos-devops-templates/infrastructure/modules/api-management"

  name                          = module.config[each.key].names.api-management
  resource_group_name           = azurerm_resource_group.rg_hub[each.key].name
  location                      = each.key
  certificate_details           = []
  gateway_disabled              = var.apim_config.gateway_disabled
  public_ip_address_id          = length(var.apim_config.zones) > 0 ? module.apim-public-ip[each.key].id : null
  publisher_email               = var.apim_config.publisher_email
  publisher_name                = var.apim_config.publisher_name
  sku_capacity                  = var.apim_config.sku_capacity
  sku_name                      = var.apim_config.sku_name
  virtual_network_type          = var.apim_config.virtual_network_type
  virtual_network_configuration = [module.subnets_hub["${module.config[each.key].names.subnet}-api-mgmt"].id]
  zones                         = var.apim_config.zones

  /*________________________________
| API Management AAD Integration |
__________________________________*/
  client_id       = data.azurerm_key_vault_secret.object-id[each.key].value
  client_secret   = data.azurerm_key_vault_secret.secret[each.key].value
  allowed_tenants = [data.azurerm_client_config.current.tenant_id]

  tags = var.tags

}

/*________________________________
| API Management Public IP Address |
__________________________________*/

module "apim-public-ip" {
  for_each = length(var.apim_config.zones) > 0 ? var.regions  : {}

  source = "../../dtos-devops-templates/infrastructure/modules/public-ip"

  name                = "${module.config[each.key].names.public-ip-address}-api-mgmt"
  resource_group_name = azurerm_resource_group.rg_hub[each.key].name
  location            = each.key
  allocation_method   = var.apim_config.public_ip_allocation_method
  domain_name_label   = module.config[each.key].names.api-management
  sku                 = var.apim_config.public_ip_sku
  zones               = var.apim_config.zones

  tags = var.tags
}


/*______________________________________
| API Management Private DNS A Records |
______________________________________*/

module "apim-private-dns-a-records" {
  for_each = local.custom_domains_map


  source = "../../dtos-devops-templates/infrastructure/modules/private-dns-a-record"

  name                = each.value.name
  resource_group_name = "${module.config[each.value.region].names.resource-group}-private-dns-zones"
  private_dns_a_record = {
    zone_name    = module.private_dns_zone_private_nationalscreening_nhs_uk[each.value.region].name
    a_record_ttl = each.value.ttl
    ip_address   = module.api-management[each.value.region].private_ip_address
  }

  tags = var.tags
}


locals {

  custom_domains = flatten([
    for region_key in var.regions : [
      for domain_obj in var.apim_config.custom_domains : [
        for type, value in domain_obj : {
          region = region_key
          type   = type
          name   = value.name
          ttl    = value.a_record_ttl
        }
      ]
    ]
  ])
  custom_domains_map = { for domain in local.custom_domains : "${domain.region}-${domain.type}" => domain
  }
}
