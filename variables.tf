variable "teamid" {
  description = "Name of the team/group e.g. devops, dataengineering. Should not be changed after running 'tf apply'"
  type        = string
}

variable "prjid" {
  description = "Name of the project/stack e.g: mystack, nifieks, demoaci. Should not be changed after running 'tf apply'"
  type        = string
}

variable "eventhub_namespaces_config" {
  description = "Resource group configuration"
  type        = map(any)
}


variable "extra_tags" {
  description = "Additional tags to associate"
  type        = map(string)
  default     = {}
}

variable "hubs" {
  description = "A list of event hubs to add to namespace."
  type = list(object({
        name       = optional(string)
    partition_count   = number
    message_retention = optional(number, 7)
    capture_description = optional(object({
      enabled             = optional(bool, true)
      encoding            = string
      interval_in_seconds = optional(number)
      size_limit_in_bytes = optional(number)
      skip_empty_archives = optional(bool)
      destination = object({
        name                = optional(string, "EventHubArchive.AzureBlockBlob")
        archive_name_format = optional(string)
        blob_container_name = string
        storage_account_id  = string
      })
    }))

    consumer_group = optional(object({
      enabled       = optional(bool, false)
      custom_name   = optional(string)
      user_metadata = optional(string)
    }), {})

    authorizations = optional(object({
      listen = optional(bool, true)
      send   = optional(bool, true)
      manage = optional(bool, true)
    }), {})
  }))
  default = []
}

#variable "capture_description" {
#  description = "Capture the streaming data in Event Hubs in an Azure Blob storage or Azure Data Lake Storage."
#  type = object({
#    variables = map(string)
#  })
#  default = null
#}