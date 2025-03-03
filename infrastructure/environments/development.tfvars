application = "hub"
environment = "DEV"
env_type    = "nonlive"

attached_environments = ["dev", "nft", "int"]

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

  dtos-service-insights = {
    full_name  = "service-insights"
    short_name = "serins"
    acr = {
      sku                           = "Premium"
      admin_enabled                 = false
      uai_name                      = "dtos-service-insights-acr-push"
      public_network_access_enabled = true
    }
    tags = {
      Project = "DToS Service Insights"
    }
  }

  dtos-participant-manager = {
    full_name  = "participant-manager"
    short_name = "parman"
    acr = {
      sku                           = "Premium"
      admin_enabled                 = false
      uai_name                      = "dtos-participant-manager-acr-push"
      public_network_access_enabled = true
    }
    tags = {
      Project = "DToS Participant Manager"
    }
  }
}

features = {
  private_endpoints_enabled              = true
  private_service_connection_is_manual   = false
  public_network_access_enabled          = true
  github_actions_enabled                 = true
  log_analytics_data_export_rule_enabled = false
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
  sku_name                    = "Developer"
  sku_capacity                = 1
  virtual_network_type        = "Internal"
  publisher_email             = "apim.dtos@hscic.gov.uk"
  publisher_name              = "DToS - NHS Digital"
  gateway_disabled            = false
  zones                       = []
  public_ip_allocation_method = "Static"
  public_ip_sku               = "Standard"
  sign_in_enabled             = true
  sign_up_enabled             = false
  terms_of_service = {
    enabled          = true
    consent_required = false
    content          = "By using this service you agree to the terms and conditions"
  }
  tags = {
    Project = "DToS Hub"
  }
}

avd_vm_count                 = 6
avd_maximum_sessions_allowed = 6 # per session host
avd_vm_size                  = "Standard_D4as_v5"
avd_users_group_name         = "DToS-hub-dev-uks-hub-virtual-desktop-User-Login"
avd_admins_group_name        = "DToS-hub-dev-uks-hub-virtual-desktop-User-ADMIN-Login"
avd_source_image_from_gallery = {
  image_name      = "gi_wvd"
  gallery_name    = "rg_hub_dev_uks_compute_gallery"
  gallery_rg_name = "rg-hub-dev-uks-hub-virtual-desktop"
}

dns_zone_name_private   = "private.non-live.nationalscreening.nhs.uk"
dns_zone_name_public    = "non-live.nationalscreening.nhs.uk"
dns_zone_rg_name_public = "rg-hub-dev-uks-public-dns-zones"

diagnostic_settings = {
  metric_enabled = true
}

lets_encrypt_certificates = {
  wildcard         = "*.non-live.nationalscreening.nhs.uk"
  wildcard_private = "*.private.non-live.nationalscreening.nhs.uk"
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

key_vault = {
  disk_encryption   = true
  soft_del_ret_days = 7
  purge_prot        = false
  sku_name          = "standard"
}

private_dns_zones = {
  is_app_services_enabled                  = true
  is_azure_sql_private_dns_zone_enabled    = true
  is_postgres_sql_private_dns_zone_enabled = true
  is_storage_private_dns_zone_enabled      = true
  is_acr_private_dns_zone_enabled          = true
  is_app_insights_private_dns_zone_enabled = true
  is_apim_private_dns_zone_enabled         = true
  is_key_vault_private_dns_zone_enabled    = true
  is_event_hub_private_dns_zone_enabled    = true
  is_event_grid_enabled_dns_zone_enabled   = true
}

law = {
  export_enabled = false
  law_sku        = "PerGB2018"
  retention_days = 30
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

  # When Application Gateway uses the same frontend port (443) for public and private frontend IP configurations, traffic for
  # both interfaces will be filtered by the private subnet's NSG, so we must grant the public traffic here even though
  # logically no Internet traffic can get routed to this private subnet.
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
    },
    {
      name                       = "PublicAccess"
      priority                   = 1000
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
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

event_grid_configs = {
  # evgt-<env_name>-<project_id_source>-<api_name>-<theme>

  # CreateEpisode writes to this topic
  evgt-dev-si-create-episode-ep = {
    identity_type = "SystemAssigned"
    environment   = "dev"
  }
  # UpdateEpisode writes to this topic
  evgt-dev-si-update-episode-ep = {
    identity_type = "SystemAssigned"
    environment   = "dev"
  }
  # ReceiveData writes to this topic
  evgt-dev-si-receive-data-ep = {
    identity_type = "SystemAssigned"
    environment   = "dev"
  }
  # ReceiveData writes to this topic
  evgt-dev-si-receive-data-pr = {
    identity_type = "SystemAssigned"
    environment   = "dev"
  }
  evgt-nft-si-create-episode-ep = {
    identity_type = "SystemAssigned"
    environment   = "nft"
  }
  # UpdateEpisode writes to this topic
  evgt-nft-si-update-episode-ep = {
    identity_type = "SystemAssigned"
    environment   = "nft"
  }
  # ReceiveData writes to this topic
  evgt-nft-si-receive-data-ep = {
    identity_type = "SystemAssigned"
    environment   = "nft"
  }
  # ReceiveData writes to this topic
  evgt-nft-si-receive-data-pr = {
    identity_type = "SystemAssigned"
    environment   = "nft"
  }
  evgt-int-si-create-episode-01 = {
    identity_type = "SystemAssigned"
    environment   = "int"
  }
  # UpdateEpisode writes to this topic
  evgt-int-si-update-episode-01 = {
    identity_type = "SystemAssigned"
    environment   = "int"
  }
  # ReceiveData writes to this topic
  evgt-int-si-receive-data-01 = {
    identity_type = "SystemAssigned"
    environment   = "int"
  }
  # ReceiveData writes to this topic
  evgt-int-si-receive-data-02 = {
    identity_type = "SystemAssigned"
    environment   = "int"
  }
}

event_grid_defaults = {
  identity_ids                  = []
  identity_type                 = "SystemAssigned"
  inbound_ip_rules              = []
  input_schema                  = {}
  local_auth_enabled            = true
  public_network_access_enabled = false
}

storage_accounts = {

  eventgrid = {
    name_suffix                   = "eventgrid"
    account_tier                  = "Standard"
    replication_type              = "LRS"
    public_network_access_enabled = false
    containers = {
      config = {
        container_name = "deadletterqueue"
      }
    }
  }
}
