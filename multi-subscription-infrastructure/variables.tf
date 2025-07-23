variable "TARGET_SUBSCRIPTION_ID" {
  description = "ID of a subscription to deploy infrastructure"
  type        = string
}

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
