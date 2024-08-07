terraform {
  backend "gcs" {}
}

locals {
  gar_mlflow_repo = "asia-southeast1-docker.pkg.dev/machine-learning-ops/pub-images/mlflow-server:stable"
}

provider "kubernetes" {
  config_path = pathexpand(var.kubeconfig)
}

# generate secrets - runai-sso
resource "kubernetes_secret" "runai-sso" {
  metadata {
    name      = "runai-sso"
    namespace = var.namespace
  }

  data = {
    "runai-sso.yaml" = file(var.runai_kubeconfig)
  }
}

# GKE Secrets - gcp-sa-credentials 
resource "kubernetes_secret" "gcp-credentials" {
  metadata {
    name      = "gcp-sa-credentials"
    namespace = var.namespace
  }

  data = {
    "gcp-service-account.json" = file(var.gcs_credentials)
  }
}

# create RWX PVC
resource "kubernetes_persistent_volume_claim" "pvc-data-gke" {
  metadata {
    name      = var.pvc_name
    namespace = var.namespace
  }
  spec {
    storage_class_name = "fs-std-rwx"
    access_modes       = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1Ti"
      }
    }
  }
  timeouts {
    create = "15m"
  }
}

module "mlflow-server" {
  source               = "../../modules/mlflow/"
  backend_storage      = "gcs"
  artifact_bucket_name = var.artifact_bucket_name
  namespace            = var.namespace
  pvc_name             = var.pvc_name
  custom_image         = local.gar_mlflow_repo
  gcp_project_id       = var.gcp_project_id
  kubeconfig           = var.kubeconfig
  ingress_hostname     = format("mlflow.%s", var.root_url)
  node_selector_key    = var.node_selector_key
  node_selector_value  = var.node_selector_value
}

module "coder-server" {
  source               = "../../modules/coder/"
  kubeconfig           = var.kubeconfig
  namespace            = var.namespace
  coder_url            = format("coder.%s", var.root_url)
  node_selector_key    = var.node_selector_key
  node_selector_value  = var.node_selector_value
  auth_method          = var.coder_auth
  oidc_issuer_url      = var.coder_auth == "oidc" ? var.oidc_issuer_url : null
  oidc_email_domain    = var.coder_auth == "oidc" ? var.oidc_email_domain : null
  oidc_client_id       = var.coder_auth == "oidc" ? var.oidc_client_id : null
  oidc_client_secret   = var.coder_auth == "oidc" ? var.oidc_client_secret : null
}
