locals {
  client_id            = "website_s3_gj2l69ckoe"
  lambda_function_name = "lambdaTest"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "default" {
  url = "https://gitlab.com"
  client_id_list = [
    local.client_id,
  ]
  thumbprint_list = ["2b8f1b57330dbba2d07a6c51f70ee90ddab9ad8e"]
}

resource "aws_iam_policy" "policy" {
  name        = "IAMPolicyAccessManagement"
  path        = "/"
  description = "IAM Policy for Access Management"
  policy      = data.aws_iam_policy_document.iampolicy.json
}

data "aws_iam_policy_document" "iampolicy" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.website_s3}"]
    actions   = ["s3:ListBucket"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.website_s3}/*"]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
    ]
  }
}

data "aws_iam_policy_document" "lambdapolicy" {
  statement {
    sid      = ""
    effect   = "Allow"
    resources = ["arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:${aws_lambda_function.test_lambda_function.function_name}"]

    actions = [
      "lambda:UpdateFunctionCode",
      "lambda:GetFunction",
      "lambda:ListVersionsByFunction",
    ]
  }
}

resource "aws_iam_role" "web_identity_role" {
  name                = "Gitlab-identity"
  assume_role_policy  = data.aws_iam_policy_document.web_identity_policy.json
  managed_policy_arns = [aws_iam_policy.policy.arn]
}


data "aws_iam_policy_document" "web_identity_policy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "gitlab.com:aud"
      values   = ["${local.client_id}"]
    }

    principals {
      type        = "Federated"
      identifiers = ["${aws_iam_openid_connect_provider.default.arn}"]
    }
  }
}


