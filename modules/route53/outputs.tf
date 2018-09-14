output "zone_id" {
  value = "${data.aws_route53_zone.default.id}"
}

output "name" {
  value = "${data.aws_route53_zone.default.name}"
}

output "certificate_id" {
  value = "${data.aws_acm_certificate.default.id}"
}

output "certificate_arn" {
  value = "${data.aws_acm_certificate.default.arn}"
}
