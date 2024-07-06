#configuring terraform version and AWS provider 
terraform {
  required_version = ">= 1.8.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}