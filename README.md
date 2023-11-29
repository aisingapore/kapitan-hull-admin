# AI Singapore's End-To-End Platform for 100E Projects

A Helm chart repository for AISG's E2E Platform (Polyaxon & MLFlow).

This repository is to setup the MLFlow server within the K8S cluster 
provided. This has to be installed after the Polyaxon server is set up 
with its persistence storage. Both MLFlow and Polyaxon services have to
be in the same namespace (`polyaxon-v1` by default).

## How to Use

- Check `aisg-e2e-platform/values.yaml` and change the values 
  accordingly.
- Check `run.sh` and see if there're any issues, and simply run 
  `bash run.sh`. Ensure that the target Kubernetes cluster is your 
  current context.
- Check that polyaxon runs 
  (`polyaxon port-forward -p 8888 -n polyaxon-v1 -r aisg-e2e-platform &`)

## Versions Used
- Polyaxon 1.14.3

## Known Issues/Quirks
- This repository only takes into account local storage use. Would need 
  to build it further to dynamically allow GCP installations as well. 
  For now, [Setup Scripts V2](https://gitlab.aisingapore.net/data-engineering/setup-scripts-v2) 
  from the Data Engineering team would suffice with the use of Terraform 
  scripts.
- The image used for MLFlow server deployment requires the use of 
  `ryzalk/mlflow-nginx-server`, which is not an official MLFlow image, 
  or one that is hosted by AISG 

