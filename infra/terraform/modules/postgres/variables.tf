variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "server_name" {
  description = "PostgreSQL server name override"
  type        = string
  default     = ""
}

variable "admin_user" {
  description = "PostgreSQL administrator username"
  type        = string
}

variable "admin_password" {
  description = "PostgreSQL administrator password"
  type        = string
  sensitive   = true
}

variable "version" {
  description = "PostgreSQL version"
  type        = string
  default     = "16"
}

variable "storage_size_gb" {
  description = "Storage size in GB"
  type        = number
  default     = 64
}

variable "geo_redundant_backup" {
  description = "Geo-redundant backup setting"
  type        = string
  default     = "Disabled"
}

variable "auto_grow" {
  description = "Auto-grow setting"
  type        = string
  default     = "Enabled"
}

variable "sku_name" {
  description = "SKU name"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "sku_tier" {
  description = "SKU tier"
  type        = string
  default     = "GeneralPurpose"
}
