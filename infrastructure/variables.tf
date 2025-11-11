variable "AVD_SOURCE_IMAGE_ID" {
  description = "Source OS image for AVD Session Hosts, allows deployment from an Azure Compute Gallery in a remote subscription. Remember to grant 'Compute Gallery Image Reader' RBAC role."
  type        = string
  default     = null
}

variable "HUB_BACKEND_AZURE_STORAGE_ACCOUNT_NAME" {
  description = "Storage account for certbot state"
  type        = string
}

variable "GITHUB_ORG_DATABASE_ID" {
  description = "GitHub Organization Database ID, specified via TF_VAR env var"
  type        = string
  default     = "DEV"
}

variable "LETS_ENCRYPT_CONTACT_EMAIL" {
  description = "Contact email address for certificate expiry notifications."
  type        = string
}

variable "TARGET_SUBSCRIPTION_ID" {
  description = "ID of a subscription to deploy infrastructure"
  type        = string
}


variable "WAF_POLICY_ID_APIM_GATEWAY" {
  description = "ID of the WAF policy which will be bound to the Application Gateway listener for APIM Gateway"
  type        = string
}

variable "acme_certificates" {
  # https://registry.terraform.io/providers/vancluever/acme/latest/docs/resources/certificate
  type = map(object({
    common_name                 = string
    subject_alternative_names   = optional(list(string))
    dns_cname_zone_name         = optional(string) # CNAME for redirecting DNS-01 challenges
    dns_private_cname_zone_name = optional(string) # CNAME for redirecting DNS-01 challenges
    dns_challenge_zone_name     = string
    dns_challenge_zone_rg_name  = optional(string)
    key_type                    = optional(string, "P256") # Follow certbot default of ECDSA P256
  }))
  description = "Map of ACME certificates to be requested"
}

variable "apim_config" {
  description = "Configuration for API Management"
  type = object({
    sku_name                    = string
    sku_capacity                = number
    virtual_network_type        = string
    publisher_email             = string
    publisher_name              = string
    gateway_disabled            = bool
    public_ip_allocation_method = string
    public_ip_sku               = string
    zones                       = list(string)
    sign_in_enabled             = bool
    sign_up_enabled             = bool
    terms_of_service = object({
      enabled          = bool
      consent_required = bool
      content          = string
    })
    tags = map(string)
  })
}

variable "application" {
  description = "Project/Application code for deployment"
  type        = string
  default     = "hub"
}

variable "application_gateway_additional" {
  type = object({
    probe = optional(map(object({
      host                                      = optional(string)
      interval                                  = number
      path                                      = string
      pick_host_name_from_backend_http_settings = optional(bool)
      protocol                                  = string
      timeout                                   = number
      unhealthy_threshold                       = number
      minimum_servers                           = optional(number)
      port                                      = optional(number)
      match = optional(object({
        status_code = list(string)
        body        = optional(string)
      }))
    })))
    backend_http_settings = optional(map(object({
      cookie_based_affinity               = string
      affinity_cookie_name                = optional(string)
      path                                = optional(string)
      port                                = number
      probe_key                           = optional(string) # Since the names map is only interpolated inside the module, we have to pass in the probe key from the root module
      protocol                            = string
      request_timeout                     = optional(number)
      host_name                           = optional(string)
      pick_host_name_from_backend_address = optional(bool)
      trusted_root_certificate_names      = optional(list(string))
      connection_draining = optional(object({
        enabled           = bool
        drain_timeout_sec = number
      }))
    })))
    http_listener = optional(map(object({
      host_name                     = optional(string)
      host_names                    = optional(list(string), [])
      firewall_policy_id            = optional(string)
      frontend_ip_configuration_key = string
      frontend_port_key             = string
      protocol                      = string
      require_sni                   = optional(bool, false)
      ssl_certificate_key           = optional(string)
      ssl_profile_name              = optional(string)
    })))
    request_routing_rule = optional(map(object({
      backend_address_pool_key  = string
      backend_http_settings_key = string
      http_listener_key         = string
      priority                  = number
      rewrite_rule_set_key      = optional(string)
      rule_type                 = string
    })))
  })
  default = {}
}

