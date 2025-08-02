#!/bin/bash -e

# Adds custom flag(s) to script
while getopts 'pfud' OPTION; do
  case "$OPTION" in
    # This option is used to execute 'terraform apply'
    p)
      argP="push"
      ;;
    # This option is only for the CI GitHub Actions pipeline
    f)
      argF="fmt"
      ;;
    # This option is used to prepare main.tf for existing deployment
    u)
      argU="update"
      ;;
    d)
      argD="destroy"
      ;;
    ?)
      echo "Usage: $(basename $0) [-p] [-f] [-u] [-d]"
      exit 1
      ;;
  esac
done

# Removes temporary files
./cleanup-tf.sh

if [ -n "$argF" ] || [ -n "$argP" ]
then
  # Copies main.tf file using local backend
  cp resources/main-local-backend.tf main.tf
fi

# Executes 'terraform apply' if the '-p' flag is used
if [ -n "$argP" ]
then
  # Initialize and apply terraform
  terraform init
  terraform apply --auto-approve

  # Return remote state s3 bucket name from output
  BUCKET_NAME=$(terraform output -raw aws_s3_bucket)

  # Copies main.tf file using remote backend
  cp resources/main-remote-backend.tf main.tf

  # Update backend block with s3 bucket name
  sed -i "s/UPDATE_ME/$BUCKET_NAME/g" main.tf

  # Copies state data to the s3 bucket
  terraform init -force-copy

  # Removes temporary files
  ./cleanup-tf.sh
fi

# Prepares main.tf if the '-u' flag is used
if [ -n "$argU" ]
then
  # Return remote state s3 bucket name from output
  BUCKET_NAME=$(aws s3 ls | grep terraform-remote-state | cut -d " " -f 3)

  # Copies main.tf file using remote backend
  cp resources/main-remote-backend.tf main.tf

  # Update backend block with s3 bucket name
  sed -i "s/UPDATE_ME/$BUCKET_NAME/g" main.tf

  # Initialized Terraform
  terraform init
fi

# Prepares main.tf if the '-d' flag is used
if [ -n "$argD" ]
then
  # Return remote state s3 bucket name from output
  BUCKET_NAME=$(aws s3 ls | grep terraform-remote-state | cut -d " " -f 3)

  # Copies main.tf file using remote backend
  cp resources/main-remote-backend.tf main.tf

  # Update backend block with s3 bucket name
  sed -i "s/UPDATE_ME/$BUCKET_NAME/g" main.tf

  # Initialize and create local tfstate file
  terraform init
  terraform state pull > terraform.tfstate

  # Copy main.tf with no remote state configured
  cp resources/main-local-backend.tf main.tf

  # Migrate the state from remote to local
  terraform init -migrate-state

  # Empty the S3 bucket
  aws s3api delete-objects --bucket "$BUCKET_NAME" --delete "$(aws s3api list-object-versions --bucket ${BUCKET_NAME} --output=json --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"

  # Destroy resources
  terraform destroy --auto-approve

  # Removes temporary files
  ./cleanup-tf.sh
fi