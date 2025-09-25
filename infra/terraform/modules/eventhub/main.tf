resource "azurecaf_name" "eventhub_ns" {
  name          = var.name_prefix
  resource_type = "azurerm_eventhub_namespace"
  prefixes      = ["eh"]
  clean_input   = true
}

resource "azurerm_eventhub_namespace" "main" {
  name                = var.namespace_name != "" ? var.namespace_name : azurecaf_name.eventhub_ns.result
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku_name
  capacity            = var.capacity
  tags                = var.tags
  auto_inflate_enabled = false
  kafka_enabled        = true
  minimum_tls_version  = "1.2"
}

resource "azurerm_eventhub" "main" {
  name                = var.eventhub_name
  namespace_name      = azurerm_eventhub_namespace.main.name
  resource_group_name = var.resource_group_name
  partition_count     = var.partition_count
  message_retention   = var.message_retention_days

  dynamic "capture_description" {
    for_each = var.capture_enabled && var.capture_storage_account_id != "" ? [1] : []
    content {
      enabled  = true
      encoding = var.capture_encoding
      interval_in_seconds = var.capture_interval_seconds
      size_limit_in_bytes = var.capture_size_limit_bytes
      destination {
        name                = "EventHubArchive.AzureBlockBlob"
        archive_name_format = var.capture_archive_name_format
        blob_container_name = var.capture_container_name
        storage_account_id  = var.capture_storage_account_id
      }
    }
  }
}

resource "azurerm_eventhub_consumer_group" "groups" {
  for_each            = toset(var.consumer_groups)
  name                = each.value
  namespace_name      = azurerm_eventhub_namespace.main.name
  eventhub_name       = azurerm_eventhub.main.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_eventhub_namespace_authorization_rule" "root_manage" {
  name                = "RootManageSharedAccessKey"
  namespace_name      = azurerm_eventhub_namespace.main.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = true
  manage              = true
}

output "namespace_id" {
  value = azurerm_eventhub_namespace.main.id
}

output "namespace_name" {
  value = azurerm_eventhub_namespace.main.name
}

output "eventhub_name" {
  value = azurerm_eventhub.main.name
}

output "consumer_groups" {
  value = [for cg in azurerm_eventhub_consumer_group.groups : cg.name]
}

output "primary_connection_string" {
  value       = azurerm_eventhub_namespace_authorization_rule.root_manage.primary_connection_string
  sensitive   = true
  description = "Primary connection string for namespace"
}