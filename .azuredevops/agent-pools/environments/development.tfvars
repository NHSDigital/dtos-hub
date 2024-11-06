environment = "DEV"
regions     = ["uksouth"]

agent_profile_resource_predictions_manual = {
  "time_zone" : "GMT Standard Time",
  "days_data" : [
    {}, # Sunday
    {
      "08:00:00" : 2, # Monday
      "19:00:00" : 0
    },
    {
      "08:00:00" : 2, # Tuesday
      "19:00:00" : 0
    },
    {
      "08:00:00" : 2, # Wednesday
      "19:00:00" : 0
    },
    {
      "08:00:00" : 2, # Thursday
      "19:00:00" : 0
    },
    {
      "08:00:00" : 2, # Friday
      "19:00:00" : 0
    },
    {} # Saturday
  ]
}
