variable "namespace" {
  type        = string
  description = "Deployment namespace"
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