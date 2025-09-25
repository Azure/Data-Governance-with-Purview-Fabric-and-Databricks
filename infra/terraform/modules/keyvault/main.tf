data "azurerm_client_config" "current" {}

resource "azurecaf_name" "kv" {
  name          = var.name_prefix
  resource_type = "azurerm_key_vault"
  prefixes      = ["kv"]
  clean_input   = true
}

resource "azurerm_key_vault" "main" {
  name                       = var.key_vault_name != "" ? var.key_vault_name : azurecaf_name.kv.result
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = var.enable_purge_protection
  soft_delete_retention_days = 90
  enable_rbac_authorization  = true
  tags                       = var.tags
}

resource "azurerm_key_vault_secret" "postgres_admin_password" {
  name         = "postgres-admin-password"
  value        = var.postgres_admin_password
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "eventhub_connection" {
  count        = var.eventhub_connection_string != "" ? 1 : 0
  name         = "eventhub-connection-string"
  value        = var.eventhub_connection_string
  key_vault_id = azurerm_key_vault.main.id
}

output "id" { value = azurerm_key_vault.main.id }
output "name" { value = azurerm_key_vault.main.name }
output "uri"  { value = azurerm_key_vault.main.vault_uri }
output "postgres_secret_name" { value = azurerm_key_vault_secret.postgres_admin_password.name }
output "eventhub_secret_created" { value = var.eventhub_connection_string != "" }