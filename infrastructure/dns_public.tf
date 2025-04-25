/*--------------------------------------------------------------------------------------------------
  Application Gateway Public DNS A Records
--------------------------------------------------------------------------------------------------*/

locals {
  appgw_public_listener_hostnames = [
    for listener in local.appgw_config[local.primary_region].http_listener :
    listener.host_name if listener.frontend_ip_configuration_key == "public"
  ]
}

module "appgw-dns-a-records" {
  # No region loop since public DNS is global. Traffic Manager will be required if an additional region is added.
  for_each = toset(local.appgw_public_listener_hostnames)

  source = "../../dtos-devops-templates/infrastructure/modules/dns-a-record"

  name                = split(".", each.key)[0]
  resource_group_name = var.dns_zone_rg_name_public
  zone_name           = replace(each.key, "${split(".", each.key)[0]}.", "")
  ttl                 = 300
  target_resource_id  = module.application-gateway-pip[local.primary_region].id

  tags = var.tags
}
