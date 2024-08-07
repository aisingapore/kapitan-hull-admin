# code-server-aisg

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Deploys VSCode server with authentication in AISG-managed clusters.

## Values

| Key                       | Type   | Default                                                   | Description                                                                 |
|---------------------------|--------|-----------------------------------------------------------|-----------------------------------------------------------------------------|
| affinity                  | object | `{}`                                                      | Defines pod scheduling rules.                                               |
| codeServer.condaBin       | string | `"/miniconda3/bin/conda"`                                 | Specifies the path to the conda binary.                                     |
| codeServer.homeDir        | string | `"/home/coder"`                                           | Sets the home directory for the VSCode server.                              |
| codeServer.password       | string | `nil`                                                     | Password for authentication to VSCode server.                               |
| codeServer.uid            | int    | `2222`                                                    | Specifies the user ID to run the VSCode server.                             |
| codeServer.user           | string | `nil`                                                     | Username for authentication to VSCode server.                               |
| fullnameOverride          | string | `""`                                                      | Overrides the fully qualified app name.                                     |
| gcp.isGCP                 | bool   | `false`                                                   | Indicates if the deployment is on Google Cloud Platform (GCP).              |
| gcp.saFile                | string | `"gcp-service-account.json"`                              | Service account JSON file for GCP.                                          |
| gcp.saSecretName          | string | `"gcp-sa-credentials"`                                    | Kubernetes secret name for GCP service account credentials.                 |
| image.args[0]             | string | `"--disable-telemetry"`                                   | Argument to disable telemetry for the VSCode server container.              |
| image.args[1]             | string | `"--auth=password"`                                       | Argument to enable password authentication for the VSCode server container. |
| image.pullPolicy          | string | `"Always"`                                                | Policy to use when pulling the container image.                             |
| image.repository          | string | `"registry.aisingapore.net/mlops-pub/code-server:stable"` | Docker image repository for the VSCode server.                              |
| image.tag                 | string | `""`                                                      | Overrides the image tag whose default is usually the chart version.         |
| imagePullSecrets          | list   | `[]`                                                      | List of secrets for pulling images from private registries.                 |
| liveness.enabled          | bool   | `false`                                                   | Enables the liveness probe to check the health of the VSCode server.        |
| liveness.initialDelay     | int    | `30`                                                      | Initial delay before starting the liveness probe.                           |
| liveness.path             | string | `"/healthz"`                                              | Endpoint path for the liveness probe.                                       |
| liveness.periodSeconds    | int    | `30`                                                      | Interval between liveness checks.                                           |
| nameOverride              | string | `""`                                                      | Overrides the chart name.                                                   |
| nodeSelector              | object | `{}`                                                      | Node selection constraints for the VSCode server pods.                      |
| podAnnotations            | object | `{}`                                                      | Annotations to add to the VSCode server pods.                               |
| replicaCount              | int    | `1`                                                       | Number of VSCode server replicas.                                           |
| resources.limits.memory   | string | `"8G"`                                                    | Memory limit for the VSCode server container.                               |
| resources.requests.cpu    | int    | `2`                                                       | CPU request for the VSCode server container.                                |
| resources.requests.memory | string | `"8G"`                                                    | Memory request for the VSCode server container.                             |
| runaiKubeconfig.dir       | string | `".runai_config"`                                         | Directory for the Run:AI configuration.                                     |
| runaiKubeconfig.filename  | string | `"runai-cluster.yaml"`                                    | Filename for the Run:AI Kubeconfig file.                                    |
| runaiKubeconfig.mntPath   | string | `"/etc/runai"`                                            | Mount path for the Run:AI Kubeconfig file.                                  |
| runaiKubeconfig.srcFile   | string | `"runai-cluster-oidc.yaml"`                               | Source file for the Run:AI Kubeconfig.                                      |
| service.port              | int    | `8080`                                                    | Port on which the VSCode server will be exposed.                            |
| tolerations               | list   | `[]`                                                      | Tolerations for pod assignment to nodes with taints.                        |
| volumes.csInitMntPath     | string | `"scripts/"`                                              | Mount path for the VSCode server initialization scripts.                    |
| volumes.gcpsaMntPath      | string | `"/var/secret/cloud.google.com"`                          | Mount path for the GCP service account key.                                 |
| volumes.pvcMntPath        | string | `"/pvc-data"`                                             | Mount path for the persistent volume claim (PVC).                           |
| volumes.pvcName           | string | `"gke-pvc"`                                               | Name of the persistent volume claim (PVC).                                  |
| volumes.runaiSecretName   | string | `"runai-sso"`                                             | Kubernetes secret name for Run:AI SSO credentials.                          |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.3](https://github.com/norwoodj/helm-docs/releases/v1.11.3)
