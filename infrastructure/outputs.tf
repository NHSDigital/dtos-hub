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

output "firewall_policy_id" {
  value = { for k, v in module.firewall : k => v.firewall_policy_id }
}

output "firewall_private_ip_addresses" {
  value = { for k, v in module.firewall : k => v.private_ip_address }
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}
