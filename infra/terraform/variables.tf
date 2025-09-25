# Variables for Terraform configuration

variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "East US"
  
  validation {
    condition = contains([
      "East US", "East US 2", "West Europe", "North Europe", 
      "Central US", "West US 2", "Brazil South", "France Central", 
      "UK South", "Southeast Asia"
    ], var.location)
    error_message = "Location must be one of the supported regions."
  }
}

variable "name" {
  description = "Base name to seed resource names"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project identifier"
  type        = string
  default     = "DataGovernance"
}

variable "additional_tags" {
  description = "Additional tags to merge with default tags"
  type        = map(string)
  default     = {}
}

# PostgreSQL Variables
variable "postgres_admin_user" {
  description = "PostgreSQL administrator login username"
  type        = string
}

variable "postgres_admin_password" {
  description = "PostgreSQL administrator password"
  type        = string
  sensitive   = true
}

# Resource Naming Overrides
variable "resource_group_name" {
  description = "Optional Resource Group name override"
  type        = string
  default     = ""
}

variable "storage_account_name" {
  description = "Optional Storage account name override"
  type        = string
  default     = ""
}

variable "databricks_workspace_name" {
  description = "Optional Databricks workspace name override"
  type        = string
  default     = ""
}

variable "fabric_capacity_name" {
  description = "Optional Fabric capacity name override"
  type        = string
  default     = ""
}

variable "postgres_server_name" {
  description = "Optional PostgreSQL server name override"
  type        = string
  default     = ""
}

# Fabric Configuration
variable "fabric_sku_name" {
  description = "Fabric capacity SKU (F units)"
  type        = string
  default     = "F2"
  
  validation {
    condition     = contains(["F2", "F4", "F8", "F16", "F32", "F64", "F128"], var.fabric_sku_name)
    error_message = "Fabric SKU must be one of F2, F4, F8, F16, F32, F64, F128."
  }
}

variable "fabric_admin_users" {
  description = "Fabric capacity admin users (AAD object IDs or UPNs)"
  type        = list(string)
  default     = []
}

# Databricks Configuration
variable "databricks_workspace_sku" {
  description = "Databricks workspace pricing tier"
  type        = string
  default     = "standard"
  
  validation {
    condition     = contains(["standard", "premium", "trial"], var.databricks_workspace_sku)
    error_message = "Databricks workspace SKU must be standard, premium, or trial."
  }
}

variable "databricks_enable_no_public_ip" {
  description = "Disable public IP for Databricks workspace"
  type        = bool
  default     = true
}

variable "databricks_managed_resource_group_name" {
  description = "Custom managed resource group name for Databricks"
  type        = string
  default     = ""
}

# Storage Configuration
variable "storage_sku_name" {
  description = "Storage account SKU"
  type        = string
  default     = "Standard_LRS"
  
  validation {
    condition = contains([
      "Standard_LRS", "Standard_GRS", "Standard_RAGRS", 
      "Standard_ZRS", "Premium_LRS", "Premium_ZRS"
    ], var.storage_sku_name)
    error_message = "Storage SKU must be one of the supported types."
  }
}

variable "storage_containers" {
  description = "Storage containers to create"
  type        = list(string)
  default     = ["bronze", "silver", "gold", "raw", "curated", "sandbox"]
}

# PostgreSQL Configuration
variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "16"
  
  validation {
    # Added versions 12 and 11 to align with .env (PGAZUREVERSION) and Bicep module which already supports 11-17
    condition     = contains(["16", "15", "14", "13", "12", "11"], var.postgres_version)
    error_message = "PostgreSQL version must be one of: 16, 15, 14, 13, 12, 11."
  }
}

variable "postgres_storage_size_gb" {
  description = "PostgreSQL storage size in GB"
  type        = number
  default     = 64
  
  validation {
    condition     = var.postgres_storage_size_gb >= 32 && var.postgres_storage_size_gb <= 16384
    error_message = "PostgreSQL storage size must be between 32 and 16384 GB."
  }
}

variable "postgres_geo_redundant_backup" {
  description = "PostgreSQL geo-redundant backup setting"
  type        = string
  default     = "Disabled"
  
  validation {
    condition     = contains(["Enabled", "Disabled"], var.postgres_geo_redundant_backup)
    error_message = "PostgreSQL geo-redundant backup must be Enabled or Disabled."
  }
}

variable "postgres_auto_grow" {
  description = "PostgreSQL auto-grow setting"
  type        = string
  default     = "Enabled"
  
  validation {
    condition     = contains(["Enabled", "Disabled"], var.postgres_auto_grow)
    error_message = "PostgreSQL auto-grow must be Enabled or Disabled."
  }
}

variable "postgres_sku_name" {
  description = "PostgreSQL compute SKU name (VM size)"
  type        = string
  default     = "Standard_D2s_v3"
  
  validation {
    condition     = contains(["Burstable_B1ms", "Standard_D2s_v3", "Standard_D4s_v3"], var.postgres_sku_name)
    error_message = "PostgreSQL SKU must be one of the supported VM sizes."
  }
}

variable "postgres_sku_tier" {
  description = "PostgreSQL SKU tier"
  type        = string
  default     = "GeneralPurpose"
  
  validation {
    condition     = contains(["Burstable", "GeneralPurpose", "MemoryOptimized"], var.postgres_sku_tier)
    error_message = "PostgreSQL SKU tier must be Burstable, GeneralPurpose, or MemoryOptimized."
  }
}

# Event Hub Configuration
variable "eventhub_namespace_name" {
  description = "Optional Event Hub namespace name override"
  type        = string
  default     = ""
}

variable "eventhub_name" {
  description = "Event Hub name"
  type        = string
  default     = "market-data"
}

variable "eventhub_sku_name" {
  description = "Event Hub namespace SKU"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic","Standard","Premium"], var.eventhub_sku_name)
    error_message = "Event Hub SKU must be Basic, Standard or Premium."
  }
}

variable "eventhub_capacity" {
  description = "Event Hub namespace capacity (throughput units)"
  type        = number
  default     = 1
}

variable "eventhub_partition_count" {
  description = "Event Hub partition count"
  type        = number
  default     = 2
}

variable "eventhub_message_retention_days" {
  description = "Event Hub message retention days"
  type        = number
  default     = 1
}

variable "eventhub_consumer_groups" {
  description = "Consumer groups to create"
  type        = list(string)
  default     = ["raw-loader","analytics","replay"]
}

variable "eventhub_capture_enabled" {
  description = "Enable capture to Blob Storage"
  type        = bool
  default     = true
}

variable "eventhub_capture_container_name" {
  description = "Blob container for capture (must exist)"
  type        = string
  default     = "ehcapture"
}

variable "eventhub_capture_interval_seconds" {
  description = "Capture interval seconds"
  type        = number
  default     = 300
}

variable "eventhub_capture_size_limit_bytes" {
  description = "Capture size limit bytes"
  type        = number
  default     = 314572800
}

variable "eventhub_capture_encoding" {
  description = "Capture encoding"
  type        = string
  default     = "Avro"
  validation {
    condition     = contains(["Avro","AvroDeflate"], var.eventhub_capture_encoding)
    error_message = "Capture encoding must be Avro or AvroDeflate."
  }
}

variable "eventhub_capture_archive_name_format" {
  description = "Capture archive name format"
  type        = string
  default     = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
}

# Key Vault
variable "key_vault_name" {
  description = "Optional Key Vault name override"
  type        = string
  default     = ""
}

variable "enable_key_vault" {
  description = "Enable Key Vault provisioning"
  type        = bool
  default     = true
}
