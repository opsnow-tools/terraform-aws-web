output "domain" {
  value = "${element(var.domain_name, 0)}"
}

output "s3_website_endpoint" {
  value = "${aws_s3_bucket.default.website_endpoint}"
}

output "cdn_domain" {
  value = "${aws_cloudfront_distribution.default.domain_name}"
}

output "cdn_zone_id" {
  value = "${aws_cloudfront_distribution.default.hosted_zone_id}"
}
