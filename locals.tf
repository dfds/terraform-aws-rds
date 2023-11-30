locals {

  ########################################################################
  # Parameter group
  ########################################################################
  create_db_parameter_group = true
  # parameter_group_name_id = local.create_db_parameter_group ? module.db_parameter_group.db_parameter_group_id : var.parameter_group_name
  pramater_group_family = local.create_db_parameter_group && var.parameter_group_family == null ? "${var.engine}${var.major_engine_version}" : var.parameter_group_family
  instance_parameters = concat([
    {
      "name"         = "rds.force_ssl"
      "value"        = 1 # this might need to be changed back and forth to ensure apply_method is applied. See here: https://github.com/hashicorp/terraform-provider-aws/pull/24737
      "apply_method" = "immediate"
    }]
  , var.instance_parameters)

  cluster_parameters = concat([
    {
      name         = "rds.force_ssl"
      value        = 1
      apply_method = "immediate"
    }
  ], var.cluster_parameters)

  ########################################################################
  # Subnet group
  ########################################################################
  create_db_subnet_group = true
  db_subnet_group_name   = local.create_db_subnet_group ? module.db_subnet_group[0].db_subnet_group_id : var.db_subnet_group_name

  ########################################################################
  # Enhanced Monitoring
  ########################################################################
  create_monitoring_role      = var.enhanced_monitoring_interval > 0
  monitoring_role_name        = local.create_monitoring_role && var.enhanced_monitoring_role_name == null ? "${var.identifier}-rds-enhanced-monitoring" : var.enhanced_monitoring_role_name
  monitoring_role_description = var.enhanced_monitoring_create_role && var.enhanced_monitoring_role_description == null ? "Role for enhanced monitoring of RDS instance ${var.identifier}" : var.enhanced_monitoring_role_description
  monitoring_role_arn         = try(module.enhanced_monitoring_iam_role[0].enhanced_monitoring_iam_role_arn, null)
  ########################################################################
  # CloudWatch log group config
  ########################################################################
  create_cloudwatch_log_group                   = length(var.enabled_cloudwatch_logs_exports) > 0
  cloudwatch_log_group_skip_destroy_on_deletion = true

  ########################################################################
  # DB Proxy configuration
  ########################################################################
  proxy_name          = var.proxy_name == null ? "${var.identifier}" : var.proxy_name
  db_proxy_secret_arn = (var.is_db_cluster || local.is_serverless) ? coalesce(try(module.db_multi_az_cluster[0].cluster_master_user_secret_arn, null), try(module.db_cluster_serverless[0].cluster_master_user_secret_arn, null)) : module.db_instance[0].db_instance_master_user_secret_arn

  proxy_auth_config = {
    (var.username) = {
      description = "Proxy user for ${var.username}"
      secret_arn  = local.db_proxy_secret_arn # aws_secretsmanager_secret.superuser.arn
      iam_auth    = var.rds_proxy_iam_auth
    }
  }

  ########################################################################
  # Instance configs
  ########################################################################
  instance_class       = var.instance_class
  storage_type         = var.is_db_cluster ? "io1" : var.storage_type
  storage_size         = var.allocated_storage == null && var.storage_type == "gp2" ? 5 : var.allocated_storage             # Console suggests 20 GB as minumum storage
  cluster_storage_size = var.is_db_cluster && local.storage_type == "io1" && var.iops == null ? 100 : var.allocated_storage # Console suggests 100 GB as minimum storage for io1
  iops                 = var.iops == null && local.storage_type == "io1" ? 1000 : var.iops                                  # The minimum value is 1,000 IOPS and the maximum value is 256,000 IOPS. The IOPS to GiB ratio must be between 0.5 and 50

  backup_retention_period = var.backup_retention_period == null ? 0 : var.backup_retention_period

  is_serverless = var.is_serverless # temporary controlled by variable. TODO: Replace by calculation

  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.final_snapshot_identifier_prefix}-${var.identifier}-${try(random_id.snapshot_identifier[0].hex, "")}"

  engine_version = var.major_engine_version
}


resource "null_resource" "validate_instance_type_proxy" { # need to enforce dependency in proxy module
  count = var.is_db_cluster && var.include_proxy ? 1 : 0

  provisioner "local-exec" {
    command = "Running a check"
  }

  lifecycle {
    precondition {
      condition     = var.is_db_cluster && var.include_proxy
      error_message = "Cannot create a proxy for a DB cluster"
    }
  }
}
