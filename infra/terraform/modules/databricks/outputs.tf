output "id" {
  description = "Databricks workspace ID"
  value       = azurerm_databricks_workspace.main.id
}

output "name" {
  description = "Databricks workspace name"
  value       = azurerm_databricks_workspace.main.name
}

output "workspace_url" {
  description = "Databricks workspace URL"
  value       = azurerm_databricks_workspace.main.workspace_url
}

output "workspace_id" {
  description = "Databricks workspace ID"
  value       = azurerm_databricks_workspace.main.workspace_id
}
