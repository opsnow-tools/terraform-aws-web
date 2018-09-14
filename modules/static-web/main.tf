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

resource "aws_s3_bucket" "default" {
  bucket = "${var.name}.${var.domain}"

  acl = "public-read"
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_cloudfront_distribution" "default" {
  origin {
    origin_id = "S3-${var.name}.${var.domain}"
    domain_name = "${var.name}.${var.domain}.s3.amazonaws.com"

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  aliases = [
    "${var.name}.${var.domain}"
  ]

  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods = [
      "HEAD",
      "DELETE",
      "POST",
      "GET",
      "OPTIONS",
      "PUT",
      "PATCH",
    ]
    cached_methods = [
      "HEAD",
      "GET",
    ]
    target_origin_id = "S3-${var.name}.${var.domain}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    compress = true
    //viewer_protocol_policy = "allow-all"
    viewer_protocol_policy = "redirect-to-https"

    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }

  //price_class = "PriceClass_All"
  price_class = "PriceClass_200"

  restrictions {
    //geo_restriction {
    //  restriction_type = "none"
    //  locations = []
    //}
    geo_restriction {
      restriction_type = "whitelist"
      locations = [
        "KR"
      ]
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate.default.certificate_arn}"
    minimum_protocol_version = "TLSv1"
    ssl_support_method = "sni-only"
  }
}

resource "aws_route53_record" "default" {
  zone_id = "${aws_route53_zone.default.zone_id}"

  name = "${var.name}.${var.domain}"
  type = "A"

  alias {
    name = "${aws_cloudfront_distribution.default.domain_name}"
    zone_id = "${aws_cloudfront_distribution.default.hosted_zone_id}"
    evaluate_target_health = "false"
  }
}
