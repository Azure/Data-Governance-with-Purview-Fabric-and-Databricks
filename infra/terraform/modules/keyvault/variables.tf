variable "name_prefix" {
  description = "Name prefix"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group"
  type        = string
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}

variable "key_vault_name" {
  description = "Key Vault name override"
  type        = string
  default     = ""
}

variable "postgres_admin_password" {
  description = "Postgres admin password to store as secret"
  type        = string
  sensitive   = true
}

variable "eventhub_connection_string" {
  description = "Event Hub connection string (optional)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "enable_purge_protection" {
  description = "Enable purge protection"
  type        = bool
  default     = true
}