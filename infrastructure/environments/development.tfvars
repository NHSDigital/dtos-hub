application = "hub"
environment = "DEV"

projects = {
  dtos-cohort-manager = {
    full_name  = "cohort-manager"
    short_name = "cohman"
    acr = {
      sku                           = "Premium"
      admin_enabled                 = false
      uai_name                      = "dtos-cohort-manager-acr-push"
      public_network_access_enabled = true
    }
    tags = {
      Project = "DToS Cohort Manager"
    }
  }

  dtos-communication-management = {
    full_name  = "communication-management"
    short_name = "commgt"
    acr = {
      sku                           = "Premium"
      admin_enabled                 = false
      uai_name                      = "dtos-communication-management-acr-push"
      public_network_access_enabled = true
    }
    tags = {
      Project = "DToS Communication Management"
    }
  }
}

features = {
  private_endpoints_enabled            = true
  private_service_connection_is_manual = false
  public_network_access_enabled        = true
  github_actions_enabled               = true
}

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
      github-actions = {
        cidr_newbits               = 8
        cidr_offset                = 10
        delegation_name            = "GitHub.Network/networkSettings" # az provider register --namespace 'GitHub.Network'
        service_delegation_name    = "GitHub.Network/networkSettings"
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

apim_config = {
  sku_name             = "Developer"
  sku_capacity         = 1
  virtual_network_type = "Internal"
  publisher_email      = "apim.dtos@hscic.gov.uk"
  publisher_name       = "DToS - NHS Digital"
  gateway_disabled     = false
  zones                = []

  # ip address configuration
  public_ip_allocation_method = "Static"
  public_ip_sku               = "Standard"

  tags = {
    Project = "DToS Hub"
  }
}

firewall_config = {
  firewall_sku_name = "AZFW_VNet"
  firewall_sku_tier = "Standard"
  public_ip_addresses = {
    hub-azfw = {
      name_suffix          = "hub-azfw"
      allocation_method    = "Static"
      ddos_protection_mode = "Disabled"
      sku                  = "Standard"
    }
  }
  policy_sku                      = "Standard"
  policy_threat_intelligence_mode = "Alert"
  policy_dns_proxy_enabled        = false
  zones                           = ["1", "2", "3"]
}

private_dns_zones = {
  is_app_services_enabled                  = true
  is_azure_sql_private_dns_zone_enabled    = true
  is_storage_private_dns_zone_enabled      = true
  is_acr_private_dns_zone_enabled          = true
  is_app_insights_private_dns_zone_enabled = true
  is_apim_private_dns_zone_enabled         = true
  is_key_vault_private_dns_zone_enabled    = true

}

network_security_group_rules = {
  api-mgmt = [ # subnet key from regions map above
    {
      name                       = "ManagementEndpointForAzureportal"
      priority                   = 1600
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3443"
      source_address_prefix      = "ApiManagement"
      destination_address_prefix = "VirtualNetwork"
    },
    {
      name                       = "AzureInfrastructureLoadBalancer"
      priority                   = 1400
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "6390"
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "VirtualNetwork"
    },
    {
      name                       = "DependencyAzureStorageForCoreServiceFunctionality"
      priority                   = 1200
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "Storage"
    },
    {
      name                       = "AzureSQLEndpointsForCoreServiceFunctionality"
      priority                   = 1000
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "AzureKeyVault"
    },
    {
      name                       = "PublishDiagnosticLogsToAzureMonitorAndApplicationInsights"
      priority                   = 800
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_ranges    = ["1886", "443"]
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "AzureMonitor"
    }
  ],

  app-gateway = [
    {
      name                       = "Azure_Traffic_Manager_Probes"
      priority                   = 1400
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "AzureTrafficManager"
      destination_address_prefix = "VirtualNetwork"
    },
    {
      name                       = "Gateway_Manager_Ports"
      priority                   = 1500
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "65200-65535"
      source_address_prefix      = "GatewayManager"
      destination_address_prefix = "*"
    }
  ],

  virtual-desktop = [ # subnet key from regions map above
    {
      name                       = "AllowRDPfromAVD"
      priority                   = 600
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefix      = "WindowsVirtualDesktop"
      destination_address_prefix = "VirtualNetwork"
    }
  ],

  github-actions = [
    {
      name                       = "AllowStorageOutbound"
      priority                   = 230
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "Storage"
    }
  ]
}

tags = {
  Project = "DToS Hub"
}