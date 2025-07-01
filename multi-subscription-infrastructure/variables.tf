variable "TARGET_SUBSCRIPTION_ID" {
  description = "ID of a subscription to deploy infrastructure"
  type        = string
}

# variable "SUBSCRIPTION_ID_LIST" {
#   description = "A list of Azure subscription IDs used for smart detector alert rules."
#   type        = string
# }


variable "application" {
  description = "Project/Application code for deployment"
  type        = string
  default     = "hub"
}

variable "environment" {
  description = "Environment code for deployments"
  type        = string
}

variable "env_type" {
  description = "Environment grouping for shared hub (live/non-live)"
  type        = string
}


# variable "features" {
#   description = "Feature flags for the deployment"
#   type        = map(bool)
# }

# variable "private_dns_zones" {
#   description = "Configuration for private DNS zones"
#   type = object({
#     is_app_services_enabled                    = optional(bool, false)
#     is_azure_sql_private_dns_zone_enabled      = optional(bool, false)
#     is_postgres_sql_private_dns_zone_enabled   = optional(bool, false)
#     is_storage_private_dns_zone_enabled        = optional(bool, false)
#     is_acr_private_dns_zone_enabled            = optional(bool, false)
#     is_app_insights_private_dns_zone_enabled   = optional(bool, false)
#     is_apim_private_dns_zone_enabled           = optional(bool, false)
#     is_key_vault_private_dns_zone_enabled      = optional(bool, false)
#     is_event_hub_private_dns_zone_enabled      = optional(bool, false)
#     is_event_grid_enabled_dns_zone_enabled     = optional(bool, false)
#     is_container_apps_enabled_dns_zone_enabled = optional(bool, false)
#   })
# }

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

variable "activity_log_alert" {
  type = map(object({
    criteria = optional(object({
      category = string
      level    = string
      service_health = optional(object({
        events    = list(string)
        locations = list(string)
        services  = optional(list(string), [])
      }))
    }))
  }))
}

# variable "activity_log_alert" {
#   type = map(object({
#     criteria = optional(map(object({
#       category = string
#       level    = string
#       service_health = optional(map(object({
#         events    = list(string)
#         locations = list(string)
#         services  = optional(list(string), [])
#       })))
#     })))
#   }))
# }

variable "monitor_action_group" {
  description = "Default configuration for the monitor action groups."
  type = map(object({
    short_name = string
    email_receiver = optional(map(object({
      name                    = string
      email_address           = string
      use_common_alert_schema = optional(bool, false)
    })))
    event_hub_receiver = optional(map(object({
      name                    = string
      event_hub_namespace     = string
      event_hub_name          = string
      subscription_id         = string
      use_common_alert_schema = optional(bool, false)
    })))
    sms_receiver = optional(map(object({
      name         = string
      country_code = string
      phone_number = string
    })))
    voice_receiver = optional(map(object({
      name         = string
      country_code = string
      phone_number = string
    })))
    webhook_receiver = optional(map(object({
      name                    = string
      service_uri             = string
      use_common_alert_schema = optional(bool, false)
    })))
  }))
}


variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
  default     = {}
}
