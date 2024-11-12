application = "hub"
environment = "PROD"

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
}

features = {
  private_endpoints_enabled            = true
  private_service_connection_is_manual = false
  public_network_access_enabled        = true
  github_actions_enabled               = false
}

regions = {
  uksouth = {
    address_space     = "10.1.0.0/16"
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
        create_nsg   = false
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

apim_config = {
  sku_name             = "Premium"
  sku_capacity         = 3
  virtual_network_type = "Internal"
  publisher_email      = "apim.dtos@hscic.gov.uk"
  publisher_name       = "DToS - NHS Digital"
  gateway_disabled     = false
  zones                = ["1", "2", "3"]

  # ip address configuration
  public_ip_allocation_method = "Static"
  public_ip_sku               = "Standard"

  tags = {
    Project = "DToS Hub"
  }
}

avd_vm_count          = 2
avd_users_group_name  = "DToS-hub-prod-uks-hub-virtual-desktop-User-Login"
avd_admins_group_name = "DToS-hub-prod-uks-hub-virtual-desktop-User-ADMIN-Login"

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

key_vault = {
  disk_encryption   = true
  soft_del_ret_days = 7
  purge_prot        = false
  sku_name          = "standard"
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

  virtual-desktop = [ # subnet key from regions map above
    {
      name                       = "AllowRDPfromAVD"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389-3389"
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
