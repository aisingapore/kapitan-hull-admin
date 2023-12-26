variable "kubeconfig" {
	type		= string
	description = "Location of the cluster's kubeconfig file"
}

variable "namespace" {
	type		= string
	description = "Deployment namespace"
}

variable "backend_storage" {
	type		= string
	description = "Backend storage configuration for MLflow server; either 'ecs' or 'gcs'"

	validation {
		condition	  = contains(["ecs", "gcs"], var.backend_storage)
		error_message = "Invalid backend storage provider provided"
	}
}

variable "artefact_bucket_name" {
	type		= string
	description = "Name of the bucket where artefacts will be stored to"
}

variable "pvc_name" {
	type		= string
	description = "Name of the persistent volume claim that will be mounted to the MLflow server as perstent storage"
}

variable "custom_image" {
	type		= string
	default		= null
	description = "Custom image to be used for the deployment; else defaults to the helm chart defaults"
}

variable "gcp_project_id" {
	type		= string
	description = "Project ID of the GCP project"
}

variable "ingress_hostname" {
	type	    = string
	description = "Host name for the MLflow server"
}


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
		name	  = "mlflow-admin-credentials"
		namespace = var.namespace
	}
	
	data = {
		username = "admin"
		password = random_password.mlflow_password.result
	}
}

resource "random_password" "mlflow_password" {
	length = 16
	special = false
}


resource "helm_release" "mlflow-server" {
	chart	  = "../helm-charts/mlflow"
	name	  = "mlflow-server"
	namespace = var.namespace

	set {
		name  = "config.artefactBackend"
		value = var.backend_storage
		type  = "string"
	}

	set {
		name  = "config.bucketName"
		value = var.artefact_bucket_name
		type  = "string"
	}

	set {
		name  = "persistent.volumeClaimName"
		value = var.pvc_name
		type  = "string"
	}	

	set {
		name  = "gcp.projectId"
		value = var.gcp_project_id
		type  = "string"
	}

	set {
		name  = "ingress.hostname"
		value = var.ingress_hostname
		type  = "string"
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

