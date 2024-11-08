variable "namespace" {
  type        = string
  description = "Deployment namespace"
}

variable "neo4j_url" {
  type        = string
  description = "Host name for the Neo4j"
}

variable "neo4j_hosts" {
  description = "List of hostnames for Neo4j ingress"
  type        = list(string)
  default     = []
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