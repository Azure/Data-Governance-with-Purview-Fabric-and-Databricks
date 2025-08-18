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

variable "capacity_name" {
  description = "Fabric capacity name override"
  type        = string
  default     = ""
}

variable "sku_name" {
  description = "Fabric capacity SKU"
  type        = string
  default     = "F2"
}

variable "admin_users" {
  description = "Fabric capacity admin users"
  type        = list(string)
}
