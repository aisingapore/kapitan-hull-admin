# Adapted from https://gist.github.com/ryzalk/a1f47ddc8032811ab66841a6a82affe8
import os
import mlflow
import hydra
from mlflow.server import get_app_client

@hydra.main(
    version_base=None, 
    config_path="conf", 
    config_name="mlflow.yaml"
)
def main(args):

    args = args["create_exp"]

    if not set(
        ["MLFLOW_TRACKING_PASSWORD", "MLFLOW_TRACKING_USERNAME"]
    ).issubset(list(os.environ)):
        print(
            "MLFLOW_TRACKING_PASSWORD and MLFLOW_TRACKING_USERNAME " + \
            "must be set as environment variables."
        )
        exit(1)

    mlflow.set_tracking_uri(args["tracking_uri"])
    tracking_uri = mlflow.get_tracking_uri()
    print("Current tracking server URI: {}".format(tracking_uri))

    auth_client = get_app_client(
        "basic-auth", tracking_uri=tracking_uri
    )

    client = mlflow.MlflowClient(tracking_uri=tracking_uri)
    print("Creating experiment.")
    experiment_id = client.create_experiment(
        name=args["experiment_name"]
    )

    for user in args["users_to_add"]:
        print("Adding user {} to experiment.".format(user))
        auth_client.create_experiment_permission(
            experiment_id=experiment_id,
            username=user,
            permission=args["permission"])


if __name__ == "__main__":
    main()