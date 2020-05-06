// main.tf describes backend and output. Infrastructure resources are described in other *.tf files.

terraform {
  backend "s3" {
    region = "eu-north-1"
    bucket = "exercise-tf-states"
    key    = "global/s3/terraform.tfstate"
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-north-1"
}

// The application resources are deployed in the Stockholm region.
module "eu_app" {
  source = "./app"
  providers = {
    aws = aws
  }
  prod_waf_stream_arn = module.us_analytics.prod_waf_stream_arn
}

provider "aws" {
  profile = "default"
  alias   = "us-east-1"
  region  = "us-east-1"
}

/*
The analytics resources are deployed in the US Virginia region.
As visitor's requests are collected from WAF, the delivery stream and associated analytics infrastructure have to
be created in the Virginia region.
*/
module "us_analytics" {
  source = "./analytics"
  providers = {
    aws = aws.us-east-1
  }
}
