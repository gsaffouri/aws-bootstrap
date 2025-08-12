#!/usr/bin/env bash
set -euo pipefail
# Usage: ./deploy.sh [-p]   (-p applies; otherwise plan only)

APPLY=0
while getopts ":p" opt; do case $opt in p) APPLY=1 ;; esac; done

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Require committed backend stub in root module
if [[ ! -f "$ROOT/backend.tf" ]]; then
  echo 'ERROR: backend.tf missing. Commit this minimal file first:'
  echo 'terraform { backend "s3" {} }'
  exit 1
fi

# Find the bootstrap repo next door
BOOTSTRAP_DIR=""
for d in "$ROOT/../aws-bootstrap" "$ROOT/../aws-bootstrap-main"; do
  [[ -d "$d" ]] && BOOTSTRAP_DIR="$d" && break
done
[[ -n "$BOOTSTRAP_DIR" ]] || { echo "ERROR: Could not find ../aws-bootstrap (or ../aws-bootstrap-main)"; exit 1; }

echo "[eks] reading values from bootstrap Terraform state..."
# Init bootstrap (read-only)
terraform -chdir="$BOOTSTRAP_DIR" init -reconfigure -input=false >/dev/null

# Discover bucket/table from state (no parsing files, no outputs needed)
S3_ADDR="$(terraform -chdir="$BOOTSTRAP_DIR" state list | grep '^aws_s3_bucket\.' | head -1 || true)"
DDB_ADDR="$(terraform -chdir="$BOOTSTRAP_DIR" state list | grep '^aws_dynamodb_table\.' | head -1 || true)"
if [[ -z "${S3_ADDR}" || -z "${DDB_ADDR}" ]]; then
  echo "ERROR: bootstrap state missing aws_s3_bucket or aws_dynamodb_table. Did you run aws-bootstrap/deploy.sh -p?"
  exit 1
fi

BUCKET="$(terraform -chdir="$BOOTSTRAP_DIR" state show "$S3_ADDR" | awk -F ' = ' '/^bucket = /{print $2; exit}' | tr -d '"')"
DYNAMO="$(terraform -chdir="$BOOTSTRAP_DIR" state show "$DDB_ADDR" | awk -F ' = ' '/^name = /{print $2;   exit}' | tr -d '"')"
REGION="$(terraform -chdir="$BOOTSTRAP_DIR" state show "$DDB_ADDR" | awk -F ' = ' '/^arn = /{print $2;    exit}' | sed -E 's/^"arn:aws:dynamodb:([^:]+):.*/\1/' | tr -d '"')"

if [[ -z "${BUCKET}" || -z "${DYNAMO}" || -z "${REGION}" ]]; then
  echo "ERROR: Failed to read bucket/lock-table/region from bootstrap state."
  echo "Got: bucket='${BUCKET:-}', dynamo='${DYNAMO:-}', region='${REGION:-}'"
  exit 1
fi

echo "[eks] backend -> bucket=${BUCKET}  region=${REGION}  ddb=${DYNAMO}"

# Clean init, then plan/apply
rm -rf "$ROOT/.terraform" "$ROOT/.terraform.lock.hcl" "$ROOT/tfplan" || true

terraform -chdir="$ROOT" init -reconfigure -upgrade \
  -backend-config="bucket=${BUCKET}" \
  -backend-config="key=eks-deployment/terraform.tfstate" \
  -backend-config="region=${REGION}" \
  -backend-config="dynamodb_table=${DYNAMO}"

terraform -chdir="$ROOT" fmt -recursive
terraform -chdir="$ROOT" validate
terraform -chdir="$ROOT" plan -out=tfplan -input=false

if [[ $APPLY -eq 1 ]]; then
  terraform -chdir="$ROOT" apply -input=false tfplan
  echo "[eks] done."
else
  echo "[eks] plan ready. Re-run with -p to apply."
fi
