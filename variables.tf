
# Name the s3 bucket as the domain name of the website
variable "website_s3" {
  type        = string
  description = "S3 Bucket name for the website"
  default     = "www.isonghoang.com"
}

# Name this as the domain name of the website
variable "domainName" {
  default = "isonghoang.com"
  type    = string
}

variable "client_id" {
  type        = string
  description = "Audience Client ID Tag"
  default     = "website_s3_gj2l69ckoe"
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-2"
}

variable "zone_id" {
  description = "Zone ID of domain in Route53"
  type        = string
  default     = "Z01277683AFP2FF5KUOCR"
}