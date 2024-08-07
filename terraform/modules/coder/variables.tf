variable "coder_image" {
  type        = string
  description = "Image repository for Coder, defaults to ghcr.io; provide custom Harbor repository if deploying to OCP clusters"
  default     = "ghcr.io/coder/coder"
}

variable "coder_image_tag" {
  type        = string
  description = "Image tag for Coder"
  default     = "v2.13.4"
}

variable "kubeconfig" {
  type        = string
  description = "Location of the cluster's kubeconfig file"
}

variable "namespace" {
  type        = string
  description = "Deployment kubernetes namespace within the cluster"
}

variable "coder_url" {
  type        = string
  description = "URL of the Coder Server"
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

variable "auth_method" {
  type        = string
  description = "Authentication method for the Coder server; either 'oidc' or 'password'"

  validation {
    condition     = contains(["oidc", "password"], var.auth_method)
    error_message = "Invalid authentication method provided"
  }
}

variable "oidc_issuer_url" {
  type        = string
  description = "URL for OIDC issuer, required if auth_method is set to 'oidc'"
  default     = ""
}

variable "oidc_email_domain" {
  type        = string
  description = "Valid email domains for OIDC, required if auth_method is set to 'oidc'"
  default     = ""
}

variable "oidc_client_id" {
  type        = string
  description = "Client ID for OIDC, required if auth_method is set to 'oidc'"
  default     = ""
}

variable "oidc_client_secret" {
  type        = string
  description = "Client Secret for OIDC, required if auth_method is set to 'oidc'"
  default     = ""
}

