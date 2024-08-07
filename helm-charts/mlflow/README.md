# mlflow-aisg

![Version: 2.1.2](https://img.shields.io/badge/Version-2.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Deploys MLFlow server with authentication in AISG-managed clusters. Backup cronjobs are also included in the charts.

## Values

| Key                                 | Type   | Default                           | Description                                                                                            |
|-------------------------------------|--------|-----------------------------------|--------------------------------------------------------------------------------------------------------|
| backup.containerName                | string | `"backup-job"`                    | Name of the container of the backup job.                                                               |
| backup.cronjobName                  | string | `"mlflow-sqlitedb-backup"`        | Name of the backup cronjob.                                                                            |
| backup.ecs.args                     | list   | `["aws s3 cp $MLFLOW_DATABASE_PATH s3://$S3_BUCKET/$MLFLOW_BACKUP_PATH/$(TZ='Asia/Singapore' date +\"%d%m%y_%H%M%S\")_mlflow.db"]` | Arguments for the backup job image for a ECS backend. |
| backup.ecs.image                    | string | `"amazon/aws-cli:2.17.24"`        | Image to run the backup job on, for when the tracking server is stored on ECS.                         |
| backup.gcs.args                     | list   | `["gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS; gsutil ls -b gs://$GCS_BUCKET/$MLFLOW_BACKUP_PATH; gsutil cp $MLFLOW_DATABASE_PATH gs://$GCS_BUCKET/$MLFLOW_BACKUP_PATH/$(TZ='Asia/Singapore' date +\"%d%m%y_%H%M%S\")_mlflow.db"]` | Arguments for the backup job image for a GCS backend. |
| backup.gcs.image                    | string | `"google/cloud-sdk:487.0.0-slim"` | Image to run the backup job on, for when the tracking server is stored on GCS.                         |
| backup.path                         | string | `"db-backups"`                    | Path to save the mlflow tracking server backups to.                                                    |
| backup.schedule                     | string | `"30 19 * * 2,4,6"`               | Cron schedule for the backup job. Default: Every Tuesday, Thursday, and Saturday at 7:30pm.            |
| backup.timeoutSec                   | int    | `60`                              | TTL (in seconds) for the jobs spun up by the cronjob schedule.                                         |
| config.artefactBackend              | string | `"ecs"`                           | Define which backend to use to store MLflow artefact, [ecs, gcs].                                      |
| config.authSecretName               | string | `"mlflow-admin-credentials"`      | Name of secret containing basic auth admin credentials.                                                |
| config.backupJob                    | bool   | `true`                            | Enable/Disable backup jobs for database file.                                                          |
| config.bucketName                   | string | `"100e-proj"`                     | Name of bucket that the artifacts and tracking server will write to.                                   |
| config.database.customAuthDBURL     | string | `""`                              | Custom database URL for authentication, if not using the default.                                      |
| config.database.customTrackingDBURL | string | `""`                              | Custom database URL for tracking server, if not using the default.                                     |
| config.database.enableCustom        | bool   | `false`                           | Enable or disable using a custom database URL.                                                         |
| deployment.args                     | list   | `["-w 2","-p 5005"]`              | Arguments to pass to the image.                                                                        |
| deployment.containerName            | string | `"mlflow"`                        | Container name that runs the mlflow-server.                                                            |
| deployment.deploymentName           | string | `"mlflow-deployment"`             | Name of the mlflow-server deployment.                                                                  |
| deployment.image                    | string | `"registry.aisingapore.net/mlops-pub/mlflow-server:stable"` | Image to pull mlflow-server from.                                            |
| deployment.limits                   | object | `{"memory":"2Gi"}`                | Maximum CPU and RAM that the mlflow-servers will be provisioned with.                                  |
| deployment.portName                 | string | `"mlflow"`                        | Name of the port that is to be exposed.                                                                |
| deployment.resources                | object | `{"cpu":"0.5","memory":"2Gi"}`    | Requested CPU and RAM to run the mlflow-server on.                                                     |
| ecs.accessKeyId                     | string | `"accessKeyId"`                   | Name of the key within the Secret that contains the access key ID.                                     |
| ecs.endpointURL                     | string | `"https://necs.nus.edu.sg"`       | Endpoint for ECS.                                                                                      |
| ecs.harborCredentialsName           | string | `"harbor-credentials"`            | Name of Secret that contains credentials to Harbor registry.                                           |
| ecs.s3CredentialsName               | string | `"s3-credentials"`                | Name of Secret that contains credentials to ECS.                                                       |
| ecs.secretAccessKey                 | string | `"secretAccessKey"`               | Name of the key within the Secret that contains the secret access key.                                 |
| gcp.credentialsName                 | string | `"gcp-imagepullsecrets"`          | Name of the Secret that contains the imagePullSecret for MLflow.                                       |
| gcp.projectId                       | string | `"100e-proj-aut0"`                | GCP project ID.                                                                                        |
| gcp.serviceAccount.jsonName         | string | `"gcp-service-account.json"`      | Name of the Service Account json file.                                                                 |
| gcp.serviceAccount.mountPath        | string | `"/var/secret/cloud.google.com"`  | Location to mount the Service Account key to.                                                          |
| gcp.serviceAccount.secretName       | string | `"gcp-sa-credentials"`            | Name of secret that contains the Service Account key.                                                  |
| gcp.serviceAccount.volumeName       | string | `"gcp-service-account"`           | Service account reference name.                                                                        |
| persistent.mountPath                | string | `"/workspace"`                    | Path to mount the Persistent Volume Storage to; use absolute path to specify mount location.           |
| persistent.volumeClaimName          | string | `"mlflow-pvc"`                    | Name of the PersistentVolumeClaim that will be used to mount a volume to the MLflow server.            |
| persistent.volumeName               | string | `"mlflow-persistent-storage"`     | Reference name for volume.                                                                             |
| service.appName                     | string | `"mlflow-server"`                 | Reference labels that will be applied to both Deployment and Service to expose the correct Deployment. |
| service.port                        | int    | `8080`                            | Port at which the service is to be exposed on.                                                         |
| service.protocol                    | string | `"TCP"`                           | Communication protocol for the service.                                                                |
| service.serviceName                 | string | `"mlflow-server-svc"`             | Name of the Service that points to the MLflow server Pods.                                             |
| service.targetPort                  | int    | `5005`                            | Port at which the mlflow-server is exposed on.                                                         |
| service.type                        | string | `"NodePort"`                      | Type of service to create.                                                                             |
| tolerations                         | list   | `[]`                              | Kubernetes tolerations for scheduling pods.                                                            |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.3](https://github.com/norwoodj/helm-docs/releases/v1.11.3)
