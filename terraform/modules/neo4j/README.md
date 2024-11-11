# Neo4J Terraform Module
This neo4j module subdirectory contains the module configuration in `neo4j.tf` and the variables declared in `variables.tf`.
In addition, there are two YAML files containing key parameters that can be modified by the user to customize the deployment.

## YAML Variables

### values.yaml
This YAML contains the following variables that will be loaded by terraform and override the values included in the `neo4j` `helm-charts` folder
| Variable Name | Description |
| neo4j.passwordFromSecret | Existing secret to use for initial database password (DO NOT CHANGE) |
| neo4j.edition | Neo4j Edition to use (community|enterprise) |
| volumes.data.mode | REQUIRED: specify a volume mode to use for data. Valid values are share|selector|defaultStorageClass|volume|volumeClaimTemplate|dynamic |
| ssl | Section to configure SSL. Remove the entire section from values.yaml to disable SSL . |

### reverse-proxy-values.yaml
This YAML contains the following variables that will be loaded by terraform and override the values included in the `neo4j-reverse-proxy` `helm-charts` folder

| Variable Name | Description |
| serviceName | The service name for neo4j. This service should have the ports 7474 and 7687 open. |
| ingress.enabled | Set this to true to deploy an ingress resource. Beneficial for GKE)
| ingress.annotations | The included annotation is required for `cert-manager` to recognize the ingress resource |
| ingress.host | Host name to use. Leave as empty string, configure instead through `.tfvars` file in `terraform/envs` folder |
| ingress.tls.enabled | Set to true to enable TLS |
| ingress.tls.config | Array containing the required spec for the SSL secret and all the hosts specified in the rules section of an Ingress resource |