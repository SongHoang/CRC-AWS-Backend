terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
 
  required_version = ">= 1.2.0"
}



provider "vault" {
  address = "http://localhost:8200"
  token   = "root"
}

data "vault_generic_secret" "aws_credentials" {
  path = "my-secrets/aws"
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_credentials.data["aws_access_key_id"]
  secret_key = data.vault_generic_secret.aws_credentials.data["aws_secret_access_key"]
  region     = "us-east-2"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.website_s3
  tags = {
    Name        = "CRC"
    Environment = "Production"
  }
}
resource "aws_s3_bucket_public_access_block" "my_bucket" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Makes S3 bucket read only for the public
resource "aws_s3_bucket_policy" "my_bucket" {
  bucket     = aws_s3_bucket.my_bucket.id
  policy     = data.aws_iam_policy_document.bucketpolicy.json

  depends_on = [aws_s3_bucket_public_access_block.my_bucket]
}

data "aws_iam_policy_document" "bucketpolicy" {
  statement {
    sid       = "PublicReadGetObject"
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.website_s3}/*"]
    actions   = ["s3:GetObject"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_object" "upload_index" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "/index.html"
  content_type    = "text/html"
  source = "${path.module}/website/react-template/out/index.html"
  etag   = filemd5("${path.module}/website/react-template/out/index.html")
}
/*
resource "aws_s3_object" "upload_error" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "/error.html"
  content_type    = "text/html"
  source = "${path.module}/website/error.html"
  etag   = filemd5("${path.module}/website/error.html")
}

resource "aws_s3_object" "upload_javascript" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "/javascript_getapi.js"
  content      = local.rendered_script
  content_type = "application/javascript"
} */

// Upload multiple files to S3 Bucket
resource "aws_s3_bucket_object" "provision_source_files" {
    bucket  = aws_s3_bucket.my_bucket.id
    for_each = fileset("website/react-template/out", "**/*.*")

    key    = each.value
    source = "website/react-template/out/${each.value}"
}

resource "aws_s3_bucket_website_configuration" "website-config" {
  bucket = aws_s3_bucket.my_bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = " error.html"
  }
}

