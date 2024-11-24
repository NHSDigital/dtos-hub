/*--------------------------------------------------------------------------------------------------
  Application Gateway Public DNS A Records
--------------------------------------------------------------------------------------------------*/

module "appgw-dns-a-records" {
  # No region loop since DNS is global. Traffic Manager will be required if an additional region is added.
  source = "../../dtos-devops-templates/infrastructure/modules/dns-a-record"

  name                = "api"
  resource_group_name = var.dns_zone_rg_name_public
  zone_name           = var.dns_zone_name_public
  ttl                 = 300
  target_resource_id  = module.application-gateway-pip.id

  tags = var.tags
}
