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
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

variable "namespace_name" {
  description = "Event Hub namespace name override"
  type        = string
  default     = ""
}

variable "eventhub_name" {
  description = "Event Hub name"
  type        = string
  default     = "market-data"
}

variable "sku_name" {
  description = "Namespace SKU"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic","Standard","Premium"], var.sku_name)
    error_message = "SKU must be Basic, Standard or Premium."
  }
}

variable "capacity" {
  description = "Throughput units / capacity"
  type        = number
  default     = 1
}

variable "partition_count" {
  description = "Number of partitions"
  type        = number
  default     = 2
}

variable "message_retention_days" {
  description = "Message retention in days"
  type        = number
  default     = 1
}

variable "consumer_groups" {
  description = "List of consumer groups to create"
  type        = list(string)
  default     = []
}

variable "capture_enabled" {
  description = "Enable Capture to Blob Storage"
  type        = bool
  default     = true
}

variable "capture_storage_account_id" {
  description = "Storage Account resource ID for capture destination"
  type        = string
  default     = ""
}

variable "capture_container_name" {
  description = "Blob container for capture"
  type        = string
  default     = "ehcapture"
}

variable "capture_interval_seconds" {
  description = "Capture interval in seconds"
  type        = number
  default     = 300
}

variable "capture_size_limit_bytes" {
  description = "Capture size limit in bytes"
  type        = number
  default     = 314572800
}

variable "capture_encoding" {
  description = "Capture encoding"
  type        = string
  default     = "Avro"
  validation {
    condition     = contains(["Avro","AvroDeflate"], var.capture_encoding)
    error_message = "Capture encoding must be Avro or AvroDeflate."
  }
}

variable "capture_archive_name_format" {
  description = "Archive name format"
  type        = string
  default     = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
}