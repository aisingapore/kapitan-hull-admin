variable "kubeconfig" {
	type		= string
	description = "Location of the cluster's kubeconfig file"
}

variable "namespace" {
	type		= string
	description = "Deployment kubernetes namespace within the cluster"
}

variable "coder_url" {
	type		= string
	description = "URL of the Coder Server"
}

variable "auth_method" {
	type		= string
	description = "Authentication method for the Coder server; either 'oidc' or 'password'"

	validation {
		condition	  = contains(["oidc", "password"], var.auth_method)
		error_message = "Invalid authentication method provided"
	}
}

variable "oidc_issuer_url" {
	type		= string
	description = "URL for OIDC issuer, required if auth_method is set to 'oidc'"
	default		= ""
}

variable "oidc_email_domain" {
	type		= string
	description = "Valid email domains for OIDC, required if auth_method is set to 'oidc'"
	default		= ""
}

variable "oidc_client_id" {
	type		= string
	description = "Client ID for OIDC, required if auth_method is set to 'oidc'"
	default		= ""
}

variable "oidc_client_secret" {
	type		= string
	description = "Client Secret for OIDC, required if auth_method is set to 'oidc'"
	default		= ""
}


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
	chart	   = "postgresql"
	repository = "https://charts.bitnami.com/bitnami"
	name	   = "coder-db"
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
}

resource "kubernetes_secret" "coder-db-url" {
	metadata {
		name	  = "coder-db-url"
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

resource "helm_release" "coder" {
	chart	   = "coder"
	repository = "https://helm.coder.com/v2"
	name	   = "coder-server"
	namespace  = var.namespace

	values = [
		"${file("./coder_module/values.yaml")}"
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

	dynamic "set" {
		for_each = var.auth_method == "oidc" ? [1] : [0]
		content {
			name  = "coder.env[3].name"
			value = "CODER_OIDC_ISSUER_URL"
			type  = "string"
		}
	}

	dynamic "set" {
		for_each = var.auth_method == "oidc" ? [var.oidc_issuer_url] : []
		content {
			name  = "coder.env[3].value"
			value = set.value
			type  = "string"
		}
	}

	dynamic "set" {
		for_each = var.auth_method == "oidc" ? [1] : [0]
		content {
			name  = "coder.env[4].name"
			value = "CODER_OIDC_EMAIL_DOMAIN"
			type  = "string"
		}
	}

	dynamic "set" {
		for_each = var.auth_method == "oidc" ? [var.oidc_email_domain] : []
		content {
			name  = "coder.env[4].value"
			value = set.value
			type  = "string"
		}
	}
	
	dynamic "set" {
		for_each = var.auth_method == "oidc" ? [1] : [0]
		content {
			name  = "coder.env[5].name"
			value = "CODER_OIDC_CLIENT_ID"
			type  = "string"
		}
	}

	dynamic "set" {
		for_each = var.auth_method == "oidc" ? [var.oidc_client_id] : []
		content {
			name  = "coder.env[5].value"
			value = set.value
			type  = "string"
		}
	}

	dynamic "set" {
		for_each = var.auth_method == "oidc" ? [1] : [0]
		content {
			name  = "coder.env[6].name"
			value = "CODER_OIDC_CLIENT_SECRET"
			type  = "string"
		}
	}

	dynamic "set" {
		for_each = var.auth_method == "oidc" ? [var.oidc_client_secret] : []
		content {
			name  = "coder.env[6].value"
			value = set.value
			type  = "string"
		}
	}

}

	
