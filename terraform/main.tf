# main entrypoint for terraforms

terraform {
	backend "gcs" {
		bucket = "mlops-dc-bucket"
		prefix = "mock-test/terraform/state"
	}
}

locals {
	gar_mlflow_repo	   = "asia-southeast1-docker.pkg.dev/machine-learning-ops/mlflow-server/v2/mlflow:latest"
	harbor_mlflow_repo = "registry.aisingapore.net/mlops-pub/mlflow-server/mlflow:latest"
	ecs_endpoint	   = "https://necs.nus.edu.sg"
}

provider "kubernetes" {
	config_path = pathexpand(var.kubeconfig)
}

# generate secrets - runai-sso
resource "kubernetes_secret" "runai-sso" {
	metadata {
		name	  = "runai-sso"
		namespace = var.namespace
	}

	data = {
		"runai-sso.yaml" = file(var.runai_kubeconfig)
	}
}

# RKE Secrets - s3-credentials
resource "kubernetes_secret" "gcp-credentials" {
	count = var.target_env == "gke" ? 1 : 0
	metadata {
		name	  = "gcp-sa-credentials"
		namespace = var.namespace
	}

	data = {
		"gcp-service-account.json" = file(var.gcs_credentials)
	}
}

# GKE Secrets - gcp-sa-credentials 
resource "kubernetes_secret" "s3-credentials" {
	count = var.target_env == "rke" ? 1 : 0
	metadata {
		name	  = "s3-credentials"
		namespace = var.namespace
	}

	data = {
		accessKeyId		 = var.ecs_access_key
		secretAccessKey  = var.ecs_secret_key
		ecsS3EndpointURL = local.ecs_endpoint
	}
}
	
# create RWX PVC
resource "kubernetes_persistent_volume_claim" "pvc-data-onprem" {
	count = var.target_env == "rke" ? 1 : 0
	metadata {
		name	  = var.pvc_name
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

resource "kubernetes_persistent_volume_claim" "pvc-data-gke" {
	count = var.target_env == "gke" ? 1 : 0
	metadata {
		name	  = var.pvc_name
		namespace = var.namespace
	}
	spec {
		storage_class_name = "fs-std-rwx"
		access_modes	   = ["ReadWriteMany"]
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
	source				 = "./modules/mlflow/"
	backend_storage		 = var.target_env == "rke" ? "ecs" : "gcs"
	artefact_bucket_name = var.artefact_bucket_name
	namespace			 = var.namespace
	pvc_name			 = var.pvc_name
	custom_image		 = var.target_env == "rke" ? local.harbor_mlflow_repo : local.gar_mlflow_repo
	gcp_project_id		 = var.target_env == "gke" ? var.gcp_project_id : null
	kubeconfig			 = var.kubeconfig
	ingress_hostname     = format("mlflow.%s", var.root_url)
}

module "coder-server" {
	source				 = "./modules/coder/"
	kubeconfig			 = var.kubeconfig
	namespace			 = var.namespace
	coder_url			 = format("coder.%s", var.root_url)
	auth_method			 = var.coder_auth
	oidc_issuer_url		 = var.coder_auth == "oidc" ? var.oidc_issuer_url : null
	oidc_email_domain	 = var.coder_auth == "oidc" ? var.oidc_email_domain : null
	oidc_client_id		 = var.coder_auth == "oidc" ? var.oidc_client_id : null
	oidc_client_secret	 = var.coder_auth == "oidc" ? var.oidc_client_secret : null
}
	

