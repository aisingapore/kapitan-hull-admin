import csv
import subprocess
import argparse

def create_coder_users(csv_file):
  """Creates Coder users from a CSV file."""
  with open(csv_file, 'r') as file:
    reader = csv.DictReader(file)
    for row in reader:
      aisg_uid = row['aisg_uid'].replace('_', '-')
      aisg_email = row['aisg_email']
      command = f"coder users create -u {aisg_uid} -e {aisg_email} --login-type oidc"
      subprocess.run(command, shell=True)

if __name__ == "__main__":
  parser = argparse.ArgumentParser(description='Create Coder users from a CSV file.')
  parser.add_argument('csv_file', help='Path to the CSV file containing \'aisg_uid\' and \'aisg_email\' columns.')
  args = parser.parse_args()

  create_coder_users(args.csv_file)