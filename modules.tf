module "eventhub" {
  source = "../"
  namespace_name = "demo1namespace1"
  location            = "westus2"
  resource_group_name = "messaging-testrg"
  sku                 = "Standard"
  capacity            = 15
  authorized_ips_or_cidr_blocks = ["103.59.73.254"]
  eventhub_namespaces_hubs = [
    {
      name              = "event-1"
      partitions        = 8
      message_retention = 1
      capture_description = null
        authorizations = {
        listen = true
        send   = true
        manage = false
      }
      consumer_group = {
        enabled       = true
        name          = "cfg-evr2"
        
      }
    },
    {
      name              = "event-2"
      partitions        = 8
      message_retention = 1
      capture_description = null
        authorizations = {
        listen = true
        send   = true
        manage = false
      }
      consumer_group = {
        enabled       = true
        name          = "cfg-evrn"
       
      }
    }
      ]
}
  






locals {

  tags = {
    environment = "development"
  }

}
