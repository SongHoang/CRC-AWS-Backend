locals {
  client_id_s3 = "website_s3_gj2l69ckoe"
  client_id_lambda ="lambda_jgj31"
  lambda_function_name = "lambdaTest"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "default" {
  url = "https://gitlab.com"
  client_id_list = [
    local.client_id_s3,
  ]
  thumbprint_list = ["2b8f1b57330dbba2d07a6c51f70ee90ddab9ad8e"]
}

resource "aws_iam_policy" "policy" {
  name        = "IAMPolicyAccessManagement"
  path        = "/"
  description = "IAM Policy for Access Management"
  policy = data.aws_iam_policy_document.iampolicy.json
}


## Gives gitlab role to do S3 changes
resource "aws_iam_role" "web_identity_role" {
  name = "Gitlab-identity"
  assume_role_policy = data.aws_iam_policy_document.web_identity_policy.json
  managed_policy_arns = [aws_iam_policy.policy.arn]
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


data "aws_iam_policy_document" "web_identity_policy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "gitlab.com:aud"
      values   = ["${local.client_id_s3}"]
    }

    principals {
      type        = "Federated"
      identifiers = ["${aws_iam_openid_connect_provider.default.arn}"]
    }
  }
}

############


## Gives gitlab role to do Lambda

resource "aws_iam_policy" "lambda_policy" {
  name        = "IAMPolicyLambdaManagement"
  path        = "/"
  description = "IAM Policy for Lambda Management"
  policy = data.aws_iam_policy_document.lambdapolicy.json
}

resource "aws_iam_role" "web_identity_role_lambda" {
  name = "Gitlab-Lambda"
  assume_role_policy = data.aws_iam_policy_document.web_identity_policy_lambda.json
  managed_policy_arns = [aws_iam_policy.lambda_policy.arn]
}

data "aws_iam_policy_document" "lambdapolicy" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources  = ["arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:${local.lambda_function_name}"]

    actions = [
      "lambda:UpdateFunctionCode",
      "lambda:GetFunction",
      "lambda:ListVersionsByFunction",
    ]
  }
}
data "aws_iam_policy_document" "web_identity_policy_lambda" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "gitlab.com:aud"
      values   = ["${local.client_id_lambda}"]
    }

    principals {
      type        = "Federated"
      identifiers = ["${aws_iam_openid_connect_provider.default.arn}"]
    }
  }
}