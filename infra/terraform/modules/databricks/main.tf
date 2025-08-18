# Azure Databricks Module

resource "azurecaf_name" "databricks_workspace" {
  name          = var.name_prefix
  resource_type = "azurerm_databricks_workspace"
  prefixes      = ["dbw"]
  clean_input   = true
}

resource "azurerm_databricks_workspace" "main" {
  name                = var.workspace_name != "" ? var.workspace_name : azurecaf_name.databricks_workspace.result
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  sku = var.workspace_sku

  managed_resource_group_name = var.managed_resource_group_name != "" ? var.managed_resource_group_name : "${var.resource_group_name}-databricks"

  public_network_access_enabled         = !var.enable_no_public_ip
  network_security_group_rules_required = "NoAzureDatabricksRules"

  custom_parameters {
    no_public_ip = var.enable_no_public_ip
  }
}
