# Outputs for the Terraform configuration

# output "vpc_id" {
#   description = "VPC ID"
#   value       = module.vpc.vpc_id
# }

# output "private_subnets" {
#   description = "List of private subnet IDs"
#   value       = module.vpc.private_subnets
# }

# output "public_subnet_ids" {
#   description = "List of public subnet IDs"
#   value       = module.vpc.public_subnets
# }

output "backend_bucket" {
  description = "Name of the S3 bucket used for remote state"
  value       = aws_s3_bucket.tf_backend.bucket
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table used for state locking"
  value       = aws_dynamodb_table.tf_lock.name
}

output "region" {
  description = "AWS region in use"
  value       = "us-east-1"
}
