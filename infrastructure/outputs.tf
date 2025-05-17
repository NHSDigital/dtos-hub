output "azure_monitor_private_link_scope_name" {
  value = azurerm_monitor_private_link_scope.ampls.name
}

output "certificates" {
  value     = module.acme_certificate
  sensitive = true
}

output "event_grid_topic" {
  value = module.event_grid_topic
}

# Output the Event Hub Id for Log Analytics Data Exports so it can be used as a reference
# by the Log Analytics workspace modules in Audit and Hub services
output "eventhub_law_export_id" {
  value = { for k, v in module.eventhub_law_export : k => v.id }
}

output "event_hubs" {
  value = { for k, v in module.eventhub_law_export : k => v.event_hubs }
}

# Output the Firewall details so they can be used in the spoke networks
output "firewall_policy_id" {
  value = { for k, v in module.firewall : k => v.firewall_policy_id }
}

output "firewall_private_ip_addresses" {
  value = { for k, v in module.firewall : k => v.private_ip_address }
}

output "key_vault" {
  value = module.key_vault
}

# Output the DNS resolver inbound private ip addresses so they can be used in the private endpoint modules
output "private_dns_resolver_inbound_ips" {
  value = module.private_dns_resolver
}

# Output the private DNS zone IDs so they can be used in private endpoint modules
output "private_dns_zones" {
  value = module.private_dns_zones
}

output "private_endpoint_rg_name" {
  value = { for k, v in azurerm_resource_group.rg_private_endpoints : k => v.name }
}

output "public_dns_zone_rg_name" {
  value = var.dns_zone_rg_name_public
}

output "subnets_hub" {
  value = module.subnets_hub
}

# Output the Tenant ID so it can be used APIM module
output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "storage" {
  value     = module.storage
  sensitive = true
}

output "vnets_hub" {
  value = module.vnets_hub
}
