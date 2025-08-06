# main.remote.tf — uses the backend, gets copied after infra exists

terraform {
  backend "s3" {
    bucket         = "UPDATE_ME" # 🔥 gets replaced by script
    key            = "aws-bootstrap/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "tf-state-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "us-east-1"
}
