provider "helm" {
  kubernetes {
    config_path = pathexpand(var.kubeconfig)
  }
}

provider "kubernetes" {
  config_path = pathexpand(var.kubeconfig)
}

resource "random_password" "coder-pg-password" {
  length  = 12
  special = false
}

resource "helm_release" "coder-postgres-database" {
  chart      = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  name       = "coder-db"
  namespace  = var.namespace

  set {
    name  = "auth.username"
    value = "coder"
    type  = "string"
  }

  set {
    name  = "auth.password"
    value = random_password.coder-pg-password.result
    type  = "string"
  }

  set {
    name  = "auth.database"
    value = "coder"
    type  = "string"
  }
  
  set {
    name  = "primary.persistence.size"
    value = "5Gi"
    type  = "string"
  }

  set {
    name  = "resource.limits.cpu"
    value = "1"
    type  = "string"
  }
  set {
    name  = "resources.limits.memory"
    value = "1Gi"
    type  = "string"
  }

  dynamic "set" {
    for_each = var.node_selector_key != "" ? [[var.node_selector_key, var.node_selector_value]] : []
    content {
      name = format("primary.nodeSelector.%s", set.value[0])
      value = set.value[1]
      type = "string"
    }
  }
  
  set {
    name = "image.pullPolicy"
    value = "Always"
    type = "string"
  }
}

resource "kubernetes_secret" "coder-db-url" {
  metadata {
    name      = "coder-db-url"
    namespace = var.namespace
  }

  data = {
    url = format(
      "postgres://coder:%s@coder-db-postgresql.%s.svc.cluster.local:5432/coder?sslmode=disable",
      random_password.coder-pg-password.result,
      var.namespace
    )
  }
}

resource "helm_release" "coder-server" {
  chart      = "coder"
  repository = "https://helm.coder.com/v2"
  name       = "coder-server"
  namespace  = var.namespace

  values = [
    file("${path.module}/values.yaml")
  ]

  set {
    name  = "coder.ingress.host"
    value = var.coder_url
    type  = "string"
  }

  set {
    name  = "coder.env[2].value"
    value = format("https://%s", var.coder_url)
    type  = "string"
  }

  set {
    name  = "coder.ingress.wildcardHost"
    value = format("*-%s", var.coder_url)
    type  = "string"
  }

  set {
    name  = "coder.env[3].value"
    value = format("*-%s", var.coder_url)
  }

  set {
    name  = "coder.image.repo"
    value = var.coder_image
    type  = "string"
  }

  set {
    name  = "coder.image.tag"
    value = var.coder_image_tag
    type  = "string"
  }

  set {
    name = "coder.image.pullPolicy"
    value = "Always"
    type = "string"
  }

  dynamic "set" {
    for_each = var.node_selector_key != "" ? [[var.node_selector_key, var.node_selector_value]] : []
    content {
      name = format("coder.nodeSelector.%s", set.value[0])
      value = set.value[1]
      type = "string"
    }
  }
  
  dynamic "set" {
    for_each = var.auth_method == "oidc" ? ["CODER_OIDC_ISSUER_URL"] : []
    content {
      name  = "coder.env[4].name"
      value = set.value
      type  = "string"
    }
  }

  dynamic "set" {
    for_each = var.auth_method == "oidc" ? [var.oidc_issuer_url] : []
    content {
      name  = "coder.env[4].value"
      value = set.value
      type  = "string"
    }
  }

  dynamic "set" {
    for_each = var.auth_method == "oidc" ? ["CODER_OIDC_EMAIL_DOMAIN"] : []
    content {
      name  = "coder.env[5].name"
      value = set.value
      type  = "string"
    }
  }

  dynamic "set" {
    for_each = var.auth_method == "oidc" ? [var.oidc_email_domain] : []
    content {
      name  = "coder.env[5].value"
      value = set.value
      type  = "string"
    }
  }
  
  dynamic "set" {
    for_each = var.auth_method == "oidc" ? ["CODER_OIDC_CLIENT_ID"] : []
    content {
      name  = "coder.env[6].name"
      value = set.value
      type  = "string"
    }
  }

  dynamic "set" {
    for_each = var.auth_method == "oidc" ? [var.oidc_client_id] : []
    content {
      name  = "coder.env[6].value"
      value = set.value
      type  = "string"
    }
  }

  dynamic "set" {
    for_each = var.auth_method == "oidc" ? ["CODER_OIDC_CLIENT_SECRET"] : []
    content {
      name  = "coder.env[7].name"
      value = set.value
      type  = "string"
    }
  }

  dynamic "set" {
    for_each = var.auth_method == "oidc" ? [var.oidc_client_secret] : []
    content {
      name  = "coder.env[7].value"
      value = set.value
      type  = "string"
    }
  }

  dynamic "set" {
    for_each = var.auth_method == "oidc" ? ["CODER_OIDC_ALLOW_SIGNUPS"] : []
    content {
      name  = "coder.env[8].name"
      value = set.value
      type  = "string"
    }
  }

  dynamic "set" {
    for_each = var.auth_method == "oidc" ? ["false"] : []
    content {
      name  = "coder.env[8].value"
      value = set.value
      type  = "string"
    }
  }
}
