# Output the hub virtual network so it can be used in a remote_state lookup by the spoke networks
output "vnets_hub" {
  value = module.vnets_hub
}

# Output the DNS resolver inbound private ip addresses so they can be used in the private endpoint modules
output "private_dns_resolver_inbound_ips" {
  value = module.private_dns_resolver
}

# Output the private DNS zone IDs so they can be used in private endpoint modules
output "private_dns_zone_acr" {
  value = module.private_dns_zone_acr
}

output "private_dns_zone_app_insight" {
  value = module.private_dns_zone_app_insight
}

output "private_dns_zone_api_management" {
  value = module.private_dns_zone_api_management
}

output "private_dns_zone_app_services" {
  value = module.private_dns_zone_app_services
}

output "private_dns_zone_azure_sql" {
  value = module.private_dns_zone_azure_sql
}

output "private_dns_zone_key_vault" {
  value = module.private_dns_zone_key_vault
}

output "private_dns_zone_storage_blob" {
  value = module.private_dns_zone_storage_blob
}

output "private_dns_zone_storage_queue" {
  value = module.private_dns_zone_storage_queue
}

output "firewall_private_ip_address" {
  value = {
    for region_key, region_val in module.firewall.ip_configuration[0].private_ip_address :
    region_key => region_val
  }
}
