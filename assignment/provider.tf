terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
    version = "= 3.72.0"
   }
    kubernetes = {
   version = ">= 2.0.0"

    }
 }
}

provider "aws" {
  region  = var.aws_region
}

