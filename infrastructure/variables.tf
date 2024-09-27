variable "application" {
  description = "Project/Application code for deployment"
  type        = string
  default     = "DToS"
}

variable "environment" {
  description = "Environment code for deployments"
  type        = string
  default     = "DEV"
}

variable "GITHUB_ORG_DATABASE_ID" {
  description = "GitHub Organization Database ID, specified via TF_VAR env var."
  type        = string
  default     = "DEV"
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
    is_app_services_enabled               = bool
    is_azure_sql_private_dns_zone_enabled = bool
    is_storage_private_dns_zone_enabled   = bool
  })
  default = {
    is_app_services_enabled               = false
    is_azure_sql_private_dns_zone_enabled = false
    is_storage_private_dns_zone_enabled   = false
  }
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

variable "TARGET_SUBSCRIPTION_ID" {
  description = "ID of a subscription to deploy infrastructure"
  type        = string
}
