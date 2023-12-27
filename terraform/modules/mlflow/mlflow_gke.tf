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

