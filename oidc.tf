module "oidc-github" {
  source  = "unfunco/oidc-github/aws"
  version = "1.8.1"

  github_repositories = [
    "gsaffouri/eks-deployment:ref:refs/heads/main"
  ]

  attach_admin_policy = true

}






