variable "agent_profile_kind" {
  type    = string
  default = "Stateful" # "Stateless"
}

variable "agent_profile_resource_prediction_profile" {
  type    = string
  default = "Manual"
}

variable "agent_profile_resource_predictions_manual" {
  type = object({
    time_zone = string
    days_data = list(map(any)) # list of maps with dynamic key-value pairs
  })
  default = {
    "time_zone" : "GMT Standard Time",
    "days_data" : [
      {},
      {
        "08:00:00" : 1,
        "19:00:00" : 0
      },
      {
        "08:00:00" : 1,
        "19:00:00" : 0
      },
      {
        "08:00:00" : 1,
        "19:00:00" : 0
      },
      {
        "08:00:00" : 1,
        "19:00:00" : 0
      },
      {
        "08:00:00" : 1,
        "19:00:00" : 0
      },
      {}
    ]
  }
}

variable "application" {
  description = "Project/Application code for deployment."
  type        = string
  default     = "hub"
}

variable "environment" {
  description = "Environment code for deployments."
  type        = string
}

variable "fabric_profile_images" {
  type = list(object({
    aliases               = list(string)
    well_known_image_name = string
  }))
  default = [{
    aliases = [
      "ubuntu-22.04",
      "ubuntu-22.04/latest"
    ],
    buffer                = "*",
    well_known_image_name = "ubuntu-22.04/latest"
  }]
}

variable "fabric_profile_os_disk_storage_account_type" {
  type    = string
  default = "StandardSSD"
}

variable "fabric_profile_sku_name" {
  description = "The Virtual Machine SKU."
  type        = string
  #default     = "Standard_D2ads_v5"
  default = "Standard_DS1_v2"
}

variable "maximum_concurrency" {
  type    = number
  default = 1
}

variable "regions" {
  description = "The Azure regions to deploy into."
  type        = set(string)
}

variable "SUBNET_ID_UKSOUTH" {
  description = "The uksouth virtual network subnet resource id to use for private networking, specified via TF_VAR env var."
  type        = string
}

variable "SUBNET_ID_UKWEST" {
  description = "The ukwest virtual network subnet resource id to use for private networking, specified via TF_VAR env var."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
  default     = {}
}

variable "TARGET_SUBSCRIPTION_ID" {
  description = "The target Azure subscription ID, specified via TF_VAR env var."
  type        = string
}

variable "version_control_system_organization_name" {
  description = "The Azure DevOps organization name."
  type        = string
  default     = "nhse-dtos"
}

variable "version_control_system_project_names" {
  description = "List of Azure DevOps projects which will use the pool."
  type        = list(string)
  default     = []
}