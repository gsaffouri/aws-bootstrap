# outputs.tf — includes both "bootstrap_*" and legacy "backend_*" names

data "aws_region" "current" {}

# Canonical names
output "bootstrap_bucket" {
  description = "S3 bucket for remote state"
  value       = aws_s3_bucket.tf_backend.bucket
}

output "bootstrap_key" {
  description = "Key (path) of the remote state file"
  value       = "aws-bootstrap/terraform.tfstate"
}

output "bootstrap_dynamodb_table" {
  description = "DynamoDB table for state locking"
  value       = aws_dynamodb_table.tf_lock.name
}

output "bootstrap_region" {
  description = "AWS region for the backend"
  value       = data.aws_region.current.id
}

# ---- Compatibility aliases (what your scripts expect) ----
output "backend_bucket" {
  description = "Compat: same as bootstrap_bucket"
  value       = aws_s3_bucket.tf_backend.bucket
}

output "backend_key" {
  description = "Compat: same as bootstrap_key"
  value       = "aws-bootstrap/terraform.tfstate"
}

output "backend_dynamodb_table" {
  description = "Compat: same as bootstrap_dynamodb_table"
  value       = aws_dynamodb_table.tf_lock.name
}

output "backend_region" {
  description = "Compat: same as bootstrap_region"
  value       = data.aws_region.current.id
}
