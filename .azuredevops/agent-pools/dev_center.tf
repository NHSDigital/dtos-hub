resource "azurerm_resource_group" "dev_center_rg" {
  for_each = var.regions

  name     = "${module.config[each.key].names.resource-group}-${var.application}-networking"
  location = each.key
}

# Although azurerm provider 4.0 can create Dev Center resources, the Managed DevOps Pool module requires an older 3.x version which cannot.
# Consequently we will need to use azapi...

# Prerequisites:
# az provider register --namespace 'Microsoft.DevOpsInfrastructure'
# az provider register --namespace 'Microsoft.DevCenter'

resource "azapi_resource" "dev_center" {
  for_each = var.regions

  type      = "Microsoft.DevCenter/devcenters@2024-08-01-preview"
  name      = module.config[each.key].names.dev-center
  parent_id = azurerm_resource_group.dev_center_rg[each.key].id
  location  = each.key

  body = jsonencode({
    properties = {
      projectCatalogSettings = {
        catalogItemSyncEnableStatus = "Disabled"
      }
    }
  })
}

resource "azapi_resource" "dev_center_project" {
  for_each = var.regions

  type      = "Microsoft.DevCenter/projects@2024-08-01-preview"
  name      = module.config[each.key].names.dev-center-project
  location  = each.key
  parent_id = azurerm_resource_group.dev_center_rg[each.key].id

  body = jsonencode({
    properties = {
      devCenterId = azapi_resource.dev_center[each.key].id,
      displayName = "ado-agents"
    }
  })

  tags = {
    "hidden-title" = "ado-agents"
  }
}
