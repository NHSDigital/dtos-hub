output "azure_monitor_private_link_scope_name" {
  value = azurerm_monitor_private_link_scope.ampls.name
}

output "private_endpoint_rg_name" {
  value = { for k, v in azurerm_resource_group.rg_private_endpoints : k => v.name }
}

# Output the hub virtual network so it can be used in a remote_state lookup by the spoke networks
output "vnets_hub" {
  value = module.vnets_hub
}

output "subnets_hub" {
  value = module.subnets_hub
}

output "key_vault" {
  value = module.key_vault
}

output "certificates" {
  value = module.lets_encrypt_certificate
}

# Output the DNS resolver inbound private ip addresses so they can be used in the private endpoint modules
output "private_dns_resolver_inbound_ips" {
  value = module.private_dns_resolver
}

# Output the private DNS zone IDs so they can be used in private endpoint modules
output "private_dns_zones" {
  value = module.private_dns_zones
}

# Output the Firewall details so they can be used in the spoke networks
output "firewall_policy_id" {
  value = { for k, v in module.firewall : k => v.firewall_policy_id }
}

output "firewall_private_ip_addresses" {
  value = { for k, v in module.firewall : k => v.private_ip_address }
}

# Output the Event Hub Id for Log Analytics Data Exports so it can be used as a reference
# by the Log Analytics workspace modules in Audit and Hub services
output "eventhub_law_export_id" {
  value = { for k, v in module.eventhub_law_export : k => v.id }
}

output "event_hubs" {
  value = { for k, v in module.eventhub_law_export : k => v.event_hubs }
}

# Output the Tenant ID so it can be used APIM module
output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}
