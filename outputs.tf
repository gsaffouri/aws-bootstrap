# Outputs for the Terraform configuration

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket used for remote state"
  value       = aws_s3_bucket.this_s3_bucket.bucket
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table used for state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "region" {
  description = "AWS region in use"
  value       = "us-east-1"
}
