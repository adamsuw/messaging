resource "azurerm_eventhub" "eventhub" {
  for_each            = local.hubs_list
  name                = each.key
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_eventhub_namespace.ehn.name

  message_retention = each.value.message_retention
  partition_count   = each.value.partitions

  dynamic "capture_description" {
    for_each = each.value.capture_description == null ? [] : ["enabled"]
    content {
      enabled             = each.value.capture_description.enabled
      encoding            = each.value.capture_description.encoding
      interval_in_seconds = each.value.capture_description.interval_in_seconds
      size_limit_in_bytes = each.value.capture_description.size_limit_in_bytes
      skip_empty_archives = each.value.capture_description.skip_empty_archives

      destination {
        archive_name_format = each.value.capture_description.destination.archive_name_format
        blob_container_name = each.value.capture_description.destination.blob_container_name
        name                = each.value.capture_description.destination.name
        storage_account_id  = each.value.capture_description.destination.storage_account_id
    }
  }
}
}

resource "azurerm_eventhub_namespace" "ehn" {
  name                     = "${var.namespace_name}-ns"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  sku                      = var.sku
  auto_inflate_enabled     = local.auto_inflate_enabled
  maximum_throughput_units = var.maximum_throughput_units
  zone_redundant           = local.redundancy
  capacity                 = var.capacity

  identity {
    type = "SystemAssigned"
  }

  dynamic "network_rulesets" {
    for_each = var.sku == "Basic" ? [] : ["true"]
    content {
      default_action                 = "Deny"
      trusted_service_access_enabled = true

      virtual_network_rule = [
        for subnet in var.authorized_vnet_subnet_ids : {
          subnet_id                                       = subnet
          ignore_missing_virtual_network_service_endpoint = false
      }]

      ip_rule = [
        for ip_range in var.authorized_ips_or_cidr_blocks : {
          ip_mask = ip_range
          action  = "Allow"
      }]
    }
  }

  tags = var.tags
}

resource "azurerm_eventhub_namespace_authorization_rule" "reader" {
  for_each            = toset(local.namespaces_reader)
  name                = "${each.key}-reader"
  namespace_name      = azurerm_eventhub_namespace.ehn.name
  resource_group_name = var.resource_group_name

  listen = true
  send   = false
  manage = false
}

resource "azurerm_eventhub_namespace_authorization_rule" "sender" {
  for_each            = toset(local.namespaces_sender)
  name                = "${each.key}-sender"
  namespace_name      = azurerm_eventhub_namespace.ehn.name
  resource_group_name = var.resource_group_name

  listen = false
  send   = true
  manage = false
}

resource "azurerm_eventhub_namespace_authorization_rule" "manage" {
  for_each            = toset(local.namespaces_manage)
  name                = "${each.key}-manage"
  namespace_name      = azurerm_eventhub_namespace.ehn.name
  resource_group_name = var.resource_group_name

  listen = true
  send   = true
  manage = true
}

resource "azurerm_eventhub_consumer_group" "eventhub_consumer_group" {
  for_each = local.consumers
  name                = each.value.name
  namespace_name      = azurerm_eventhub_namespace.ehn.name
  eventhub_name       = each.value.hub
  resource_group_name = var.resource_group_name
  

  depends_on = [
    azurerm_eventhub.eventhub
  ]
}


resource "azurerm_eventhub_authorization_rule" "reader" {
  for_each            = toset(local.hubs_reader)
  name                = "${split("|", each.key)[1]}-reader"
  namespace_name      = azurerm_eventhub_namespace.ehn.name
  eventhub_name       = azurerm_eventhub.eventhub[each.key].name
  resource_group_name = var.resource_group_name

  listen = true
  send   = false
  manage = false
}

resource "azurerm_eventhub_authorization_rule" "sender" {
  for_each            = toset(local.hubs_sender)
  name                = "${split("|", each.key)[1]}-sender"
  namespace_name      = azurerm_eventhub_namespace.ehn.name
  eventhub_name       = azurerm_eventhub.eventhub[each.key].name
  resource_group_name = var.resource_group_name

  listen = false
  send   = true
  manage = false
}

resource "azurerm_eventhub_authorization_rule" "manage" {
  for_each            = toset(local.hubs_manage)
  name                = "${split("|", each.key)[1]}-manage"
  namespace_name      = azurerm_eventhub_namespace.ehn.name
  eventhub_name       = azurerm_eventhub.eventhub[each.key].name
  resource_group_name = var.resource_group_name

  listen = true
  send   = true
  manage = true
}