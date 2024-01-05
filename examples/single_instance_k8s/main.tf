provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "single-postgresql-instance-k8s"
  region = "eu-central-1"

  tags = {
    Name = local.name
  }
}

module "rds_instance_test" {
  source                    = "../../"
  environment               = "dev"
  identifier                = local.name
  is_kubernetes_app_enabled = true
  is_proxy_included         = false
  rds_security_group_rules = {
    ingress_rules = [
      {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        description = "PostgreSQL access from within VPC"
        cidr_blocks = module.vpc.vpc_cidr_block
      },
      {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        description = "PostgreSQL access from internet"
        cidr_blocks = "0.0.0.0/0"
      },
    ]
  }
  service_availability   = "low"
  username               = "single_instance_user"
  vpc_id                 = module.vpc.vpc_id
  is_publicly_accessible = true
  subnet_ids             = concat(module.vpc.public_subnets)
  # enabled_cloudwatch_logs_exports        = ["upgrade", "postgresql"] # Do we enable them by default on production?
  # cloudwatch_log_group_retention_in_days = 1
  resource_owner_contact_email = "example@dfds.com"
  cost_centre                  = "ti-arch"
  data_classification          = "public"
  optional_tags                = local.tags
  deletion_protection          = false
}

################################################################################
# Supporting Resources - Example VPC
################################################################################

module "vpc" {
  source = "../shared/"
  name   = local.name
  cidr   = "10.24.0.0/16"
  tags   = local.tags
}
