
variable "eventhub_namespaces_config" {
  description = "Resource group configuration"
  type        = map(any)
}


variable "tags" {
  description = "Additional tags to associate"
  type        = map(string)
  default     = {}
}

variable "hubs" {
  description = "A list of event hubs to add to namespace."
  type = list(object({
    name              = string
    partitions        = number
    message_retention = number
    consumers         = list(string)
    keys = list(object({
      name   = string
      listen = bool
      send   = bool
    }))
  }))
  default = []
}
