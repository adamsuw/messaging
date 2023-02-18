output "namespace_names" {
  description = "Name of Event Hub Namespace."
  value       = [for namespace in azurerm_eventhub_namespace.this : namespace.name]
}

output "namespace_ids" {
  description = "Id of Event Hub Namespace."
  value       = [for namespace in azurerm_eventhub_namespace.this : namespace.id]
}

output "identity" {
  description = "Identity of Event Hub Namespace."
  value       = [for namespace in azurerm_eventhub_namespace.this : namespace.identity]
}

output "hub_ids" {
  description = "Identity of Event Hubs."
  value       = [for hub in azurerm_eventhub.this : hub.id]
}

output "hub_partition_ids" {
  description = "Partition id of Event Hubs."
  value       = [for hub in azurerm_eventhub.this : hub.partition_ids]
}

