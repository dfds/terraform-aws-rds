provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "single-postgresql-instance"
  region = "eu-central-1"

  tags = {
    Name = local.name
  }
}

module "rds_instance_test" {
  source                    = "../../"
  environment               = "dev"
  identifier                = local.name
  is_kubernetes_app_enabled = false
  is_proxy_included         = false
  service_availability      = "low"
  username                  = "single_instance_user"
  vpc_id                    = module.vpc.vpc_id
  is_publicly_accessible    = true
  subnet_ids                = concat(module.vpc.public_subnets)
  # enabled_cloudwatch_logs_exports        = ["upgrade", "postgresql"] # Do we enable them by default on production?
  # cloudwatch_log_group_retention_in_days = 1
  resource_owner_contact_email = "example@dfds.com"
  cost_centre                  = "ti-arch"
  data_classification          = "public"
  optional_tags                = local.tags
  deletion_protection          = false

  # public_access_ip_whitelist = ["x.x.x.x/32"]
}

################################################################################
# Supporting Resources - Example VPC
################################################################################

module "vpc" {
  source = "../shared/"
  name   = local.name
  cidr   = "10.20.0.0/16"
  tags   = local.tags
}


output "peering" {
  value = module.rds_instance_test.peering
}
