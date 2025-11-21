application = "hub"
environment = "DEV"
env_type    = "nonlive"

attached_environments = ["dev", "nft", "int"]

# See variable description
virtual_desktop_group_active = "both-with-blue-primary"

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
    frontdoor_profile = {
      sku_name = "Premium_AzureFrontDoor"
    }
    tags = {
      Project = "DToS Cohort Manager"
    }
  }

  dtos-tooling = {
    full_name  = "dtos-tooling"
    short_name = "tooling"
    acr = {
      sku                           = "Premium"
      admin_enabled                 = false
      uai_name                      = "dtos-tooling-push"
      public_network_access_enabled = true
    }
    tags = {
      Project = "DToS Tooling"
    }
  }

  dtos-manage-breast-screening = {
    full_name  = "dtos-manage-breast-screening"
    short_name = "manbrs"
    tags = {
      Project = "Manage Breast Screening"
    }
    frontdoor_profile = {
      sku_name = "Premium_AzureFrontDoor"
    }
  }
}

features = {
  private_endpoints_enabled              = true
  private_service_connection_is_manual   = false
  public_network_access_enabled          = true
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

application_gateway_additional = {
  probe = {
    migration_test = {
      interval                                  = 30
      path                                      = "/"
      pick_host_name_from_backend_http_settings = true
      protocol                                  = "Https"
      timeout                                   = 30
      unhealthy_threshold                       = 3
      match = {
        status_code = ["200-399"] # not strictly needed, but this stops Terraform detecting a change every time
      }
    }
  }
  backend_http_settings = {
    migration_test = {
      cookie_based_affinity               = "Disabled"
      pick_host_name_from_backend_address = true
      port                                = 443
      probe_key                           = "migration_test"
      protocol                            = "Https"
      request_timeout                     = 20
    }
  }
  http_listener = {
    migration_test_public = {
      frontend_ip_configuration_key = "public"
      frontend_port_key             = "https"
      host_name                     = "migration-test.non-live.nationalscreening.nhs.uk"
      protocol                      = "Https"
      require_sni                   = true
      ssl_certificate_key           = "nationalscreening_wildcard"
      # firewall_policy_id            = null
    }
  }
  request_routing_rule = {
    migration_test_public = {
      backend_address_pool_key  = "migration_test"
      backend_http_settings_key = "migration_test"
      http_listener_key         = "migration_test_public"
      priority                  = 950
      rewrite_rule_set_key      = "migration_test"
      rule_type                 = "Basic"
    }
  }
}

application_gateway_additional_backend_address_pool_by_region = {
  uksouth = {
    migration_test = {
      fqdns = ["apim-pamo16test.developer.azure-api.net"]
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

dns_zone_name_private = {
  nationalscreening = "private.non-live.nationalscreening.nhs.uk"
  screening         = "private.non-live.screening.nhs.uk"
}
dns_zone_name_public = {
  nationalscreening = "non-live.nationalscreening.nhs.uk"
  screening         = "non-live.screening.nhs.uk"
}
dns_zone_rg_name_public = "rg-hub-dev-uks-public-dns-zones"

diagnostic_settings = {
  metric_enabled = true
}

# ACME Terraform provider (which uses https://github.com/go-acme/lego) always checks that public NS records exist for the leaf domain, unlike certbot.
# Where this leaf domain is missing, redirect the DNS-01 challenges using the CNAME method (e.g. to acme subdomain).
# Split-brain DNS (where private domains overlap the public namespace) will also spoil DNS-01 challenges, so redirect with both public and private CNAMEs.
acme_certificates = {
  screening_wildcard = {
    common_name             = "*.non-live.screening.nhs.uk"
    dns_challenge_zone_name = "non-live.screening.nhs.uk"
  }
  screening_wildcard_private = {
    common_name                 = "*.private.non-live.screening.nhs.uk"
    dns_cname_zone_name         = "non-live.screening.nhs.uk"
    dns_private_cname_zone_name = "private.non-live.screening.nhs.uk"
    dns_challenge_zone_name     = "acme.non-live.screening.nhs.uk"
  }
  nationalscreening_wildcard = {
    common_name             = "*.non-live.nationalscreening.nhs.uk"
    dns_challenge_zone_name = "non-live.nationalscreening.nhs.uk"
  }
  nationalscreening_wildcard_private = {
    common_name                 = "*.private.non-live.nationalscreening.nhs.uk"
    dns_cname_zone_name         = "non-live.nationalscreening.nhs.uk"
    dns_private_cname_zone_name = "private.non-live.nationalscreening.nhs.uk"
    dns_challenge_zone_name     = "acme.non-live.nationalscreening.nhs.uk"
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
  is_app_services_enabled                    = true
  is_azure_sql_private_dns_zone_enabled      = true
  is_postgres_sql_private_dns_zone_enabled   = true
  is_storage_private_dns_zone_enabled        = true
  is_acr_private_dns_zone_enabled            = true
  is_app_insights_private_dns_zone_enabled   = true
  is_apim_private_dns_zone_enabled           = true
  is_key_vault_private_dns_zone_enabled      = true
  is_event_hub_private_dns_zone_enabled      = true
  is_event_grid_enabled_dns_zone_enabled     = true
  is_container_apps_enabled_dns_zone_enabled = true
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
    # {
    #   name                       = "AllowAzureFrontDoor"
    #   priority                   = 1500
    #   direction                  = "Inbound"
    #   access                     = "Allow"
    #   protocol                   = "Tcp"
    #   source_port_range          = "*"
    #   destination_port_range     = "443"
    #   source_address_prefix      = "AzureFrontDoor.Backend"
    #   destination_address_prefix = "VirtualNetwork"
    # },
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
  evgt-int-si-create-episode-ep = {
    identity_type = "SystemAssigned"
    environment   = "int"
  }
  # UpdateEpisode writes to this topic
  evgt-int-si-update-episode-ep = {
    identity_type = "SystemAssigned"
    environment   = "int"
  }
  # ReceiveData writes to this topic
  evgt-int-si-receive-data-ep = {
    identity_type = "SystemAssigned"
    environment   = "int"
  }
  # ReceiveData writes to this topic
  evgt-int-si-receive-data-pr = {
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
