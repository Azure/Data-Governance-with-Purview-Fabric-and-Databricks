# Main Terraform outputs

output "resource_group" {
  description = "Resource group information"
  value = {
    id       = azurerm_resource_group.main.id
    name     = azurerm_resource_group.main.name
    location = azurerm_resource_group.main.location
  }
}

output "storage" {
  description = "Storage account information"
  value = {
    id                   = module.storage.id
    name                 = module.storage.name
    primary_blob_endpoint = module.storage.primary_blob_endpoint
    containers           = module.storage.containers
  }
}

output "databricks" {
  description = "Databricks workspace information"
  value = {
    id            = module.databricks.id
    name          = module.databricks.name
    workspace_url = module.databricks.workspace_url
    workspace_id  = module.databricks.workspace_id
  }
}

output "fabric" {
  description = "Fabric capacity information"
  value = {
    id   = module.fabric.id
    name = module.fabric.name
  }
}

output "postgres" {
  description = "PostgreSQL server information"
  value = {
    id            = module.postgres.id
    name          = module.postgres.name
    fqdn          = module.postgres.fqdn
    database_name = module.postgres.database_name
  }
}
