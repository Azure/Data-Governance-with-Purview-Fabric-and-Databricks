# Development environment configuration

name     = "dg-dev"
location = "East US"

# Admin credentials
postgres_admin_user     = "pgadmin"
postgres_admin_password = "YourStrong!Passw0rd123"

# Environment and project info
environment = "dev"
project     = "DataGovernance"

# Additional tags
additional_tags = {
  owner       = "DataTeam"
  costCenter  = "IT-DataPlatform"
  environment = "development"
}

# Resource naming overrides (optional)
# resource_group_name          = "rg-datagovernance-dev"
# storage_account_name         = "stdatagovdev001"
# databricks_workspace_name    = "dbw-datagovernance-dev"
# fabric_capacity_name         = "fab-datagovernance-dev"
# postgres_server_name         = "pg-datagovernance-dev"

# Fabric configuration
fabric_sku_name    = "F2"
fabric_admin_users = [
  "admin@contoso.com"
  # Add more admin users as needed
]

# Databricks configuration
databricks_workspace_sku             = "standard"
databricks_enable_no_public_ip       = true
# databricks_managed_resource_group_name = "rg-databricks-managed-dev"

# Storage configuration
storage_sku_name  = "Standard_LRS"
storage_containers = [
  "bronze",
  "silver", 
  "gold",
  "raw",
  "curated",
  "sandbox"
]

# PostgreSQL configuration
postgres_version               = "16"
postgres_storage_size_gb       = 64
postgres_geo_redundant_backup  = "Disabled"
postgres_auto_grow            = "Enabled"
postgres_sku_name             = "Standard_D2s_v3"
postgres_sku_tier             = "GeneralPurpose"
