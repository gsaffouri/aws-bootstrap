#!/bin/bash

set -e

# Flag detection
if [[ "$1" != "-p" ]]; then
  echo "Usage: ./deploy.sh -p"
  exit 1
fi

echo "🚀 Starting Terraform backend bootstrapping..."

# Step 1: Use local config to build backend infra
# Ensure main.local.tf exists
echo "🔧 Initializing with local state..."
cp main.local.tf main.tf
terraform init -backend=false
terraform apply -auto-approve

# Step 2: Capture bucket name
BUCKET_NAME=$(terraform output -raw backend_bucket)
echo "✅ Bucket created: $BUCKET_NAME"

# Step 3: Swap in remote backend config
echo "📦 Switching to remote backend..."
cp main.remote.tf main.tf
sed -i "s/UPDATE_ME/$BUCKET_NAME/g" main.tf

# Step 4: Migrate state to remote
terraform init -force-copy

# Step 5: Done
echo "🎉 Backend initialized & state migrated to S3!"
