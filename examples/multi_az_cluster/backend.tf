terraform {
  backend "s3" {
    bucket         = "dfds-aws-modules-rds"
    encrypt        = true
    key            = "examples/multi_az_cluster/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
  }
}
