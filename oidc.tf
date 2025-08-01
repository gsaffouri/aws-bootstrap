module "oidc-github" {
  source  = "unfunco/oidc-github/aws"
  version = "1.6.0"

  github_repositories = [
    "your-gh-org-or-user/your-eks-repo:ref:refs/heads/main"
  ]

  attach_admin_policy = true # or false if you're defining fine-grained IAM later 
}
