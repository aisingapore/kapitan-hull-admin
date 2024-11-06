variable "namespace" {
  type        = string
  description = "Deployment namespace within the Kubernetes cluster"
}

variable "root_url" {
  type        = string
  description = "Root URL for Mlflow and Coder servers, without the resource header. e.g. 100e-exampleproj.aisingapore.net"
}

variable "enable_neo4j" {
  type    = bool
  description = "Flag to enable the creation of the neo4j module"
  default = false
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

variable "kubeconfig" {
  type        = string
  description = "Location of the kubeconfig of the target Kubernetes cluster"
}


