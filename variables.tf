variable "busybox_container" {
  description = "Busybox container URI."
  type        = string
  default     = "mcr.microsoft.com/oss/busybox/busybox:1.33.1"

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

variable "subscription_id" {
  description = "Azure Subscription ID."
  type        = string
}

variable "tags" {
  description = "Tags to be applied to Azure resources."
  type        = map(string)
}
