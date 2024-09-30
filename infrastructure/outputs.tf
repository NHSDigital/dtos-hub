# Output the hub virtual network so it can be used in a remote_state lookup by the spoke networks
output "vnets_hub" {
  value = module.vnets_hub
}
