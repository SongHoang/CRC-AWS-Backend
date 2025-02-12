variable "website_s3" {
    type        = string
    description = "S3 Bucket name for the website"
    default     = "cloudchallenge-i515d"
}

variable "client_id" {
    type        = string
    description = "Audience Client ID Tag"
    default     = "website_s3_gj2l69ckoe"
}