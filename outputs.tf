# --- Bootstrap Outputs ---

output "bootstrap_bucket" {
  description = "Name of the S3 bucket for remote state"
  value       = aws_s3_bucket.this_s3_bucket.bucket
}

output "bootstrap_key" {
  description = "Key (path) of the remote state file"
  value       = "aws-bootstrap/terraform.tfstate"
}

output "bootstrap_region" {
  description = "AWS region for the remote state backend"
  value       = var.aws_region
}

output "bootstrap_dynamodb_table" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

# Optional: EKS Deployment Role ARN for GitHub Actions
output "eks_deployment_role_arn" {
  description = "IAM Role ARN that EKS deployment repo assumes via OIDC"
  value       = aws_iam_role.eks_deployment_role.arn
}
