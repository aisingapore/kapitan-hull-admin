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

    args = args["create_user"]

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

    auth_client = get_app_client("basic-auth", tracking_uri=tracking_uri)

    auth_client.create_user(
        args["username"], args["password"])

    print("User {} created.".format(args["username"]))


if __name__ == "__main__":
    main()