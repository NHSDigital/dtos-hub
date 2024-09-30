# Output the hub virtual network so it can be used in a remote_state lookup by the spoke networks
output "vnets_hub" {
  value = module.vnets_hub
}

# Output the DNS ZOne Ids as they are required by the private endpoint module
output "azurerm_private_dns_zone_app_services_id" {
  value = azurerm_private_dns_zone.private_dns_zone_app_services.id
}

output "azurerm_private_dns_zone_azure_sql_id" {
  value = azurerm_private_dns_zone.private_dns_zone_azure_sql.id
}

output "azurerm_private_dns_zone_storage_id" {
  value = azurerm_private_dns_zone.private_dns_zone_storage.id
}
