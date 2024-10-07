# Output the hub virtual network so it can be used in a remote_state lookup by the spoke networks
output "vnets_hub" {
  value = module.vnets_hub
}

# Output the private DNS zone IDs so they can be used in private endpoint modules
output "private_dns_zone_app_services" {
  value = module.private_dns_zone_app_services
}

output "private_dns_zone_azure_sql" {
  value = module.private_dns_zone_azure_sql
}

output "private_dns_zone_storage_blob" {
  value = module.private_dns_zone_storage_blob
}

output "private_dns_zone_storage_queue" {
  value = module.private_dns_zone_storage_queue
}
