application = "hub"
environment = "DEV"
env_type    = "nonlive"

# attached_environments = ["dev", "nft", "int"]

regions = {
  uksouth = {
    address_space     = "10.100.0.0/16"
    is_primary_region = true
    subnets = {
      acr = {
        cidr_newbits = 11
        cidr_offset  = 8
      }
      api-mgmt = {
        cidr_newbits = 8
        cidr_offset  = 6
      }
      app-gateway = {
        cidr_newbits = 8
        cidr_offset  = 5
      }
      pep = {
        cidr_newbits = 8
        cidr_offset  = 2
      }
      virtual-desktop = {
        cidr_newbits = 11
        cidr_offset  = 32
      }
      devops = {
        cidr_newbits               = 8
        cidr_offset                = 9
        delegation_name            = "Microsoft.DevOpsInfrastructure/pools" # az provider register --namespace 'Microsoft.DevOpsInfrastructure'
        service_delegation_name    = "Microsoft.DevOpsInfrastructure/pools"
        service_delegation_actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
      dns-resolver-in = {
        cidr_newbits               = 12
        cidr_offset                = 112
        delegation_name            = "Microsoft.Network/dnsResolvers"
        service_delegation_name    = "Microsoft.Network/dnsResolvers"
        service_delegation_actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
      firewall = {
        name         = "AzureFirewallSubnet"
        cidr_newbits = 10
        cidr_offset  = 192
        create_nsg   = false
      }
    }
  }
}

monitor_action_group = {
  action_group = {
    short_name = "SHA"
    email_receiver = {
      alert_team = {
        name                    = "Service_Health_Alerts"
        email_address           = "england.dtos-azure-health-alerts@nhs.net"
        use_common_alert_schema = false
      }
    }
  }
}


activity_log_alert = {
  criteria-action_group-uksouth = {
    criteria = {
      category = "ServiceHealth"
      level    = "Critical"
      service_health = {
        events    = ["Incident", "Maintenance"]
        locations = ["uksouth"]
        services  = []
      }
    }
  }
}

# activity_log_alert = {
#   criteria = {
#     category = "ServiceHealth"
#     level    = "Critical"
#     service_health = {
#       alert_team = {
#         events     = ["Incident", "Maintenance"]
#         locations  = ["uksouth"]
#         # services   = "Activity Logs & Alerts"
#       }
#     }
#   }
# }


tags = {
  Project = "DToS Hub"
}
