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

variable "workspace_name" {
  description = "Databricks workspace name override"
  type        = string
  default     = ""
}

variable "workspace_sku" {
  description = "Databricks workspace SKU"
  type        = string
  default     = "standard"
}

variable "enable_no_public_ip" {
  description = "Disable public IP"
  type        = bool
  default     = true
}

variable "managed_resource_group_name" {
  description = "Managed resource group name"
  type        = string
  default     = ""
}
