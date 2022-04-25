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

resource "azurerm_log_analytics_workspace" "example" {
  name                = random_string.random.result
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
}

resource "azurerm_monitor_diagnostic_setting" "example" {
  name                       = "control-plane-workspace"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  target_resource_id         = azurerm_kubernetes_cluster.example.id

  log {
    category = "cluster-autoscaler"
    enabled  = true
    retention_policy {
      enabled = false
      days    = 0
    }
  }
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

  auto_scaler_profile {
    balance_similar_node_groups      = lookup(var.auto_scaler_profile, "balance_similar_node_groups", null)
    expander                         = lookup(var.auto_scaler_profile, "expander", null)
    max_graceful_termination_sec     = lookup(var.auto_scaler_profile, "max_graceful_termination_sec", null)
    max_node_provisioning_time       = lookup(var.auto_scaler_profile, "max_node_provisioning_time", null)
    max_unready_nodes                = lookup(var.auto_scaler_profile, "max_unready_nodes", null)
    max_unready_percentage           = lookup(var.auto_scaler_profile, "max_unready_percentage", null)
    new_pod_scale_up_delay           = lookup(var.auto_scaler_profile, "new_pod_scale_up_delay", null)
    scale_down_delay_after_add       = lookup(var.auto_scaler_profile, "scale_down_delay_after_add", null)
    scale_down_delay_after_delete    = lookup(var.auto_scaler_profile, "scale_down_delay_after_delete", null)
    scale_down_delay_after_failure   = lookup(var.auto_scaler_profile, "scale_down_delay_after_failure", null)
    scan_interval                    = lookup(var.auto_scaler_profile, "scan_interval", null)
    scale_down_unneeded              = lookup(var.auto_scaler_profile, "scale_down_unneeded", null)
    scale_down_unready               = lookup(var.auto_scaler_profile, "scale_down_unready", null)
    scale_down_utilization_threshold = lookup(var.auto_scaler_profile, "scale_down_utilization_threshold", null)
    empty_bulk_delete_max            = lookup(var.auto_scaler_profile, "empty_bulk_delete_max", null)
    skip_nodes_with_local_storage    = lookup(var.auto_scaler_profile, "skip_nodes_with_local_storage", null)
    skip_nodes_with_system_pods      = lookup(var.auto_scaler_profile, "skip_nodes_with_system_pods", null)
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  }


  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "scaled" {
  name                  = "scaled"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.example.id
  vm_size               = var.node_sku
  enable_auto_scaling   = true
  min_count             = 1
  max_count             = var.max_nodes

  tags = var.tags
}


output "aks_login" {
  value = "az aks get-credentials --name ${azurerm_kubernetes_cluster.example.name} --resource-group ${azurerm_resource_group.example.name} --subscription ${data.azurerm_subscription.current.display_name}"
}

output "log_analytics_workspace" {
  value = azurerm_log_analytics_workspace.example.name
}
