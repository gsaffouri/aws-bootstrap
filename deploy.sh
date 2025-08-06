#!/bin/bash
set -e

if [[ "$1" != "-p" ]]; then
  echo "Usage: ./deploy.sh -p"
  exit 1
fi

echo "🚀 Starting Terraform backend bootstrapping..."

# Step 1: Clean workspace
echo "🧹 Cleaning previous Terraform junk..."
rm -f main.tf terraform.tfstate* .terraform.lock.hcl
rm -rf .terraform

# Step 2: Copy main.local.tf to main.tf and apply locally
echo "🔧 Bootstrapping backend infra with local config..."
cp main.local.tf main.tf
terraform init -backend=false
terraform apply -auto-approve

# Step 3: Get the created bucket name from output
BUCKET_NAME=$(terraform output -raw backend_bucket)
echo "✅ S3 bucket created: $BUCKET_NAME"

# Step 4: Replace local with remote config
echo "📦 Switching to remote backend config..."
cp main.remote.tf main.tf
sed -i "s/UPDATE_ME/$BUCKET_NAME/g" main.tf

# Step 5: Delete main.local.tf to avoid duplicate resource errors
echo "❌ Removing bootstrap config..."
rm -f main.local.tf

# Step 6: Initialize remote backend and migrate state
echo "🔁 Migrating state to S3 remote backend..."
terraform init -force-copy

# Step 7: Optional cleanup
echo "🧽 Removing working main.tf (optional)..."
rm -f main.tf

echo "🎉 Done! Remote backend is live. State is migrated. You're a Terraform beast."
