# 🚀 Terraform AWS Bootstrap for EKS

<p align="center">
  <a href="https://github.com/gsaffouri/aws-bootstrap/actions">
    <img src="[![CI/CD](https://github.com/gsaffouri/aws-bootstrap/actions/workflows/lint.yml/badge.svg?branch=main&label=CI%2FCD)](https://github.com/gsaffouri/aws-bootstrap/actions)" alt="GitHub Actions">
  </a>
  <img src="https://img.shields.io/badge/Terraform-1.5%2B-blueviolet?logo=terraform&style=flat-square" alt="Terraform Version">
  <img src="https://img.shields.io/badge/AWS%20Ready-%E2%9C%85-green?logo=amazonaws&style=flat-square" alt="AWS Ready">
  <img src="https://img.shields.io/badge/AWS%20Certified-%F0%9F%94%A5-orange?style=flat-square" alt="AWS Certified">
  <img src="https://img.shields.io/badge/Certified%20CKA-%F0%9F%8F%86-blue?style=flat-square" alt="CKA Certified">
  <img src="https://img.shields.io/github/license/gsaffouri_x/aws-bootstrap?style=flat-square" alt="License">
  <img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square" alt="PRs Welcome">
</p>

---

## 📦 Overview

This repository bootstraps an AWS account using Terraform to prepare it for a future EKS (Elastic Kubernetes Service) deployment. It sets up foundational AWS infrastructure and services required for secure, versioned, and lockable Terraform state management, as well as networking primitives via a VPC module..

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

---

## 👨‍💻 About the Author

Built and maintained with 💚 by [gsaffouri](https://github.com/YOUR_USERNAME)  
DevOps Engineer • Terraform Tamer • Kubernetes Commander 🐾

---

## 🛠️ Built With

- 🧱 [Terraform](https://www.terraform.io/)
- ☁️ [AWS](https://aws.amazon.com/)
- 🐳 [Kubernetes (EKS)](https://aws.amazon.com/eks/)
- ⚙️ [GitHub Actions](https://docs.github.com/en/actions)

---

## 🤝 Contributing

Contributions, suggestions, and GitOps-style PRs are welcome!

If you find a bug, or want to add a feature — feel free to open an issue or submit a pull request.  
Let’s build something epic together 🚀

---

## 📬 Contact

Want to connect, collab, or just vibe about infra?

📫 **Email**: g.saffouri@outlook.com  
🐙 **GitHub**: [@gsaffouri](https://github.com/gsaffouri)  
📎 **LinkedIn**: [linkedin.com/in/YOUR_LINK](https://www.linkedin.com/in/saffouri/)

---

<p align="center">
  <em>“I have no failed, I just found 10,000 ways that do not work.”</em> 💥
</p>
