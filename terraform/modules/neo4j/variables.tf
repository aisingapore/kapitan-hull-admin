variable "namespace" {
  type        = string
  description = "Deployment namespace"
}


variable "neo4j_cluster_name" {
  type        = string
  description = "Name of your cluster"
}

variable "storage_mode" {
  type = string
  description = "REQUIRED: specify a volume mode to use for data. Valid values are share|selector|defaultStorageClass|volume|volumeClaimTemplate|dynamic"
}

variable "service_type" {
  type = string
  description = "Type of service to use. Use NodePort for deploying on GKE with Ingress"
}

variable "service_name" {
  type = string
  description = "Name of the kubernetes service. This service should have the ports 7474 and 7687 open."
}

variable "node_selector_key" {
  type        = string
  description = "Key for node selector, required if GPU nodes present"
  default     = ""
}

variable "node_selector_value" {
  type        = string
  description = "Value for node selector, required if GPU nodes present"
  default     = ""
}