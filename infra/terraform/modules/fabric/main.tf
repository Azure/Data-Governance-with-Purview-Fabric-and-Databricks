# Microsoft Fabric Capacity Module

resource "azurecaf_name" "fabric_capacity" {
  name          = var.name_prefix
  resource_type = "azurerm_resource_group" # Using resource group naming convention for Fabric
  prefixes      = ["fab"]
  clean_input   = true
}

resource "azapi_resource" "fabric_capacity" {
  type      = "Microsoft.Fabric/capacities@2023-11-01"
  name      = var.capacity_name != "" ? var.capacity_name : azurecaf_name.fabric_capacity.result
  location  = var.location
  parent_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  tags      = var.tags

  body = jsonencode({
    sku = {
      name = var.sku_name
      tier = "Fabric"
    }
    properties = {
      administration = {
        members = var.admin_users
      }
    }
  })
}

data "azurerm_client_config" "current" {}
