terraform {
  backend "gcs" {}
}

locals {
  harbor_mlflow_repo = "registry.aisingapore.net/mlops-pub/mlflow-server:stable"
  ecs_endpoint       = "https://necs.nus.edu.sg"
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

# RKE Secrets - s3-credentials
resource "kubernetes_secret" "s3-credentials" {
  metadata {
    name      = "s3-credentials"
    namespace = var.namespace
  }

  data = {
    accessKeyId      = var.ecs_access_key
    secretAccessKey  = var.ecs_secret_key
    ecsS3EndpointURL = local.ecs_endpoint
  }
}
  
# create RWX PVC
resource "kubernetes_persistent_volume_claim" "pvc-data-onprem" {
  metadata {
    name      = var.pvc_name
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteMany"]
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
  backend_storage      = "ecs"
  artifact_bucket_name = var.artifact_bucket_name
  namespace            = var.namespace
  pvc_name             = var.pvc_name
  custom_image         = local.harbor_mlflow_repo
  kubeconfig           = var.kubeconfig
  ingress_hostname     = format("mlflow-%s", var.root_url)
  gcp_project_id       = null
  node_selector_key    = var.node_selector_key
  node_selector_value  = var.node_selector_value
}

module "coder-server" {
  source               = "../../modules/coder/"
  kubeconfig           = var.kubeconfig
  namespace            = var.namespace
  coder_image          = "registry.aisingapore.net/mlops-pub/coder"
  coder_url            = format("coder-%s", var.root_url)
  node_selector_key    = var.node_selector_key
  node_selector_value  = var.node_selector_value
  auth_method          = var.coder_auth
  oidc_issuer_url      = var.coder_auth == "oidc" ? var.oidc_issuer_url : null
  oidc_email_domain    = var.coder_auth == "oidc" ? var.oidc_email_domain : null
  oidc_client_id       = var.coder_auth == "oidc" ? var.oidc_client_id : null
  oidc_client_secret   = var.coder_auth == "oidc" ? var.oidc_client_secret : null
}
