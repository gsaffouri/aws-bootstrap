# 🚀 Terraform AWS Bootstrap for EKS

This repository bootstraps an AWS account using Terraform to prepare it for a future EKS (Elastic Kubernetes Service) deployment. It sets up foundational AWS infrastructure and services required for secure, versioned, and lockable Terraform state management, as well as networking primitives via a VPC module.

---

## 📦 What This Terraform Configuration Does

This module performs the following setup:

- ✅ Creates a **versioned, encrypted S3 bucket** for storing Terraform state
- ✅ Sets up a **DynamoDB table** for state locking to prevent concurrent modifications
- ✅ Deploys a **custom VPC** using the `terraform-aws-modules/vpc` module
- ✅ Organizes infrastructure using **tags** and randomized resource naming to avoid collisions

---

## 📁 Resources Created

### 1. S3 Bucket for Terraform State

- Dynamically named with a random ID suffix to prevent name conflicts
- `force_destroy = true` for ease of teardown in dev environments
- Server-side encryption using AES-256
- Versioning enabled to support state history

### 2. DynamoDB Table for State Locking

- Table name is also suffixed with a random ID
- `PAY_PER_REQUEST` billing for cost-efficient scaling
- Locking is handled via a simple `LockID` string key

### 3. AWS VPC Module

- Uses [terraform-aws-modules/vpc](https://github.com/terraform-aws-modules/terraform-aws-vpc)
- CIDR block: `10.0.0.0/16`
- 3 Public and 3 Private subnets across `us-east-1a`, `1b`, and `1c`
- NAT Gateway and VPN Gateway enabled
- Tagged for environment and Terraform visibility

---

## 🧠 Prerequisites

Make sure you have the following installed and configured:

- [Terraform ≥ 1.5](https://www.terraform.io/downloads)
- [AWS CLI](https://aws.amazon.com/cli/)
- Properly configured AWS credentials (`~/.aws/credentials` or via environment variables)

---

## ⚙️ Usage

1. Clone this repo:
   ```bash
   git clone https://github.com/YOUR_USERNAME/tf-bootstrap.git
   cd tf-bootstrap
