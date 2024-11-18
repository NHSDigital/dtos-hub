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

variable "application" {
  description = "Project/Application code for deployment"
  type        = string
  default     = "hub"
}

variable "apim_config" {
  description = "Configuration for API Management"
  type = object({
    aad = object({
      secrets         = list(string)
    })
    sku_name                    = string
    sku_capacity                = number
    virtual_network_type        = string
    publisher_email             = string
    publisher_name              = string
    gateway_disabled            = bool
    zones                       = list(string)
    tags                        = map(string)
  })
}

variable "avd_users_group_name" {
  description = "Entra ID group containing AVD users"
  type        = string
}

variable "avd_admins_group_name" {
  description = "Entra ID group containing AVD admins"
  type        = string
}

variable "avd_vm_count" {
  type    = number
  default = 1
}

variable "dns_a_records" {
  description = "A records to create in the DNS zone"
  type = map(list(object({
    name    = string
    records = list(string)
    ttl     = number
  })))
  default = {}

}

variable "dns_zone_name" {
  type = string
}

variable "dns_zone_resource_group_name" {
  type = string
}

variable "environment" {
  description = "Environment code for deployments"
  type        = string
  default     = "DEV"
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

variable "lets_encrypt_certificates" {
  type = map(string)
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
    is_app_services_enabled                  = optional(bool, false)
    is_azure_sql_private_dns_zone_enabled    = optional(bool, false)
    is_storage_private_dns_zone_enabled      = optional(bool, false)
    is_acr_private_dns_zone_enabled          = optional(bool, false)
    is_app_insights_private_dns_zone_enabled = optional(bool, false)
    is_apim_private_dns_zone_enabled         = optional(bool, false)
    is_key_vault_private_dns_zone_enabled    = optional(bool, false)
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

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
  default     = {}
}
