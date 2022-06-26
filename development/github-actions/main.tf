locals {
  api_repo        = "String-xyz/api"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sigstore", "sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_iam_policy_document" "github_actions_policy" {
  statement {
    sid     = "GrantGithubActionsAccess"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${local.api_repo}:ref:refs/heads/*"
      ]
    }
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.id]
    }
  }
}

resource "aws_iam_role" "ghd_role" {
  name               = "github-actions-deployer"
  assume_role_policy = data.aws_iam_policy_document.github_actions_policy.json
}

data "aws_iam_policy_document" "github_actions" {
  statement {
    actions = [
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecs:UpdateService",
    ]

    # TODO: specific
    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]

    # TODO: specific
    resources = ["*"]
  }
}

resource "aws_iam_policy" "github_actions" {
  name        = "github-actions"
  description = "Grant Github Actions the ability to push"
  policy      = data.aws_iam_policy_document.github_actions.json
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.ghd_role.name
  policy_arn = aws_iam_policy.github_actions.arn
}
