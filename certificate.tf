resource "aws_acm_certificate" "cloudfront_cert" {
  domain_name       = "var.domainName"
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.website_s3}"
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cloudfront_cert_validation" {
  certificate_arn         = aws_acm_certificate.cloudfront_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}