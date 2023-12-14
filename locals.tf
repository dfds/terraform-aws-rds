locals {

  ########################################################################
  # Parameter group
  ########################################################################
  create_db_parameter_group = true
  parameter_group_family    = data.aws_rds_engine_version.engine_info.parameter_group_family

  instance_parameters = concat([
    {
      name           = "rds.force_ssl"
      value          = 1 # this might need to be changed back and forth to ensure apply_method is applied. See here: https://github.com/hashicorp/terraform-provider-aws/pull/24737
      apply_method = "immediate"
    },
    {
      name           = "log_connections"
      value        = 1
      apply_method = "immediate"
    }
  ]
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
  create_cloudwatch_log_group = length(var.enabled_cloudwatch_logs_exports) > 0

  ########################################################################
  # DB Proxy configuration
  ########################################################################
  proxy_name          = var.proxy_name == null ? "${var.identifier}" : var.proxy_name
  db_proxy_secret_arn = local.is_serverless ? try(module.db_cluster_serverless[0].cluster_master_user_secret_arn, null) : coalesce(module.db_instance[0].db_instance_master_user_secret_arn, null)

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

  iops                      = var.iops == null && var.storage_type == "io1" ? 1000 : var.iops # The minimum value is 1,000 IOPS and the maximum value is 256,000 IOPS. The IOPS to GiB ratio must be between 0.5 and 50
  is_serverless             = var.is_serverless                                               # temporary controlled by variable. TODO: Replace by calculation
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.final_snapshot_identifier_prefix}-${var.identifier}-${try(random_id.snapshot_identifier[0].hex, "")}"

  engine = "postgres"

  config = {
    prod = {
      instance_class                        = "db.t3.micro",
      max_allocated_storage                 = 50,
      port                                  = 5432,
      multi_az                              = true,
      skip_final_snapshot                   = false,
      performance_insights_enabled          = true,
      performance_insights_retention_period = 7,
      delete_automated_backups              = false
    },
    non-prod = {
      instance_class                        = "db.t3.micro",
      allocated_storage                     = 20,
      max_allocated_storage                 = null
      port                                  = 5432,
      multi_az                              = true,
      skip_final_snapshot                   = true,
      performance_insights_enabled          = false,
      performance_insights_retention_period = null,
      delete_automated_backups              = true
    }
  }

  # engine_version                        = var.engine_version != null ? var.engine_version : floor(data.aws_rds_engine_version.default.version)
  engine_version                        = data.aws_rds_engine_version.engine_info.version
  is_major_engine_version               = try(length(regexall("\\.[0-9]+$", var.engine_version)) > 0, true) # For example, 15 is a major version, but 15.5 is not
  environment                           = var.environment == "prod" ? var.environment : "non-prod"
  default_config                        = local.config[local.environment]
  instance_class                        = var.instance_class != "" ? var.instance_class : local.default_config.instance_class
  allocated_storage                     = var.allocated_storage != null ? var.allocated_storage : local.default_config.allocated_storage
  max_allocated_storage                 = var.max_allocated_storage != null ? var.max_allocated_storage : local.default_config.max_allocated_storage
  password                              = var.manage_master_user_password ? null : var.password
  port                                  = var.port != null ? var.port : local.default_config.port
  db_subnet_group_name                  = var.create_db_subnet_group ? module.db_subnet_group[0].db_subnet_group_id : var.db_subnet_group_name ## TODO
  multi_az                              = var.multi_az != null ? var.multi_az : local.default_config.multi_az
  skip_final_snapshot                   = var.skip_final_snapshot != null ? var.skip_final_snapshot : local.default_config.skip_final_snapshot
  performance_insights_enabled          = var.performance_insights_enabled != null ? var.performance_insights_enabled : local.default_config.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period != null ? var.performance_insights_retention_period : local.default_config.performance_insights_retention_period
  delete_automated_backups              = var.delete_automated_backups != null ? var.delete_automated_backups : local.default_config.delete_automated_backups
  backup_retention_period               = var.backup_retention_period != null ? var.backup_retention_period : 0
}
