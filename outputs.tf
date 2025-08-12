# outputs.tf — zero vars, uses concrete resources

# Region data source (no vars, safe to keep here)
data "aws_region" "current" {}

# S3 bucket name used by the backend
output "bootstrap_bucket" {
  description = "Name of the S3 bucket for remote state"
  value       = aws_s3_bucket.tf_backend.bucket
}

# Exact key your backend uses for the state file
output "bootstrap_key" {
  description = "Key (path) of the remote state file"
  value       = "aws-bootstrap/terraform.tfstate"
}

# DynamoDB lock table name
output "bootstrap_dynamodb_table" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.tf_lock.name
}

# Region (no var, no deprecation)
output "bootstrap_region" {
  description = "AWS region for the backend"
  value       = data.aws_region.current.id
}
