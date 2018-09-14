# static-web

provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    region = "ap-northeast-2"
    bucket = "terraform-state-sbl"
    key = "opsnow-web.tfstate"
  }
}

module "domain" {
  source = "./modules/route53"
  domain = "${var.domain}"
}

module "web" {
  source = "./modules/static-web"
  region = "${var.region}"

  zone_id = "${module.domain.zone_id}"
  certificate_arn = "${module.domain.certificate_arn}"

  domain_name = [
    "www.${var.domain}",
    "${var.domain}"
  ]
}

module "repo" {
  source = "./modules/static-web"
  region = "${var.region}"

  zone_id = "${module.domain.zone_id}"
  certificate_arn = "${module.domain.certificate_arn}"

  domain_name = [
    "repo.${var.domain}"
  ]
}
