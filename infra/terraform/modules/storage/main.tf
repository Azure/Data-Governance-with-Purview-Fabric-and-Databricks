# Storage Account Module

resource "azurecaf_name" "storage_account" {
  name          = var.name_prefix
  resource_type = "azurerm_storage_account"
  prefixes      = ["st"]
  clean_input   = true
}

resource "azurerm_storage_account" "main" {
  name                = var.storage_account_name != "" ? var.storage_account_name : azurecaf_name.storage_account.result
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  account_tier             = split("_", var.sku_name)[0]
  account_replication_type = split("_", var.sku_name)[1]
  account_kind            = "StorageV2"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  https_traffic_only_enabled      = true

  public_network_access_enabled = true

  blob_properties {
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
    versioning_enabled = true
  }
}

# Create blob containers
resource "azurerm_storage_container" "containers" {
  for_each = toset(var.containers)
  
  name                 = each.value
  storage_account_name = azurerm_storage_account.main.name
  container_access_type = "private"
}
