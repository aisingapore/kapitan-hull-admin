terraform {
  backend "gcs" {}
}

# locals {
#   gar_neo4j_repo = "asia-southeast1-docker.pkg.dev/machine-learning-ops/pub-images/neo4j:5.24.1"
# }

# locals {
#   gar_neo4j_rp_repo = "asia-southeast1-docker.pkg.dev/machine-learning-ops/pub-images/neo4j-reverse-proxy:5.24.1"
# }

provider "kubernetes" {
  config_path = pathexpand(var.kubeconfig)
}

provider "helm" {
  kubernetes {
    config_path = pathexpand(var.kubeconfig)
  }
}

module "neo4j" {
  count = var.enable_neo4j ? 1 : 0
  source = "github.com/aisingapore/kapitan-hull-admin//terraform/modules/neo4j"
  namespace = var.namespace
  ingress_hostname = format("neo4j.%s", var.root_url)
  node_selector_key    = var.node_selector_key
  node_selector_value  = var.node_selector_value
}