variable "application_gateway_additional_backend_address_pool_by_region" {
  type    = map(any)
  default = {}
}

variable "attached_environments" {
  description = "Configuration of the Log Analytics Workspace"
  type        = list(string)
}

variable "avd_users_group_name" {
  description = "Entra ID group containing AVD users"
  type        = string
}

variable "avd_admins_group_name" {
  description = "Entra ID group containing AVD admins"
  type        = string
}

variable "avd_maximum_sessions_allowed" {
  description = "The maximum number of sessions per host, in this host pool"
  type        = number
}

variable "avd_source_image_reference" {
  description = "Specifies a standard Azure Virtual Machine OS image, replaces var.avd_source_image_from_gallery"
  type = object({
    offer     = string
    publisher = string
    sku       = string
    version   = string
  })
  default = null
}

variable "avd_source_image_from_gallery" {
  description = "Specifies a shared OS image from an Azure Compute Gallery, replaces var.avd_source_image_reference"
  type = object({
    image_name      = string
    gallery_name    = string
    gallery_rg_name = string
  })
  default = null
}

variable "avd_vm_count" {
  type    = number
  default = 1
}

variable "avd_vm_size" {
  type    = string
  default = "Standard_D2as_v5"
}

variable "diagnostic_settings" {
  description = "Configuration for the diagnostic settings"
  type = object({
    metric_enabled = optional(bool, false)
  })
}

variable "dns_zone_name_private" {
  type        = map(string)
  description = "Map of zone identifiers to their full private DNS zone names"
}

variable "dns_zone_name_public" {
  type        = map(string)
  description = "Map of zone identifiers to their full public DNS zone names"
}

variable "dns_zone_rg_name_public" {
  type = string
}

variable "environment" {
  description = "Environment code for deployments"
  type        = string
}

variable "env_type" {
  description = "Environment grouping for shared hub (live/non-live)"
  type        = string
}

variable "event_grid_configs" {
  type    = map(any) # needs to be a loose type definition to allow merging of var.event_grid_configs
  default = {}
}

variable "event_grid_defaults" {
  description = "Default configuration for the Event Grid resource"
  type = object({
    identity_ids  = list(string)
    identity_type = string
    inbound_ip_rules = list(object({
      ip_mask = string
      action  = string
    }))
    input_schema                  = map(string)
    local_auth_enabled            = bool
    public_network_access_enabled = bool
  })
}

variable "eventhub_namespaces" {
  description = "A map of Event Hub Namespaces and contained Event Hubs."
  type = map(object({
    auto_inflate             = optional(bool, false)
    capacity                 = optional(number)
    sku                      = optional(string, "Standard")
    minimum_tls_version      = optional(string)
    maximum_throughput_units = optional(number)

    public_network_access_enabled = optional(bool, false)

    auth_rule = object({
      listen = optional(bool, true)
      send   = optional(bool, false)
      manage = optional(bool, false)
    })

    event_hubs = optional(map(object({
      name              = optional(string)
      consumer_group    = optional(string)
      partition_count   = optional(number, 2)
      message_retention = optional(number, 1)
    })))
  }))
  default = {}
}

variable "features" {
  description = "Feature flags for the deployment"
  type        = map(bool)
}

variable "firewall_config" {
  description = "Configuration for the firewall"

  type = object({
    firewall_sku_name = optional(string)
    firewall_sku_tier = optional(string)
    public_ip_addresses = optional(map(object({
      name_suffix          = string
      allocation_method    = string
      ddos_protection_mode = string
      sku                  = string
    })))
    policy_sku                      = optional(string)
    policy_threat_intelligence_mode = optional(string)
    policy_dns_proxy_enabled        = optional(bool)
    zones                           = optional(list(string))
  })
  default = {}
}

