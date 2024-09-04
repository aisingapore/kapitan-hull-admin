---
display_name: Kubernetes Workspace (Deployment)
description: Provision Coder workspaces as Kubernetes Deployments
icon: ../../../site/static/icon/k8s.png
maintainer: mlops@aisingapore
tags: [kubernetes, runai, gke, code-server, khull, container]
---

# Remote Development on Kubernetes Pods

Key motivation of this workspace is for developers to live closer to their data whilst standardising the base development OS.
The intention is to provide a workspace for developmental work and where applicable, EDA work.
If you find yourself requiring more than 16GB of RAM to do EDA, you'll be better off employing sampling techniques than blindly
loading your large dataset into memory.

> Note: If you're trying to EDA point clouds, please reach out to your mentor/MLOps engineer for dedicated resources to do so. Don't try to bang your head on this wall; trust us, we've tried to make it work but to no avail.

# Configurables

The following are configurable when creating a new workspace for your own use:
- Number of CPU (2, 4, 6 or 8 cpus)
- RAM allocation (4, 8 or 16GB RAM)

These are configurations are not hardlocked, you'll be able to scale up/down your workspaces as per your workloads.
> Do note that that'll require your workspaces to be restarted, so please safe your work and configs to somewhere persistent prior to doing so.

It is also possible to configure a set amount of run time for your workspace (default: 16 hours); set it to zero 
if you don't intend to turn off your workspaces.


## Workspace Environment

The base image used for this workspace is an Ubuntu 24.04, bundled with several convenience libraries and binaries for your use.
Also attached are a 8GB volume dedicated for your own use, mounted to `/home/coder`. Please use this to store any permanent config, 
for e.g. `.bashrc`, `.conda` and etc, to ensure data persistence. 

Another location where persistent storage is configured is in the 1TB shared workspace, usually located at `/pvc-data`.
You will have read, write and executable (RWX) permissions in the `/pvc-data/workspaces` subdirectory, RWX permission for other
subdirections in the shared workspace will be configured on a case-by-case basis as per your mentor's direction.

Every other directory will be ephemeral.

You will have the rights to run as sudo in your own workspace as well.

tl;dr -
```
/
...
├── home # your own dedicated 8GB home directory at /home/coder, store your config and credentials here
├── miniconda3 # binaries for conda; environment and libraries are stored in /pvc-data/.conda
├── pvc-data # 1TB shared directory with your project team
...
```


### Libraries - Python

Miniconda has been installed in the workspace and the environments and libraries are stored in `/pvc-data/.conda` to
benefit from centralised caching and to provide a consistent, highly-portable and readily available development workspace.
Conda environments that you've created can be shared and activated by other users in the project as well. 

While environment is flexible enough to accomodate most of the common packaging and dependency libraries, we don't dictate nor
enforce any specific methods or direction apart from the typical first principals.

### Binaries

Also included in this workspace are these binaries:
- runai - for interaction with runai, if GPU resources are allocated to your project
- khull - a convenient CLI to orchestrate Docker builds and pushes as a runai job

> runai credentials are stored in your persistent home directory and are persisted when your workspaces shuts down/starts up. Do note that the default validity for your credentials is 30 days. Please log out and log in again if the runai credentials expires.

> If you're trying to run khull in a GCP environment, please include the `--gcp` flag

### Authentication

In addition to your personal runai credentials, a Google Service Account key (SA) is located at `$GOOGLE_APPLICATION_CREDENTIALS`.

By activating this SA, you'll be able to utilise the `gcloud` and `gsutil` CLI to perform various operations in GCP and Google Cloud Storage respectively.
```bash
# Activate the SA
$ gcloud auth activate-service-account --key-file $GOOGLE_APPLICATION_CREDENTIALS

# verify that you're using the correct credentials to perform operations
$ gcloud auth list
```