provider "helm" {
	kubernetes {
		config_path = pathexpand(var.kubeconfig)
	}
}

provider "kubernetes" {
	config_path = pathexpand(var.kubeconfig)
}

resource "random_password" "neo4j_password" {
  length  = 12
  special = false
}

resource "kubernetes_secret" "neo4j-auth" {
  metadata {
    name      = "neo4j-auth"
    namespace = var.namespace
  }
  
  data = {
    NEO4J_AUTH = base64encode("random_password.neo4j_password.result")
  }
}

# Create empty secret for cert-manager & ingress
resource "kubernetes_secret" "neo4j_ssl" {
  metadata {
    name = "neo4j-ssl"
	  namespace = var.namespace
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = base64encode("")
    "tls.key" = base64encode("")
  }
}

resource "helm_release" "neo4j_reverse_proxy" {
  chart	  = "../../../helm-charts/neo4j-reverse-proxy"
	name	  = "neo4j-reverse-proxy"
	namespace = var.namespace

	values = [
		file("${path.module}/reverse-proxy-values.yaml")
	]

  dynamic "set" {
    for_each = var.node_selector_key != "" ? [[var.node_selector_key, var.node_selector_value]] : []
    content {
      name = format("primary.nodeSelector.%s", set.value[0])
      value = set.value[1]
      type = "string"
    }
  }

  depends_on = [kubernetes_secret.neo4j_ssl]
}

resource "helm_release" "neo4j" {
	chart	  = "../../../helm-charts/neo4j"
	name	  = "neo4j"
	namespace = var.namespace
	
	values = [
		file("${path.module}/values.yaml")
	]

  dynamic "set" {
    for_each = var.node_selector_key != "" ? [[var.node_selector_key, var.node_selector_value]] : []
    content {
      name = format("primary.nodeSelector.%s", set.value[0])
      value = set.value[1]
      type = "string"
    }
  }

  depends_on = [kubernetes_secret.neo4j-auth, kubernetes_secret.neo4j_ssl]
}