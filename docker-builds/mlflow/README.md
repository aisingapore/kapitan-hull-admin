# MLflow Server

This custom image of the MLflow Server builds on top of the 
`python:3.10-slim-bullseye` image MLflow by adding in 
`google-cloud-storage`, `mlflow` and `boto3` libraries and supports GCS 
and ECS artifact storage. Another reason for this image is to allow for 
easier customisation of authentication credentials. 

## How To Use

To build the image, run:

```bash
$ docker build \
    -t mlflow-server \
    --build-arg MLFLOW_VER=2.13.0 .
```

> Note that the `MLFLOW_VER` argument must be specified for a successful 
> build invocation. Also, to have authentication availiable, mlflow >= 
> 2.5.0.

To run the mlflow server locally on port 5005:

```bash
$ docker run -d -p 5005:5005 mlflow-server
```

The MLflow server can then be accessed from `localhost:5005` on your browser.

## Entrypoint

On top of the pre-defined environment variables that the `mlflow` CLI 
reads from, any compliant flags and arguments to `mlflow server` can 
be passed to the image via the entrypoint script, `entrypoint.sh`.

For more information on the list of available environment variables in 
MLflow, please consult the [official documentation][mlflow-env-var].

Primarily, the `--artifacts-destination` and `--backend-store-uri` 
arguments are passed via the custom environment variables `ARTIFACT_URL` 
and `DATABASE_URI` correspondingly within the entrypoint script.

To set up the server with authentication, the `--app-name basic-auth` 
argument needs to passed to the image during runtime. Check out 
[below](#custom-authentication) on how to configure the authentication 
values for MLflow.

> **Warning:** the image's `CMD` sets the server port at 5005 via the 
> `--port 5005` argument. Deviating from the default `CMD` will result 
> the server to listen on the port 5000. Please include the `--port 
> 5005` into the custom `CMD` if the server is still expected to listen 
> on port 5005.

[mlflow-env-var]: https://mlflow.org/docs/latest/python_api/mlflow.environment_variables.html

## Variables

The following are additional environment variables that can be passed 
to the image for further customisation. 

| Variable Name                    | Details                                                                      |
| -------------------------------- | ---------------------------------------------------------------------------- | 
| `ARTIFACT_BACKEND`               | The backend artifact storage choice. [`ECS`, `GCS`]                          |
| `ARTIFACT_URL`                   | Custom path to MLflow artifact storage                                       | 
| `AUTH_USERNAME`                  | Default Admin username for MLflow, if authentication is enabled              |
| `AUTH_PASSWORD`                  | Default Admin password for MLflow, if authentication is enabled              |
| `AUTH_DATABASE_URL`              | Custom path to storage authentication database, if authentication is enabled |
| `AWS_ACCESS_KEY_ID`              | The access key ID for S3                                                     |
| `AWS_SECRET_ACCESS_KEY`          | Secret key for S3                                                            |
| `DATABASE_URI`                   | Custom path to MLflow tracking server's database                             |
| `GOOGLE_APPLICATION_CREDENTIALS` | Credentials for accessing GCS                                                |

## Image Behavior

### `ARTIFACT_BACKEND`

If `ARTIFACT_BACKEND` is set to `ECS`, a check for `AWS_ACCESS_KEY_ID`,
`AWS_SECRET_ACCESS_KEY` and `MLFLOW_S3_ENDPOINT_URL` is conducted. If
either of these 3 values are **absent**, the server will start with
local artifact storage, i.e. within the container.

> Note: `MLFLOW_S3_ENDPOINT_URL` is a environment variable declared by
MLflow.

Conversely, if `ARTIFACT_BACKEND` is set to `GCS`, 
`GOOGLE_APPLICATION_CREDENTIALS` is checked for and will default to 
local storage if not found.

In the event that credentials for GCS and ECS are set, 
`ARTIFACT_BACKEND` will define where the backend artifact storage is. 
Keep in mind that, in the event that `ARTIFACT_BACKEND` is left empty 
or an unrecognised value is passed, the server will start with local 
artifact storage.

### Custom Authentication

In the event that authentication is required, the `--app-name basic-auth`
argument must be passed when running the image.

e.g. Running a simple MLflow tracking server with authentication on port 5005
```bash
$ docker run --detach --publish 5005:5005 mlflow-server --port 5005 --app-name basic-auth
```

To customise the initial administrative credentials, all three variables -
`AUTH_USERNAME`, `AUTH_PASSWORD` and `AUTH_DATABASE_URL` **must** be
provided. Else, the image will default to the default authentication settings.

Once all three custom values for custom authentication are provided, the
MLflow server is started with all non-admin users having no permissions.
This means that until authorised by an admin, all users will not be able
to create/view/delete experiments nor create/log/delete runs.

> Out of the box, if you have authentication enabled but did not provide custom
authentication credentials, the default username and password are `admin`
and `password` respectively; the authentication database will be located at
`sqlite:///basic_auth.db`. 

To configure the default values, the corresponding
values are to be changed within the `.ini` file at
`$PWD/.local/lib/python3.12/site-packages/mlflow/server/auth/basic_auth.ini`.
For more information, refer to [MLflow's authentication documentation.](https://mlflow.org/docs/latest/auth/index.html)

## Default Values

The following environment variables will be populated accordingly if no
custom values are passed to the image:

* `ARTIFACT_URL`: `./mlruns`
* `DATABASE_URI`: `sqlite:///mlflow.db` (sqlite database at `./mlflow.db`)

