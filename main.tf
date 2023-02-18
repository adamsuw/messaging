resource "azurerm_eventhub_namespace" "namespace" {
  for_each = var.eventhub_namespaces_config != null ? var.eventhub_namespaces_config : {}

  name                          = each.key
  location                      = each.value.location
  resource_group_name           = each.value.resource_group_name
  sku                           = try(each.value.sku, "Standard")
  capacity                      = try(each.value.capacity, 1)
  auto_inflate_enabled          = try(each.value.auto_inflate_enabled, null)
  dedicated_cluster_id          = try(each.value.dedicated_cluster_id, null)
  maximum_throughput_units      = try(each.value.maximum_throughput_units, null)
  zone_redundant                = try(each.value.zone_redundant, null)
  network_rulesets              = try(each.value.network_rulesets, null)
 
  dynamic "identity" {
    for_each = try(each.value.identity, null) == null ? [] : [each.value.identity]
    content {
      type = identity.value.type
    }
  }
  tags = var.tags
}

resource "azurerm_eventhub" "eventhub" {
  for_each = { for i in var.hubs : "${i.eventhub_name}.${i.namespace_name}" => i }

  name                = each.value.eventhub_name
  namespace_name      = each.value.namespace_name
  resource_group_name = each.value.resource_group_name
  partition_count     = each.value.partition_count
  message_retention   = each.value.message_retention
  status              = try(each.value.status, "Active")

  dynamic "capture_description" {
    for_each = try(each.value.capture_description, null) == null ? [] : [each.value.capture_description]
    content {
      enabled             = capture_description.value.enabled
      encoding            = capture_description.value.encoding
      interval_in_seconds = capture_description.value.interval_in_seconds
      size_limit_in_bytes = capture_description.value.size_limit_in_bytes
      skip_empty_archives = capture_description.value.skip_empty_archives
      destination         = capture_description.value.destination
    }
  }

  depends_on = [azurerm_eventhub_namespace.namespace]
}
