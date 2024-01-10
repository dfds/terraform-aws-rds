data "aws_rds_engine_version" "engine_info" { # preferred vesion.
  engine       = local.engine
  version      = var.engine_version
  default_only = !local.is_major_engine_version || var.engine_version == null
}

data "aws_iam_account_alias" "current" {}

data "aws_ssm_parameter" "oidc_provider" {
  name = "/managed/cluster/oidc-provider"
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_vpc_peering_connection" "kubernetes_access" {
  count = var.is_kubernetes_app_enabled ? 1 : 0 # Only needed if the RDS instance is not publicly accessible
  tags  = { Name = "oxygen-hellman" }
}
