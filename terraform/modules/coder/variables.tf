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

