output "namespace_names" {
  description = "Name of Event Hub Namespace."
  value       = [for namespace in azurerm_eventhub_namespace.namespace : namespace.name]
}

output "namespace_ids" {
  description = "Id of Event Hub Namespace."
  value       = [for namespace in azurerm_eventhub_namespace.namespace : namespace.id]
}

output "identity" {
  description = "Identity of Event Hub Namespace."
  value       = [for namespace in azurerm_eventhub_namespace.namespace : namespace.identity]
}

output "hub_ids" {
  description = "Identity of Event Hubs."
  value       = [for hub in azurerm_eventhub.eventhub : hub.id]
}

output "hub_partition_ids" {
  description = "Partition id of Event Hubs."
  value       = [for hub in azurerm_eventhub.eventhub : hub.partition_ids]
}

