module "oidc-github" {
  source  = "unfunco/oidc-github/aws"
  version = "1.6.0"

  github_repositories = [
    "gsaffouri/eks-deployment:ref:refs/heads/main"
  ]

  attach_admin_policy = true # or false if you're defining fine-grained IAM later 

}

# IAM Policy to allow managing OIDC Providers (for GitHub Actions, IRSA, etc.)
resource "aws_iam_policy" "oidc_management_policy" {
  name        = "AllowOIDCProviderManagement"
  description = "Allows creating, reading, updating, and deleting OIDC providers"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "iam:CreateOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:UpdateOpenIDConnectProviderThumbprint"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach the OIDC permissions policy to the IAM user (e.g., cloud_user)
resource "aws_iam_user_policy_attachment" "cloud_user_oidc_attachment" {
  user       = "cloud_user" # 👈 Update if your user is named differently
  policy_arn = aws_iam_policy.oidc_management_policy.arn
}

