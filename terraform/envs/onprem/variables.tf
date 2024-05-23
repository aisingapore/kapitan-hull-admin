variable "namespace" {
	type		= string
	description = "Deployment namespace within the Kubernetes cluster"
}

variable "root_url" {
	type		= string
	description = "Root URL for Mlflow and Coder servers, without the resource header. e.g. 100e-exampleproj.aisingapore.net"
}

variable "artefact_bucket_name" {
	type		= string
	description = "Bucket name where artefacts will be stored"
}

variable "kubeconfig" {
	type		= string
	description = "Location of the kubeconfig of the target Kubernetes cluster"
}

variable "pvc_name" {
	type		= string
	description = "Name of the RWX Persistent Storage Claim to be created"
}

variable "runai_kubeconfig" {
	type	    = string
	description = "Path to the non-initialised kubeconfig for the runai cluster"
}

variable "ecs_access_key" {
	type	    = string
	description = "Access Key ID for ECS"
	default		= ""
}

variable "ecs_secret_key" {
	type	    = string
	description = "Secret Key for ECS"
	default		= ""
}

variable "node_selector_key" {
	type 		= string
	description = "Key for node selector, required if GPU nodes present"
	default     = ""
}

variable "node_selector_value" {
	type 		= string
	description = "Value for node selector, required if GPU nodes present"
	default     = ""
}

variable "coder_auth" {
	type		= string
	description = "Authentication methods for Coder server, either 'oidc' or 'password'"
	
	validation {
		condition	  = contains(["oidc", "password"], var.coder_auth)
		error_message = "Invalid authentication method provided."
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

