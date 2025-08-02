module "oidc-github" {
  source  = "unfunco/oidc-github/aws"
  version = "1.6.0"

  github_repositories = [
    "gsaffouri/eks-deployment:ref:refs/heads/main"
  ]

  attach_admin_policy = true 

}

resource "aws_iam_role" "terraform_oidc_admin" {
  name = "TerraformOIDCAdminRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::058264314541:user/cloud_user"  # 👈 or another user/role who runs Terraform
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "oidc_admin_policy" {
  name        = "OIDCAdminPolicy"
  description = "Allows managing IAM OIDC provider and related resources"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "iam:CreateOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:UpdateOpenIDConnectProviderThumbprint",
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "iam:PutRolePolicy",
          "iam:TagOpenIDConnectProvider"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_oidc_admin_policy" {
  role       = aws_iam_role.terraform_oidc_admin.name
  policy_arn = aws_iam_policy.oidc_admin_policy.arn
}

aws sts assume-role \
  --role-arn arn:aws:iam::058264314541:role/TerraformOIDCAdminRole \
  --role-session-name tf-session
  # 👈 Use this command to assume the role and run Terraform commands with OIDC permissions


