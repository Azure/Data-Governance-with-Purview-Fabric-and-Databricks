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

variable "storage_account_name" {
  description = "Storage account name override"
  type        = string
  default     = ""
}

variable "sku_name" {
  description = "Storage account SKU"
  type        = string
  default     = "Standard_LRS"
}

variable "containers" {
  description = "Storage containers to create"
  type        = list(string)
  default     = ["raw", "curated", "sandbox"]
}
