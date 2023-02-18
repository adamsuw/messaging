locals {
  hubs = flatten([
    for namespace, config in var.eventhub_namespaces_config : [
      for hub, settings in config.hubs : {
        namespace_name      = namespace
        resource_group_name = config.resource_group_name
        eventhub_name       = hub
        partition_count     = try(settings.partition_count, 2)
        message_retention   = try(settings.message_retention, 1)
      }
    ]
  ])
 hubs_consumer = flatten(
    [for namespace, config in var.eventhub_namespaces_config :
      [for hub, params in lookup(config, "hubs", {}) :
        "${namespace}|${hub}" if lookup(params, "consumer_group.enabled", false)
      ]
    ]
  )
}

# resource "azurerm_eventhub_cluster" "cluster" {
#   for_each = toset(var.create_dedicated_cluster ? ["enabled"] : [])

#   name                = format("%s-cluster", local.namespace_name)
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   sku_name            = "Dedicated_1"

#   tags = local.tags
# }

resource "azurerm_eventhub_namespace" "this" {
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
  local_authentication_enabled  = try(each.value.local_authentication_enabled, null)
  public_network_access_enabled = try(each.value.public_network_access_enabled, null)
  minimum_tls_version           = try(each.value.minimum_tls_version, null)

  dynamic "identity" {
    for_each = try(each.value.identity, null) == null ? [] : [each.value.identity]
    content {
      type = identity.value.type
    }
  }
  tags = merge(var.extra_tags, local.shared_tags)
}

resource "azurerm_eventhub" "this" {
  for_each = { for i in local.hubs : "${i.eventhub_name}.${i.namespace_name}" => i }

  name                = each.value.eventhub_name
  namespace_name      = each.value.namespace_name
  resource_group_name = each.value.resource_group_name
  partition_count     = each.value.partition_count
  message_retention   = each.value.message_retention
  status              = try(each.value.status, "Active")

#  dynamic "capture_description" {
#    for_each = each.value.capture_description == null ? [] : ["enabled"]
#    for_each = each.value.capture_description == null ? [] : ["enabled"]
#    content {
 #     enabled             = each.value.capture_description.enabled
 #     encoding            = each.value.capture_description.encoding
 #     interval_in_seconds = each.value.capture_description.interval_in_seconds
 #     size_limit_in_bytes = each.value.capture_description.size_limit_in_bytes
 #     skip_empty_archives = each.value.capture_description.skip_empty_archives

 #     destination {
 #       archive_name_format = each.value.capture_description.destination.archive_name_format
 #       blob_container_name = each.value.capture_description.destination.blob_container_name
 #       name                = each.value.capture_description.destination.name
  #      storage_account_id  = each.value.capture_description.destination.storage_account_id
  #    }
 #   }
 # }*/


  depends_on = [azurerm_eventhub_namespace.this]
}

resource "azurerm_eventhub_consumer_group" "eventhub_consumer_group" {
     for a in local.hubs : a.hub_name => a if a.rule == "listen" && a.authorizations.listen
eventhub_name       = azurerm_eventhub.this[each.key].name
  name                = lookup(var.eventhub_namespaces_config[split("|", each.key)[0]]["hubs"][split("|", each.key)[1]], "consumer_group", "default")
  namespace_name      = azurerm_eventhub_namespace.this[each.key].name
  resource_group_name = "messaging-testrg"
  depends_on = [
    azurerm_eventhub.this
  ]
}