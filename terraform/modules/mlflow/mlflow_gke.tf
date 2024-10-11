provider "helm" {
  kubernetes {
    config_path = pathexpand(var.kubeconfig)
  }
}

provider "kubernetes" {
  config_path = pathexpand(var.kubeconfig)
}

resource "kubernetes_secret" "mlflow-admin-creds" {
  metadata {
    name      = "mlflow-admin-credentials"
    namespace = var.namespace
  }
  
  data = {
    username = "admin"
    password = random_password.mlflow_password.result
  }
}

resource "random_password" "mlflow_password" {
  length  = 16
  special = false
}


resource "helm_release" "mlflow-server" {
  chart     = "https://github.com/aisingapore/kapitan-hull-admin/releases/latest/download/mlflow-aisg-2.2.0.tgz"
  name      = "mlflow-server"
  namespace = var.namespace

  set {
    name  = "config.artifactBackend"
    value = var.backend_storage
    type  = "string"
  }

  set {
    name  = "config.bucketName"
    value = var.artifact_bucket_name
    type  = "string"
  }

  set {
    name  = "persistent.volumeClaimName"
    value = var.pvc_name
    type  = "string"
  }  

  dynamic "set" {
    for_each = var.backend_storage == "gcs" ? [var.gcp_project_id] : []
    content {
      name  = "gcp.projectId"
      value = set.value
      type  = "string"
    }
  }

  set {
    name  = "ingress.hostname"
    value = var.ingress_hostname
    type  = "string"
  }

  dynamic "set" {
    for_each = var.node_selector_key != "" ? [[var.node_selector_key, var.node_selector_value]] : []
    content {
      name = format("nodeSelector.%s", set.value[0])
      value = set.value[1]
      type = "string"
    }
  }
  
  dynamic "set" {
    for_each = var.custom_image != null ? [var.custom_image] : []
    content {
      name  = "deployment.image"
      value = set.value
      type  = "string"
    }
  }
}

