provider "aws" {
  region = "${var.region}"
}

resource "aws_s3_bucket" "state-file-bucket" {
  bucket = "income-stat-${var.environment}-state-file"

  versioning {
    enabled = true
  }

  tags {
    environment = "${var.environment}"
  }
}

terraform {
  backend "s3" {
    bucket  = "income-stat-production-state-file"
    key     = "terraform.tfstate"
    region  = "us-west-2"
    encrypt = true
  }
}
