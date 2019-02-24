provider "aws" {
  version = "~> 1.9"
  region  = "${var.region}"
}

provider "archive" {
  version = "~> 1.0"
}

# data "archive_file" "lambda" {
#     type = "zip"
#     source_file = "../../build/handler.js"
#     output_path = "../../build/handler.zip"
# }

resource "aws_api_gateway_rest_api" "IncomeStatAPI" {
  name        = "IncomeStatAPI"
  description = "This is my API for demonstration purposes"
}

resource "aws_api_gateway_resource" "balance" {
  rest_api_id = "${aws_api_gateway_rest_api.IncomeStatAPI.id}"
  parent_id   = "${aws_api_gateway_rest_api.IncomeStatAPI.root_resource_id}"
  path_part   = "test"
}

resource "aws_api_gateway_method" "getBalance" {
  rest_api_id   = "${aws_api_gateway_rest_api.IncomeStatAPI.id}"
  resource_id   = "${aws_api_gateway_resource.balance.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "balanceIntegration" {
  rest_api_id = "${aws_api_gateway_rest_api.IncomeStatAPI.id}"
  resource_id = "${aws_api_gateway_resource.balance.id}"
  http_method = "${aws_api_gateway_method.getBalance.http_method}"
  type        = "MOCK"
}

resource "aws_api_gateway_deployment" "incomeStatDeployment" {
  depends_on = ["aws_api_gateway_integration.balanceIntegration"]

  rest_api_id = "${aws_api_gateway_rest_api.IncomeStatAPI.id}"
  stage_name  = "test"

  variables = {
    "answer" = "42"
  }
}

data "aws_ssm_parameter" "income_stat_api_key" {
  name = "/income_stat_api_key"
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
