application = "hub"
environment = "PROD"
env_type    = "live"

attached_environments = ["pre", "prd"]

projects = {
  dtos-cohort-manager = {
    full_name  = "cohort-manager"
    short_name = "cohman"
    acr = {
      sku                           = "Premium"
      admin_enabled                 = false
      uai_name                      = "dtos-cohort-manager-acr-push"
      public_network_access_enabled = false
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
      public_network_access_enabled = false
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
      public_network_access_enabled = false
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
      public_network_access_enabled = false
    }
    tags = {
      Project = "DToS Participant Manager"
    }
  }
}

diagnostic_settings = {
  metric_enabled = true
}

features = {
  private_endpoints_enabled              = true
  private_service_connection_is_manual   = false
  public_network_access_enabled          = true
  github_actions_enabled                 = false
  log_analytics_data_export_rule_enabled = true
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

apim_config = {
  sku_name                    = "Premium"
  sku_capacity                = 3
  virtual_network_type        = "Internal"
  publisher_email             = "apim.dtos@hscic.gov.uk"
  publisher_name              = "DToS - NHS Digital"
  gateway_disabled            = false
  zones                       = ["1", "2", "3"]
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

avd_vm_count                 = 2
avd_maximum_sessions_allowed = 6 # per session host
avd_vm_size                  = "Standard_D4as_v5"
avd_users_group_name         = "DToS-hub-prod-uks-hub-virtual-desktop-User-Login"
avd_admins_group_name        = "DToS-hub-prod-uks-hub-virtual-desktop-User-ADMIN-Login"
# AVD_SOURCE_IMAGE_ID will be set by ADO variable group to allow deployment from another subscription
#
# avd_source_image_from_gallery = {
#   image_name      = "gi_wvd"
#   gallery_name    = "rg_hub_prod_uks_compute_gallery"
#   gallery_rg_name = "rg-hub-prod-uks-hub-virtual-desktop"
# }
# avd_source_image_reference = {
#   offer     = "windows-11"
#   publisher = "microsoftwindowsdesktop"
#   sku       = "win11-23h2-avd"
#   version   = "latest"
# }

dns_zone_name_private = {
  nationalscreening = "private.nationalscreening.nhs.uk"
  screening         = "private.screening.nhs.uk"
}
dns_zone_name_public = {
  nationalscreening = "nationalscreening.nhs.uk"
  screening         = "screening.nhs.uk"
}
dns_zone_rg_name_public = "rg-hub-prod-uks-public-dns-zones"

eventhub_namespaces = {
  dtos-hub = {
    sku                           = "Standard"
    public_network_access_enabled = true
    minimum_tls_version           = "1.2"
    maximum_throughput_units      = 1
    auth_rule = {
      listen = true
      send   = false
      manage = false
    }
    event_hubs = {
      # Log events from the Hub itself as well as from individual applications
      dtos-hub = {
        name              = "dtosHubProd"
        consumer_group    = "dtosHubConsumerGroupProd"
        partition_count   = 2
        message_retention = 1
      }
      cohort-manager-pre = {
        name              = "cohortExportPreProd"
        consumer_group    = "cohortConsumerGroupPreProd"
        partition_count   = 2
        message_retention = 1
      }
      cohort-manager-prod = {
        name              = "cohortExportProd"
        consumer_group    = "cohortConsumerGroupProd"
        partition_count   = 2
        message_retention = 1
      }
      communication-manager-pre = {
        name              = "commgtExportPreProd"
        consumer_group    = "commgtConsumerGroupPreProd"
        partition_count   = 2
        message_retention = 1
      }
      communication-manager-prod = {
        name              = "commgtExportProd"
        consumer_group    = "commgtConsumerGroupProd"
        partition_count   = 2
        message_retention = 1
      }
      service-insights-pre = {
        name              = "serinsExportPreProd"
        consumer_group    = "serinsConsumerGroupPreProd"
        partition_count   = 2
        message_retention = 1
      }
      service-insights-prod = {
        name              = "serinsExportProd"
        consumer_group    = "serinsConsumerGroupProd"
        partition_count   = 2
        message_retention = 1
      }
    }
  }
}

# ACME Terraform provider (which uses https://github.com/go-acme/lego) always checks that public NS records exist for the leaf domain, unlike certbot.
# Where this leaf domain is missing, redirect the DNS-01 challenges using the CNAME method (e.g. to acme subdomain).
# Split-brain DNS (where private domains overlap the public namespace) will also spoil DNS-01 challenges, so redirect with both public and private CNAMEs.
acme_certificates = {
  screening_wildcard = {
    common_name             = "*.screening.nhs.uk"
    dns_challenge_zone_name = "screening.nhs.uk"
  }
  screening_wildcard_private = {
    common_name                 = "*.private.screening.nhs.uk"
    dns_cname_zone_name         = "screening.nhs.uk"
    dns_private_cname_zone_name = "private.screening.nhs.uk"
    dns_challenge_zone_name     = "acme.screening.nhs.uk"
  }
  nationalscreening_wildcard = {
    common_name             = "*.nationalscreening.nhs.uk"
    dns_challenge_zone_name = "nationalscreening.nhs.uk"
  }
  nationalscreening_wildcard_private = {
    common_name                 = "*.private.nationalscreening.nhs.uk"
    dns_cname_zone_name         = "nationalscreening.nhs.uk"
    dns_private_cname_zone_name = "private.nationalscreening.nhs.uk"
    dns_challenge_zone_name     = "acme.nationalscreening.nhs.uk"
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
  export_enabled = true
  law_sku        = "PerGB2018"
  retention_days = 30
  export_table_names = [
    "AGWAccessLogs",
    "AGWFirewallLogs",
    "Alert",
    "ApiManagementGatewayLogs",
    "APIMDevPortalAuditDiagnosticLog",
    "AppDependencies",
    "AppExceptions",
    "AppMetrics",
    "AppPerformanceCounters",
    "AppRequests",
    "AppSystemEvents",
    "AppTraces",
    "AzureDiagnostics",
    "AzureMetrics",
    "LAQueryLogs",
    "Usage"
  ]
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

event_grid_defaults = {
  identity_ids                  = []
  identity_type                 = "SystemAssigned"
  inbound_ip_rules              = []
  input_schema                  = {}
  local_auth_enabled            = true
  public_network_access_enabled = false
}

tags = {
  Project = "DToS Hub"
}
