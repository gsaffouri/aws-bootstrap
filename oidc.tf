module "oidc-github" {
  source  = "unfunco/oidc-github/aws"
  version = "1.6.0"

  github_repositories = [
    "gsaffouri/eks-deployment:ref:refs/heads/main"
  ]

  attach_admin_policy = true 

}

# IAM Role for Terraform OIDC Admin
# This role can be assumed by a user or another role that runs Terraform commands
# It allows managing OIDC providers and related IAM resources
# Make sure to replace the Principal with the correct user or role ARN that will run Terraform
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

# IAM Policy for OIDC Admin
# This policy grants permissions to manage OIDC providers and related IAM resources
# Adjust the actions and resources as needed based on your requirements
# Ensure that the policy is attached to the role created above
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

# Attach the OIDC Admin policy to the role
resource "aws_iam_role_policy_attachment" "attach_oidc_admin_policy" {
  role       = aws_iam_role.terraform_oidc_admin.name
  policy_arn = aws_iam_policy.oidc_admin_policy.arn
}




