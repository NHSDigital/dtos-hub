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

  developer_portal_hostname_configuration = [
    for key, domain in local.custom_domains_map : {
      host_name    = "${domain.name}.${var.dns_zone_name_private}"
      key_vault_id = module.lets_encrypt_certificate.key_vault_certificates["wildcard_private-${domain.region}"].versionless_secret_id
    }
    if domain.type == "development"
  ]
  management_hostname_configuration = [
    for key, domain in local.custom_domains_map : {
      host_name    = "${domain.name}.${var.dns_zone_name_private}"
      key_vault_id = module.lets_encrypt_certificate.key_vault_certificates["wildcard_private-${domain.region}"].versionless_secret_id
    }
    if domain.type == "management"
  ]
  proxy_hostname_configuration = [
    for key, domain in local.custom_domains_map : {
      host_name           = domain.type == "gateway_external" ? "${domain.name}.${var.dns_zone_name_public}" : "${domain.name}.${var.dns_zone_name_private}"
      key_vault_id        = domain.type == "gateway_external" ? module.lets_encrypt_certificate.key_vault_certificates["wildcard-${domain.region}"].versionless_secret_id : module.lets_encrypt_certificate.key_vault_certificates["wildcard_private-${domain.region}"].versionless_secret_id
      default_ssl_binding = domain.default_ssl_binding
    }
    if domain.type == "gateway" || domain.type == "gateway_internal" || domain.type == "gateway_external"
  ]
  scm_hostname_configuration = [
    for key, domain in local.custom_domains_map : {
      host_name    = "${domain.name}.${var.dns_zone_name_private}"
      key_vault_id = module.lets_encrypt_certificate.key_vault_certificates["wildcard_private-${domain.region}"].versionless_secret_id
    }
    if domain.type == "scm"
  ]

  /*________________________________
| API Management Portal Settings |
__________________________________*/

  sign_in_enabled = var.apim_config.sign_in_enabled

  sign_up_enabled = var.apim_config.sign_up_enabled

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
  for_each = length(var.apim_config.zones) > 0 ? var.regions : {}

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
    for region_key in keys(var.regions) : [
      for type, value in var.apim_config.custom_domains : {
        region              = region_key
        type                = type
        name                = value.name
        ttl                 = value.a_record_ttl
        default_ssl_binding = lookup(value, "default_ssl_binding", null)
      }
    ]
  ])
  custom_domains_map = { for domain in local.custom_domains : "${domain.region}-${domain.type}" => domain
  }
}
