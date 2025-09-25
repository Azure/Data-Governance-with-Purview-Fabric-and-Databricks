# Terraform configuration for Data Governance with Purview, Fabric and Databricks

terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~> 1.2"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    storage {
      public_network_access_enabled = false
    }
  }
}

# Data sources
data "azurerm_client_config" "current" {}

# Locals for naming and tagging
locals {
  name_prefix = "${var.name}-${random_string.suffix.result}"
  
  default_tags = {
    environment      = var.environment
    project         = var.project
    "azd-env-name"  = var.name
  }
  
  all_tags = merge(local.default_tags, var.additional_tags)
}

# Random suffix for unique naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Resource Group
resource "azurecaf_name" "resource_group" {
  name          = local.name_prefix
  resource_type = "azurerm_resource_group"
  prefixes      = ["rg"]
  clean_input   = true
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name != "" ? var.resource_group_name : azurecaf_name.resource_group.result
  location = var.location
  tags     = local.all_tags
}

# Storage Module
module "storage" {
  source = "./modules/storage"
  
  name_prefix           = local.name_prefix
  location             = var.location
  resource_group_name  = azurerm_resource_group.main.name
  tags                 = local.all_tags
  
  storage_account_name = var.storage_account_name
  sku_name            = var.storage_sku_name
  containers          = var.storage_containers
}

# Databricks Module
module "databricks" {
  source = "./modules/databricks"
  
  name_prefix         = local.name_prefix
  location           = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags               = local.all_tags
  
  workspace_name              = var.databricks_workspace_name
  workspace_sku              = var.databricks_workspace_sku
  enable_no_public_ip        = var.databricks_enable_no_public_ip
  managed_resource_group_name = var.databricks_managed_resource_group_name
}

# Fabric Module
module "fabric" {
  source = "./modules/fabric"
  
  name_prefix         = local.name_prefix
  location           = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags               = local.all_tags
  
  capacity_name = var.fabric_capacity_name
  sku_name     = var.fabric_sku_name
  admin_users  = length(var.fabric_admin_users) > 0 ? var.fabric_admin_users : [var.postgres_admin_user]
}

# PostgreSQL Module
module "postgres" {
  source = "./modules/postgres"
  
  name_prefix         = local.name_prefix
  location           = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags               = local.all_tags
  
  server_name              = var.postgres_server_name
  admin_user              = var.postgres_admin_user
  admin_password          = var.postgres_admin_password
  version                 = var.postgres_version
  storage_size_gb         = var.postgres_storage_size_gb
  geo_redundant_backup    = var.postgres_geo_redundant_backup
  auto_grow              = var.postgres_auto_grow
  sku_name               = var.postgres_sku_name
  sku_tier               = var.postgres_sku_tier
}

# Event Hub Module
module "eventhub" {
  source = "./modules/eventhub"

  name_prefix         = local.name_prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.all_tags

  namespace_name             = var.eventhub_namespace_name
  eventhub_name              = var.eventhub_name
  sku_name                   = var.eventhub_sku_name
  capacity                   = var.eventhub_capacity
  partition_count            = var.eventhub_partition_count
  message_retention_days     = var.eventhub_message_retention_days
  consumer_groups            = var.eventhub_consumer_groups
  capture_enabled            = var.eventhub_capture_enabled
  capture_storage_account_id = module.storage.id
  capture_container_name     = var.eventhub_capture_container_name
  capture_interval_seconds   = var.eventhub_capture_interval_seconds
  capture_size_limit_bytes   = var.eventhub_capture_size_limit_bytes
  capture_encoding           = var.eventhub_capture_encoding
  capture_archive_name_format = var.eventhub_capture_archive_name_format
}

# Key Vault Module
module "keyvault" {
  source              = "./modules/keyvault"
  count               = var.enable_key_vault ? 1 : 0
  name_prefix         = local.name_prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.all_tags
  key_vault_name      = var.key_vault_name
  postgres_admin_password   = var.postgres_admin_password
  eventhub_connection_string = module.eventhub.primary_connection_string
}
