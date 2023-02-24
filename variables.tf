variable "eventhub_namespaces_hubs" {
  type        = any
  description = "Map to handle Eventhub creation. It supports the creation of the hubs, authorization_rule associated with each namespace you create"
}

variable "namespace_name" {
  type        = string
  description = "Namespace name"
}

variable "resource_group_name" {
  type        = string
  description = "The resource group where to deploy the EventHub Namespace."
}

variable "location" {
  type        = string
  description = "Specifies the supported Azure location where the resource exists."
}

variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource"
  default     = {}
}

variable "sku" {
  type        = string
  description = "Defines which tier to use. Valid options are Basic or Standard."
  validation {
    condition     = (var.sku == "Basic" || var.sku == "Standard")
    error_message = "Invalid sku. Valid options for sku are Basic or Standard."
  }
}

variable "capacity" {
  type        = number
  description = "Specifies the Capacity / Throughput Units. Maximum value could be 20."
  validation {
    condition     = var.capacity >= 1 && var.capacity <= 20
    error_message = "The Capacity of the Eventhub Namespace must be between 1 and 20."
  }
}

variable "maximum_throughput_units" {
  type        = number
  description = "Specifies the maximum number of throughput units when Auto Inflate is Enabled. Valid values range from 1 - 20. This  option will enable 'Auto Inflate' capability of Eventhub namespace'"
  validation {
    condition = (
      var.maximum_throughput_units == null ||
    coalesce(var.maximum_throughput_units, 1) >= 1 && coalesce(var.maximum_throughput_units, 20) <= 20)
    error_message = "The Max. throughput units of the Eventhub Namespace must be between 1 and 20."
  }
  default = null
}

variable "zone_redundant" {
  type        = bool
  description = "Is zone_redundancy enabled for the EventHub Namespace?"
  default     = false
}

variable "authorized_vnet_subnet_ids" {
  type        = list(string)
  description = "IDs of the virtual network subnets authorized to connect to the Eventhub Namespace."
  default     = []
}

variable "authorized_ips_or_cidr_blocks" {
  type        = list(string)
  description = "One or more IP Addresses, or CIDR Blocks which should be able to access the Eventhub Namespace."
  default     = []
}
