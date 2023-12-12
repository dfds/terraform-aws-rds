provider "aws" {
  region = local.region
}

locals {
  name   = "qa"
  region = "eu-central-1"

  tags = {
    Name                                 = local.name
    Repository                           = "https://github.com/dfds/aws-modules-rds"
    "dfds.env"                           = "test"
    "dfds.automation.tool"               = "Terraform"
    "dfds.automation.initiator.location" = "https://github.com/dfds/aws-modules-rds/"
    "dfds.automation.initiator.pipeline" = "https://github.com/dfds/aws-modules-rds/actions/workflows/qa.yml"
    "dfds.test.scope"                    = "qa"
  }

}

module "rds_instance_test" {
  source                                 = "../../"
  identifier                             = local.name
  environment                            = "test"
  instance_class                         = "db.t3.micro"
  db_name                                = "qadb"
  multi_az                               = true
  username                               = "qa_user"
  manage_master_user_password            = true
  iam_database_authentication_enabled    = true
  ca_cert_identifier                     = "rds-ca-ecc384-g1"
  apply_immediately                      = true
  tags                                   = local.tags
  publicly_accessible                    = true
  subnet_ids                             = ["subnet-04d5d42ac21fd8e8f", "subnet-0e50a82dec5fc0272", "subnet-0a49d384ff2e8a580"]
  allocated_storage                      = 5
  enabled_cloudwatch_logs_exports        = ["upgrade", "postgresql"]
  cloudwatch_log_group_retention_in_days = 1
  include_proxy                          = true
  proxy_debug_logging                    = true
  enhanced_monitoring_interval           = 0
  allow_major_version_upgrade            = true
  engine_version                         = "16.1"
  performance_insights_enabled           = true
  oidc_provider                          = "oidc.eks.eu-west-1.amazonaws.com/id/B182759F93D251942CB146063F57036B"
  kubernetes_namespace                   = "cloudengineering-bluep-nvfgm"
  vpc_id                                 = "vpc-04a384af7d3657687"

  proxy_security_group_rules = {
    ingress_rules = [
      {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        description = "PostgreSQL access over VPC peering"
        cidr_blocks = "10.0.0.0/16"
      },
    ]
  }

  rds_security_group_rules = {
    ingress_rules = [
      {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        description = "PostgreSQL access from within VPC"
        cidr_blocks = "10.100.56.0/22"
      },
      {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        description = "PostgreSQL access over VPC peering"
        cidr_blocks = "10.0.0.0/16"
      },
      {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        description = "PostgreSQL access from public IPs"
        cidr_blocks = "0.0.0.0/0"
      },
    ]
  }

}
