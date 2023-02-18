terraform {
  required_version = ">= 0.14.1"
  required_providers {
    azurerm = {
      version = "~> 3.12.0"
    }
  }
}
provider "azurerm" {
  features {}
}