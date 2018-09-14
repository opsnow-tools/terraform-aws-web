provider "aws" {
  region = "${var.region}"
}

resource "aws_s3_bucket" "default" {
  bucket = "${element(var.domain_name, 0)}"

  acl = "public-read"
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_object" "default" {
  count = "${var.index_html != "" ? 1 : 0}"

  bucket = "${aws_s3_bucket.default.bucket}"
  source = "${var.index_html}"
  key    = "index.html"

  content_type = "text/html"
  acl = "public-read"
}

resource "aws_cloudfront_distribution" "default" {
  origin {
    origin_id = "S3-${element(var.domain_name, 0)}"
    domain_name = "${element(var.domain_name, 0)}.s3.amazonaws.com"

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  aliases = [
    "${var.domain_name}"
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
    target_origin_id = "S3-${element(var.domain_name, 0)}"

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
    acm_certificate_arn = "${var.certificate_arn}"
    minimum_protocol_version = "TLSv1"
    ssl_support_method = "sni-only"
  }
}

resource "aws_route53_record" "default" {
  count = "${length(var.domain_name)}"

  zone_id = "${var.zone_id}"

  name = "${element(var.domain_name, count.index)}"
  type = "A"

  alias {
    name = "${aws_cloudfront_distribution.default.domain_name}"
    zone_id = "${aws_cloudfront_distribution.default.hosted_zone_id}"
    evaluate_target_health = "false"
  }
}
