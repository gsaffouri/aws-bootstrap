terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

resource "random_id" "this" {
  byte_length = 4
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create an S3 bucket for Terraform state managements, static s3 naming to help with EKS deployment
resource "aws_s3_bucket" "this_s3_bucket" {
  bucket        = "my-tf-state-bucket-08040627"
  force_destroy = true
  region = "us-east-1"

  tags = {
    Name = "Terraform State Bucket"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backend_sse" {
  bucket = aws_s3_bucket.this_s3_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable versioning on the S3 bucket
resource "aws_s3_bucket_versioning" "backend_versioning" {
  bucket = aws_s3_bucket.this_s3_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# VPC configuration 
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# DynamoDB table for Terraform state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "tf-state-locks-${random_id.this.hex}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = "dev"
    Terraform   = "true"
  }
}

