provider "aws" {
  region = "${var.region}"
}

data "aws_route53_zone" "default" {
  name = "${var.domain}"
}

data "aws_acm_certificate" "default" {
  domain = "${var.domain}"
  statuses = [
    "ISSUED"
  ]
  most_recent = true
}
