terraform {
  # backend "s3" {
  #   # This configuration will be filled in by Terragrunt
  # }
  required_version = ">= 1.3.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.19.0"
    }
    random = {
      source = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }
}
