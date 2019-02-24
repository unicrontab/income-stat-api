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
    bucket  = "income-stat-${var.environment}-state-file-bucket"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
