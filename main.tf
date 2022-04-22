data "azurerm_subscription" "current" {}

data "http" "busybox_tags" {
  url = "https://mcr.microsoft.com/v2/oss/busybox/busybox/tags/list"
}

locals {
  busybox_tag       = jsondecode(data.http.busybox_tags.body).tags.0
  busybox_container = "mcr.microsoft.com/oss/busybox/busybox:${local.busybox_tag}"
}

# Random string for resource group 
resource "random_string" "random" {
  length  = 12
  upper   = false
  number  = false
  special = false
}

resource "azurerm_resource_group" "example" {
  name     = random_string.random.result
  location = "eastus"
  tags     = var.tags
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = random_string.random.result
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  dns_prefix = random_string.random.result

  sku_tier = "Paid"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D4_v4"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "scaled" {
  name                  = "scaled"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.example.id
  vm_size               = "Standard_B2s"
  enable_auto_scaling   = true
  min_count             = 1
  max_count             = var.max_nodes

  tags = var.tags
}


output "aks_login" {
  value = "az aks get-credentials --name ${azurerm_kubernetes_cluster.example.name} --resource-group ${azurerm_resource_group.example.name} --subscription ${data.azurerm_subscription.current.display_name}"
}
