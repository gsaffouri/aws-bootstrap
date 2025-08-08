#!/bin/bash
set -e

if [[ "$1" != "-p" ]]; then
  echo "Usage: ./deploy.sh -p"
  exit 1
fi

echo "🚀 Starting Terraform backend bootstrapping..."

# Step 1: Clean old files
echo "🧹 Cleaning previous Terraform junk..."
rm -f main.tf terraform.tfstate* .terraform.lock.hcl
rm -rf .terraform

# Step 2: Apply using local config
echo "🔧 Bootstrapping backend infra with local config..."
cp resources/main.local.tf main.tf
terraform init #-backend=false
terraform apply -auto-approve

# Step 3: Get backend bucket name
BUCKET_NAME=$(terraform output -raw backend_bucket)
echo "✅ Bucket created: $BUCKET_NAME"

echo "Gracefully exiting..."
exit 0

# Step 4: Replace main.tf with remote backend config
echo "📦 Switching to remote backend config..."
cp main.remote.tf main.tf
sed -i "s/UPDATE_ME/$BUCKET_NAME/g" main.tf

# 🚨 Step 5: REMOVE main.local.tf BEFORE next init
echo "❌ Deleting main.local.tf to avoid duplicate resource errors..."
rm -f main.local.tf

# Step 6: Init remote backend and migrate state
echo "🔁 Reinitializing Terraform with remote backend..."
terraform init -force-copy

# Optional: clean up main.tf to leave repo spotless
echo "🧽 Removing temporary working file main.tf..."
rm -f main.tf

echo "🎉 Backend bootstrapped, state migrated, Terraform is clean. All done!"
