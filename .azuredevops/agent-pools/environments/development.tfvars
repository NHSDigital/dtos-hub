environment = "DEV"
regions     = ["uksouth"]

agent_profile_resource_predictions_manual = {
  "time_zone" : "GMT Standard Time",
  "days_data" : [
    {}, # Sunday
    {
      "08:00:00" : 4, # Monday
      "19:00:00" : 0
    },
    {
      "08:00:00" : 4, # Tuesday
      "19:00:00" : 0
    },
    {
      "08:00:00" : 4, # Wednesday
      "19:00:00" : 0
    },
    {
      "08:00:00" : 4, # Thursday
      "19:00:00" : 0
    },
    {
      "08:00:00" : 4, # Friday
      "19:00:00" : 0
    },
    {} # Saturday
  ]
}

fabric_profile_sku_name = "Standard_D2d_v5"

maximum_concurrency = 4
