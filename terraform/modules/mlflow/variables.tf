variable "kubeconfig" {
  type        = string
  description = "Location of the cluster's kubeconfig file"
}

variable "namespace" {
  type        = string
  description = "Deployment namespace"
}

variable "backend_storage" {
  type        = string
  description = "Backend storage configuration for MLflow server; either 'ecs' or 'gcs'"

  validation {
    condition     = contains(["ecs", "gcs"], var.backend_storage)
    error_message = "Invalid backend storage provider provided"
  }
}

variable "artefact_bucket_name" {
  type        = string
  description = "Name of the bucket where artefacts will be stored to"
}

variable "pvc_name" {
  type        = string
  description = "Name of the persistent volume claim that will be mounted to the MLflow server as perstent storage"
}

variable "custom_image" {
  type        = string
  default     = null
  description = "Custom image to be used for the deployment; else defaults to the helm chart defaults"
}

variable "gcp_project_id" {
  type        = string
  description = "Project ID of the GCP project"
}

variable "ingress_hostname" {
  type        = string
  description = "Host name for the MLflow server"
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

