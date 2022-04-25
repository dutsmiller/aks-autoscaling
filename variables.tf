variable "auto_scaler_profile" {
  description = "Settings to override defaults from https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#auto_scaler_profile ."
  type        = map(string)
  default     = {}
}


variable "create_timeout" {
  description = "Time allowed to create deployment (autoscaling timeout)."
  type        = string
  default     = "10m"
}

variable "deployment_size" {
  description = "Number of replicas in deployment."
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "Maximum number of nodes available to cluster."
  type        = number
  default     = 200
}

variable "node_sku" {
  description = "Sku of scaled nodepool"
  type        = string
  default     = "Standard_B2s"
}

variable "subscription_id" {
  description = "Azure Subscription ID."
  type        = string
}

variable "tags" {
  description = "Tags to be applied to Azure resources."
  type        = map(string)
}
