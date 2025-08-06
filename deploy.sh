#!/bin/bash
set -e

# Flag check
if [[ "$1" != "-p" ]]; then
  echo "Usage: ./deploy.sh -p"
  exit 1
fi

echo "🚀 Starting Terraform backend bootstrapping..."

# Step 1: Clean previous state (just in case)
echo "🧹 Cleaning up previous local TF files..."
rm -f main.tf
rm -f terraform.tfstate*
rm -rf .terraform

# Step 2: Copy the local (bootstrap) config and apply with local state
echo "🔧 Using main.local.tf to create backend resources..."
cp main.local.tf main.tf
terraform init -backend=false
terraform apply -auto-approve

# Step 3: Capture backend bucket name from output
BUCKET_NAME=$(terraform output -raw backend_bucket)
echo "✅ Created S3 bucket: $BUCKET_NAME"

# Step 4: Swap in the remote backend config
echo "📦 Switching to remote backend..."
cp main.remote.tf main.tf
sed -i "s/UPDATE_ME/$BUCKET_NAME/g" main.tf

# Step 5: Initialize remote backend and migrate state
echo "🔁 Migrating state to remote backend..."
terraform init -force-copy

# Step 6: Clean up local bootstrap config
echo "🧼 Cleaning up bootstrap files..."
rm -f main.local.tf

echo "🎉 All done! Remote backend is live and infra is bootstrapped!"
