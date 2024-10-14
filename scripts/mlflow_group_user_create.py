import csv
import subprocess
import argparse

from mlflow_create_user import main as create_user
from mlflow_create_experiment import main as create_exp

def create_mlflow_users(csv_file, tracking_uri):
  """Creates MLFlow users from a CSV file."""
  with open(csv_file, 'r') as file:
    reader = csv.DictReader(file)
    for row in reader:
      user = row['aisg_uid'].replace('_', '-')
      create_user(
        {
            "create_user": {
                "tracking_uri": tracking_uri,
                "username": user,
                "password": row['google_password']
            }
        }
      )
      create_exp(
        {
            "create_exp": {
                "tracking_uri": tracking_uri,
                "experiment_name": user,
                "users_to_add": [user],
                "permission": "EDIT"
            }
        }
      )

if __name__ == "__main__":
  parser = argparse.ArgumentParser(description='Create MLFlow users and add default experiment of same name from a CSV file.')
  parser.add_argument('csv_file', help='Path to the CSV file containing \'aisg_uid\' and \'google_password\' columns.')
  parser.add_argument('tracking_uri', help='MLFlow Tracking URI to create the user account')
  args = parser.parse_args()

  create_mlflow_users(args.csv_file, args.tracking_uri)