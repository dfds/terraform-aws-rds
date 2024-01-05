terraform {
  backend "s3" {
    bucket         = "dfds-aws-modules-rds"
    encrypt        = true
    key            = "examples/single_instance_k8s/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
  }
}