variable "key_vault" {
  description = "Configuration for the key vault"
  type = object({
    disk_encryption   = optional(bool, true)
    soft_del_ret_days = optional(number, 7)
    purge_prot        = optional(bool, false)
    sku_name          = optional(string, "standard")
  })
}

variable "law" {
  description = "Configuration of the Log Analytics Workspace"
  type = object({
    name               = optional(string, "hub")
    export_enabled     = optional(bool, false)
    law_sku            = optional(string, "PerGB2018")
    retention_days     = optional(number, 30)
    export_table_names = optional(list(string))
  })
}

variable "network_security_group_rules" {
  description = "The network security group rules."
  default     = {}
  type = map(list(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = optional(string)
    source_port_ranges           = optional(list(string))
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(list(string))
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
  })))
}

variable "private_dns_zones" {
  description = "Configuration for private DNS zones"
  type = object({
    is_app_services_enabled                    = optional(bool, false)
    is_azure_sql_private_dns_zone_enabled      = optional(bool, false)
    is_postgres_sql_private_dns_zone_enabled   = optional(bool, false)
    is_storage_private_dns_zone_enabled        = optional(bool, false)
    is_acr_private_dns_zone_enabled            = optional(bool, false)
    is_app_insights_private_dns_zone_enabled   = optional(bool, false)
    is_apim_private_dns_zone_enabled           = optional(bool, false)
    is_key_vault_private_dns_zone_enabled      = optional(bool, false)
    is_event_hub_private_dns_zone_enabled      = optional(bool, false)
    is_event_grid_enabled_dns_zone_enabled     = optional(bool, false)
    is_container_apps_enabled_dns_zone_enabled = optional(bool, false)
  })
}

variable "projects" {
  description = "Project code for deployment"
  type = map(object({
    full_name  = string
    short_name = string
    acr = optional(object({
      sku                           = string
      admin_enabled                 = bool
      uai_name                      = string
      public_network_access_enabled = bool
    }), null)
    frontdoor_profile = optional(object({
      secrets  = optional(list(string), []) # Keys from var.acme_certificates
      sku_name = string
      identity = optional(object({
        type         = string                 # "SystemAssigned", "UserAssigned", or "SystemAssigned, UserAssigned".
        identity_ids = optional(list(string)) # only required if using UserAssigned identity
      }), null)
    }))
    tags = map(string)
  }))
}

variable "regions" {
  type = map(object({
    address_space     = string
    is_primary_region = bool
    subnets = map(object({
      cidr_newbits               = string
      cidr_offset                = string
      create_nsg                 = optional(bool)   # defaults to true
      name                       = optional(string) # Optional name override
      delegation_name            = optional(string)
      service_delegation_name    = optional(string)
      service_delegation_actions = optional(list(string))
    }))
  }))
}

variable "storage_accounts" {
  description = "Configuration for the Storage Account, currently used for Function Apps"
  type = map(object({
    name_suffix                   = string
    account_tier                  = optional(string, "Standard")
    replication_type              = optional(string, "LRS")
    public_network_access_enabled = optional(bool, false)
    containers = optional(map(object({
      container_name        = string
      container_access_type = optional(string, "private")
    })), {})
  }))
  default = {}
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
  default     = {}
}

variable "virtual_desktop_group_active" {
  description = <<-EOT
    This can either be 'one', 'two', 'both-one-primary' or 'both-two-primary'.
    one means only virtual desktop one is deploy whilst virtual desktop two is removed.
    two means only virtual desktop two is deploy whilst virtual desktop one is removed. Users are directed to group two.
    both-one-primary means both virtual desktop groups are deployed, but ONLY the platform users can see group two. All other users will be directed to group one.
    both-two-primary means both virtual desktop groups are deployed, but ONLY the platform users can see group one. All other users will be directed to group two.
  EOT

  type = string

  validation {
    condition     = contains(["one", "two", "both-one-primary", "both-two-primary"], var.virtual_desktop_group_active)
    error_message = "The virtual_desktop_group_active variable must be one of: 'one', 'two', 'both-one-primary', or 'both-two-primary'."
  }
}
