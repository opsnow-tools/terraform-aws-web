# static-web

provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    region = "ap-northeast-2"
    bucket = "terraform-state-bespin-sbl-seoul"
    key = "opsnow-repo.tfstate"
  }
}

module "repo" {
  source = "./modules/static-web"
  region = "${var.region}"
  name   = "repo"
  domain = "${var.domain}"
}

output "url" {
  value = "https://repo.${var.domain}"
}
