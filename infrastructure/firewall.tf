module "firewall" {
  for_each = var.regions

  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/firewall?ref=36101b5776ad52fb0909a6e17fd3fb9b6c6db540"

  firewall_name       = "${module.config[each.key].names.firewall}-${var.application}"
  resource_group_name = azurerm_resource_group.rg_hub[each.key].name
  location            = each.key

  sku_name = var.firewall_config.firewall_sku_name
  sku_tier = var.firewall_config.firewall_sku_tier
  zones    = var.firewall_config.zones

  ip_configuration = [
    for public_ip in module.public_ip : {
      name                 = public_ip.name
      public_ip_address_id = public_ip.id
      firewall_subnet_id   = module.subnets_hub["AzureFirewallSubnet-${each.key}"].id
    }
  ]

  tags = var.tags

  ### policy variables
  policy_name              = "${module.config[each.key].names.firewall}-${var.application}-policy"
  sku                      = var.firewall_config.policy_sku
  threat_intelligence_mode = var.firewall_config.policy_threat_intelligence_mode
  dns_proxy_enabled        = var.firewall_config.policy_dns_proxy_enabled
  dns_servers              = [module.private_dns_resolver[each.key].private_dns_resolver_ip]

}

module "public_ip" {
  for_each = local.public_ips_map

  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/public-ip?ref=36101b5776ad52fb0909a6e17fd3fb9b6c6db540"

  name                = "${module.config[each.value.region_key].names.public-ip-address}-${each.value.name_suffix}"
  resource_group_name = azurerm_resource_group.rg_hub[each.value.region_key].name
  location            = each.value.region_key

  allocation_method    = each.value.allocation_method
  ddos_protection_mode = each.value.ddos_protection_mode
  sku                  = each.value.sku
  zones                = each.value.zones
}

locals {
  # Create a map of the Public IP addresses to add to the firewall
  public_ips_flatlist = flatten([
    for region_key, region_val in var.regions : [
      for public_ip_key, public_ip_val in var.firewall_config.public_ip_addresses : {
        key_name = "${public_ip_key}-${region_key}"
        region_key = region_key
        name_suffix = public_ip_val.name_suffix
        allocation_method = public_ip_val.allocation_method
        ddos_protection_mode = public_ip_val.ddos_protection_mode
        sku = public_ip_val.sku
        zones = var.firewall_config.zones
      }
    ]
  ])

  public_ips_map = { for public_ip in local.public_ips_flatlist : public_ip.key_name => public_ip }
}

output "public_ips_map" {
  value = local.public_ips_map
}
