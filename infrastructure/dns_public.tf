/*--------------------------------------------------------------------------------------------------
  Application Gateway Public DNS A Records
--------------------------------------------------------------------------------------------------*/

locals {
  appgw_public_listener_hostnames = ["api"]
}

module "appgw-dns-a-records" {
  for_each = toset(local.appgw_public_listener_hostnames)

  # No region loop since DNS is global. Traffic Manager will be required if an additional region is added.
  source = "../../dtos-devops-templates/infrastructure/modules/dns-a-record"

  name                = each.key
  resource_group_name = var.dns_zone_rg_name_public
  zone_name           = var.dns_zone_name_public
  ttl                 = 300
  target_resource_id  = module.application-gateway-pip[local.primary_region].id

  tags = var.tags
}
