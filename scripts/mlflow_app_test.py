# Adapted from https://gist.github.com/ryzalk/a1f47ddc8032811ab66841a6a82affe8
# Originally mlflow_sample_script.py

import sys
import mlflow
import random

if __name__ == "__main__":

    mlflow.set_tracking_uri(sys.argv[1])
    tracking_uri = mlflow.get_tracking_uri()
    print("Current tracking uri: {}".format(tracking_uri))

    mlflow.set_experiment(sys.argv[2])
    experiment = mlflow.get_experiment_by_name(sys.argv[2])
    print("Experiment_id: {}".format(experiment.experiment_id))
    print("Artifact Location: {}".format(experiment.artifact_location))

    alpha = float(sys.argv[3]) if len(sys.argv) > 3 else 0.5
    l1_ratio = float(sys.argv[4]) if len(sys.argv) > 4 else 0.5

    with mlflow.start_run():

        print(
            "Dummy parameters: (alpha=%f, l1_ratio=%f)" % (
                alpha, l1_ratio
            )
        )

        mlflow.log_param("alpha", alpha)
        mlflow.log_param("l1_ratio", l1_ratio)

        for step in range(1, 10):
            mlflow.log_metric("integer", step, step=step)
            mlflow.log_metric(
                "loss", random.uniform(0.1, 0.5), step=step
            )

        texts = "This text content should be uploaded to the ECS bucket."
        with open("text_artifact.txt", "w") as f:
            f.write(texts)

        mlflow.log_artifact("text_artifact.txt")

        artifact_uri = mlflow.get_artifact_uri()
        print("Artifact URI: {}".format(artifact_uri))

        mlflow.log_param("artifact_URI", artifact_uri)