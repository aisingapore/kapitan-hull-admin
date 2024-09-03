# Terraform for Kapitan Hull Admin

This subdirectory contains all the necessary terraform files to deploy Kapitan
Hull components onto a Kubernetes cluster in GKE or RKE locally.

In essence, this terraform module will manage the following resources:
- `mlflow-server` Helm chart
- `coder` Helm chart
- `runai-sso.yaml` Kubernetes Secret 
- 1Ti RWX Persistent Volume Claim
- `gcp-credentials` Kubernetes Secret (GKE)
- `s3-credentials` Kubernetes Secret (RKE)

`harbor-credentials` have to be set prior to running the Terraform scripts.

## Pre-requisites

In order to manage the resources, several preparatory work is necessary prior to
deployment.

- (For GCS only) Enabled Filestore API on Goocle Clould Console
- `terraform`, `kubectl` and `helm` CLI tools installed on your local machine
- The target cluster's `kubeconfig` file, this will require permissions to 
create/delete Kubernetes resources.
- A 'un-initialised' `kubeconfig` file for the target runAI namespace, needed 
to login and interact with the runAI backend.
- Google Service Account (SA) credential file to access Google Cloud Storage (GCS)
- `nginx-ingress` and `runAI` has been installed on the cluster
- (Optional) Login credentials for Image registry, Google Artifact Registry 
or AISG's Harbor. This is available for unique deployment circumstances; else, 
the default images resides in publically availabe image repositories.
- (Onprem - OCP) Ensure that the following hostnames are whitelisted:
    - `registry.terraform.io`
    - `releases.hashicorp.com`

## How To Use

1) Navigate to the appropriate subdirectory in the `envs/` subdirectory according to the target environment
```bash
$ cd envs/{target_env}
```
2) Populate the `config.gcs.tfbackend` file for the GCS bucket and prefix path. Please refer to [this section](#gcs-backend) for more information
3) Export the path to the Google SA credential file as `GOOGLE_APPLICATION_CREDENTIALS`

```bash
$ export GOOGLE_APPLICATION_CREDENTIALS=/path/to/the/credential/file
```

3) Initialise the repository with the GCS backend

```bash
envs/{target_env} $ terraform init -backend-config='./config.gcs.tfbackend'
```

4) Populate the required fields in the `gcp.tfvar` or `onprem.tfvars`
5) Plan and inspect the infrastructure that is to be deployed
> Please include an additional `-var gcs_credentials='LOCAL_PATH_TO_GCS_SA_FILE'`
if deploying to GKE.

```bash
envs/{target_env} $ terraform plan \
-var-file='./{target_env}.tfvars' \
-var kubeconfig='LOCAL_LOCATION_OF_CLUSTER_KUBECONFIG_FILE' \
-var runai_kubeconfig='LOCAL_LOCATION_OF_RUNAI_KUBECONFIG_FILE'
```

6) Once satisfied, apply the terraform plan to create the resources
> Please include an additional `-var gcs_credentials='LOCAL_PATH_TO_GCS_SA_FILE'`
if deploying to GKE.

```bash
envs/{target_env} $ terraform apply \
-var-file='./{target_env}.tfvars' \
-var kubeconfig='LOCAL_LOCATION_OF_CLUSTER_KUBECONFIG_FILE' \
-var runai_kubeconfig='LOCAL_LOCATION_OF_RUNAI_KUBECONFIG_FILE'
```

7) To teardown the created resources, repeat steps 5) and 6) with the 
`-destroy` flag

## GCS Backend

This little quirk deserves it's own section to provide the intention behind
this design decision. The initial idea was to have two separate terraform 
backends - `gcs` for 100E projects on GCP and `ecs` for on-premise projects. 

Whilst implementing this module, terraform's native `s3` backend supports
custom endpoints for s3, but terraform was not able to connect to ECS, 
perhaps because of NUS's VPN or some firewall rule. 

Nonetheless, coming up with a workaround would prove to be finicky and sketchy;
thus, the final approach was to consolidate all remote backends to GCS. 

The backends of both on-premise RKE and GKE clusters will be stored in the
`100e-terraform` bucket in the GCP project `machine-learning-ops`. Within
that bucket, two subdirectories `onprem` and `gcp` exists to segregate the
backends location accordingly.

For example, an on-premise RKE backend could look like this - 

```yaml
# envs/onprem/config.gcs.tfbackend
bucket = 100e-terraform
prefix = onprem/project_name/terraform/state
```

And the resulting files, when initialised, would be written to `gcs://100e-terraform/onprem/project_name/terraform/state`.


## `tfvar` Variables

### Common Variables

| Variable Name | Description |
| --- | --- |
| `namespace` | Kubernetes namespace where modules and resources are deployed in |
| `root_url` | Root URL to access `coder` and the `MLflow` server, e.g. 100e-a_project.aisingapore.net |
| `artifact_bucket_name` | Bucket name where MLflow will store model artifacts to |
| `pvc_name` | Name of the 1Ti RWX Persistent Volume Claim that will be created and referenced to |
| `coder_auth` | Authentication method for `coder`, accepts either `password` or `oidc` |

### OIDC Variables

If OIDC is required for coder, the following variables need to be set 

| Variable Name | Description |
| --- | --- |
| `oidc_issuer_url` | Issuer URL for the OIDC application, obtain it from your mlops engineer |
| `oidc_email_domain` | Email domains to allow access during OIDC authentication |
| `oidc_client_id` | Client ID for the OIDC application, obtain it from your mlops engineer |
| `oidc_client_secret` | Client Secret for the OIDC application, obtain from your mlops engineer |

### On-premise Specific Variable(s)

| Variable Name | Description |
| --- | --- |
| `ecs_access_key` | Access Key to the ECS Server, aka `AWS_ACCESS_KEY_ID` |
| `ecs_secret_key` | Secret Key to the ECS Server, aka `AWS_SECRET_ACCESS_KEY` |

### GCP Specific Variable(s)

| Variable Name | Description |
| --- | --- |
| `gcp_project_id` | GCP Project ID of the project that the resources will be deployed in |
| `gcs_credentials` | Local path to the GCP Service Account Key |


### Others 

| Variable Name | Description |
| --- | --- |
| `kubeconfig` | Kubeconfig of the Kubernetes cluster |
| `runai_kubeconfig` | An uninitialised kubeconfig file for runAI, to be populated in `coder` Workspaces |


## Things to note / Caveats
- Commas (`,`) need to be escaped with `//` in the `*.tfvars` files for Helm to parse the values correctly.
