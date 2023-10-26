provider "aws" {
  region  = var.aws_region
  version = ">= 5.10.0"
}

provider "random" {
  version = ">= 3.0.0"
}


locals {
  common_tags = {
    Application = var.application_name
    Environment = var.environment
  }

  constructed_name = "${var.prefix}${var.prefix_separator}${var.application_name}${var.suffix_separator}${var.suffix}"

  isAurora = contains(["aurora", "aurora-mysql", "aurora-postgresql"],var.db_engine)
}

module "db_cluster" {
  source = "./modules/db_cluster"
  count = local.isAurora ? 1 : 0
  resource_name = local.constructed_name
  common_tags = local.common_tags
  vpc_id = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  data_subnet_ids = var.data_subnet_ids
  cidr_block_private_subnet = var.cidr_block_private_subnet
  db_instance_count = var.db_instance_count
  application_name = var.application_name
  sql_admin_username = var.sql_admin_username
  sql_admin_password = var.sql_admin_password
  security_group_id = module.security_group.id
  proxy_security_group_id = var.include_proxy ? module.proxy[0].proxy_security_group_id : ""
  port = var.port
  publicly_accessible = var.publicly_accessible
  kms_key_id = var.kms_key_id
  deletion_protection = var.deletion_protection
  db_instance_class = var.db_instance_class
  preferred_backup_window = var.preferred_backup_window
  db_engine = var.db_engine
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  db_subnet_group_name = var.db_subnet_group_name
  identifier = var.identifier
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  skip_final_snapshot = var.skip_final_snapshot
  replication_source_identifier = var.replication_source_identifier
  promotion_tier = var.promotion_tier
  iam_roles = var.iam_roles
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  source_region = var.source_region
  monitoring_interval = var.monitoring_interval
  performance_insights_kms_key_id = var.performance_insights_kms_key_id
  db_engine_mode = var.db_engine_mode
  serverless_max_capacity_units = var.serverless_max_capacity_units
  backup_retention_period = var.backup_retention_period
  db_engine_family = var.db_engine_family
  backtrack_window = var.backtrack_window
  global_cluster_identifier = var.global_cluster_identifier
  apply_immediately = var.apply_immediately
  performance_insights_enabled = var.performance_insights_enabled
  final_snapshot_identifier = var.final_snapshot_identifier
  db_engine_version = var.db_engine_version
  copy_tags_to_snapshot = var.copy_tags_to_snapshot
  preferred_maintenance_window = var.preferred_maintenance_window
  serverless_min_capacity_units = var.serverless_min_capacity_units
  serverless_seconds_until_pause = var.serverless_seconds_until_pause
  cluster_identifier_prefix = var.cluster_identifier_prefix
  snapshot_identifier = var.snapshot_identifier
  cluster_parameter_group_settings = var.cluster_parameter_group_settings
  instance_parameter_group_settings = var.instance_parameter_group_settings
  manage_master_user_password = var.manage_master_user_password
  environment = var.environment
  db_parameter_group_family = var.db_parameter_group_family
}

module "db_instance" {
  source = "./modules/db_instance"
  count = !local.isAurora ? 1 : 0
  resource_name = local.constructed_name
  common_tags = local.common_tags
  vpc_id = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  data_subnet_ids = var.data_subnet_ids
  cidr_block_private_subnet = var.cidr_block_private_subnet
  db_instance_count = var.db_instance_count
  application_name = var.application_name
  sql_admin_username = var.sql_admin_username
  sql_admin_password = var.sql_admin_password
  allocated_storage = var.allocated_storage
  storage_type = var.storage_type
  instance_parameter_group_settings = var.instance_parameter_group_settings
  manage_master_user_password = var.manage_master_user_password
  environment = var.environment
  db_parameter_group_family = var.db_parameter_group_family
  db_engine_version = var.db_engine_version
}

module "proxy" {
  source = "./modules/proxy"
  count = var.include_proxy ? 1 : 0
  resource_name = local.constructed_name
  common_tags = local.common_tags
  vpc_id = var.vpc_id
  secret_arn = module.secret[0].arn
  secret_kms_arn = module.secret[0].kms_arn
  port = var.port
  security_group_id = module.security_group.id
  proxy_debug_logging = var.proxy_debug_logging
  idle_client_timeout = var.idle_client_timeout
  proxy_require_tls = var.proxy_require_tls
  data_subnet_ids = var.data_subnet_ids
  db_engine_family = var.db_engine_family
  cluster_identifier = local.isAurora ? module.db_cluster[0].id : null
  instance_identifier = !local.isAurora ? module.db_instance[0].id : null
}

module "secret" {
  source = "./modules/secret"
  count = var.include_secret || var.include_proxy ? 1 : 0
  resource_name = local.constructed_name
  common_tags = local.common_tags
  private_subnet_ids = var.private_subnet_ids
  db_client_username = var.db_client_username
  db_client_password = var.db_client_password
  recovery_window_in_days = var.recovery_window_in_days
  enable_secret_rotation = var.enable_secret_rotation
  proxy_endpoint = var.include_proxy ? module.proxy[0].endpoint : ""
  application_name = var.application_name
  host_endpoint = local.isAurora ? module.db_cluster[0].endpoint : module.db_instance[0].endpoint
  rotation_days = var.rotation_days
  secret_description = var.secret_description
  reader_endpoint = local.isAurora ? module.db_cluster[0].reader_endpoint : null
  db_engine_family = var.db_engine_family
  port = var.port
  service_iam_username = var.service_iam_username
  suffix = var.suffix
  suffix_separator = var.suffix_separator
}

module "security_group" {
  source = "./modules/security_group"
  resource_name = local.constructed_name
  common_tags = local.common_tags
  vpc_id = var.vpc_id
  cidr_block_private_subnet = var.cidr_block_private_subnet
  port = var.port
  cidr_block_data_subnet = var.cidr_block_data_subnet
}