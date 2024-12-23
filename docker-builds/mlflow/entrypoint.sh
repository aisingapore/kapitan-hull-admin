#!/bin/bash

mlflow_config="$PWD/.local/lib/python3.12/site-packages/mlflow/server/auth/basic_auth.ini"

case $ARTIFACT_BACKEND in
    ECS)
        if [[ -z "$AWS_ACCESS_KEY_ID" || -z "$AWS_SECRET_ACCESS_KEY" || -z "$MLFLOW_S3_ENDPOINT_URL" ]]; then 
            echo "Artifact backend set to $ARTIFACT_BACKEND, but the necessary S3 credentials are not found."
            exit 1
        fi
        echo 'Setting up artifact server in ECS S3.'
        unset GOOGLE_APPLICATION_CREDENTIALS;;
    GCS)
        if [[ -z "$GOOGLE_APPLICATION_CREDENTIALS" ]]; then
            echo "Artifact backend set to $ARTIFACT_BACKEND, but the necessary GCS credentials are not found."
            exit 1
        fi
        echo 'Setting up artifact server in Google Cloud Storage.'
        unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY;;
    "")
        echo 'Artifact backend is not set. Defaulting to local filesystem.';;
    *)
        echo 'Unknown artifact backend given. Defaulting to local filesystem.';;
esac

if [[ -n "$AUTH_USERNAME" && -n "$AUTH_PASSWORD" && -n "$AUTH_DATABASE_URL" ]]; then
    sed -i "s/\<admin\>/$AUTH_USERNAME/" $mlflow_config
    sed -i "s/\<password\>/$AUTH_PASSWORD/" $mlflow_config
    sed -i "s+\<sqlite:///basic_auth.db\>+$AUTH_DATABASE_URL+" $mlflow_config
    sed -i 's/\<READ\>/NO_PERMISSIONS/' $mlflow_config
else
    echo "Some/all custom authentication not found; starting with basic authentication."
fi

if [[ -z "$ARTIFACT_URL" ]]; then
    export ARTIFACT_URL=mlruns
fi

if [[ -z "$DATABASE_URL" ]]; then
    export DATABASE_URL='sqlite:///mlflow.db'
else
    mkdir -p $(echo $DATABASE_URL | sed -n 's+.*sqlite:///\(.*\)/mlflow\.db+\1+p')
fi

if [[ -n "$AUTH_USERNAME" && -n "$AUTH_PASSWORD" && -n "$AUTH_DATABASE_URL" ]]; then
    exec mlflow server --app-name basic-auth --artifacts-destination=$ARTIFACT_URL \
        --backend-store-uri=$DATABASE_URL --host 0.0.0.0 "$@"
else
    exec mlflow server --artifacts-destination=$ARTIFACT_URL \
        --backend-store-uri=$DATABASE_URL --host 0.0.0.0 "$@"
fi
