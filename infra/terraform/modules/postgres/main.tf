# PostgreSQL Flexible Server Module

resource "azurecaf_name" "postgres_server" {
  name          = var.name_prefix
  resource_type = "azurerm_postgresql_flexible_server"
  prefixes      = ["pg"]
  clean_input   = true
}

resource "azurerm_postgresql_flexible_server" "main" {
  name                = var.server_name != "" ? var.server_name : azurecaf_name.postgres_server.result
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  version                      = var.version
  administrator_login          = var.admin_user
  administrator_password       = var.admin_password
  
  sku_name = var.sku_name
  
  storage_mb   = var.storage_size_gb * 1024
  storage_tier = var.sku_tier

  backup_retention_days        = 7
  geo_redundant_backup_enabled = var.geo_redundant_backup == "Enabled"
  
  auto_grow_enabled = var.auto_grow == "Enabled"
  
  public_network_access_enabled = true
  
  authentication {
    password_auth_enabled = true
  }
}

# Database
resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = "datagovernance"
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}
