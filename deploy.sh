#!/bin/bash
set -e

if [[ "$1" != "-p" ]]; then
  echo "Usage: ./deploy.sh -p"
  exit 1
fi

echo "🚀 Starting Terraform backend bootstrapping..."

# Step 1: Clean old files and state
echo "🧹 Cleaning previous Terraform junk..."
rm -rf main.tf terraform.tfstate* .terraform.lock.hcl .terraform 

# Step 2: Apply using local config
echo "🔧 Bootstrapping backend infra with local config..."
cp resources/main.local.tf main.tf
terraform init #-backend=false
terraform apply -auto-approve

# Step 3: Get backend bucket name 
BUCKET_NAME=$(terraform output -raw backend_bucket)
# echo "✅ Bucket created: $BUCKET_NAME"

# Step 4: Replace main.tf with remote backend config
echo "📦 Switching to remote backend config..."
cp resources/main.remote.tf main.tf

# Step 5: Updating main.tf with the bucket name
sed -i "s/UPDATE_ME/$BUCKET_NAME/g" main.tf

# Step 6: Init remote backend and migrate state
echo "🔁 Reinitializing Terraform with remote backend..."
terraform init -force-copy

echo "🎉 Backend bootstrapped, state migrated, Terraform is clean. All done!"
