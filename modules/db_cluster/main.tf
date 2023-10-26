resource "aws_db_subnet_group" "data_subnets" {
  name       = "${var.resource_name}-data"
  subnet_ids = var.data_subnet_ids

  tags = var.common_tags
}

# IAM Role Definition for RDS Enhanced Monitoring
data "aws_iam_policy_document" "rds-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

# Create RDS Enhanced Monitoring role
resource "aws_iam_role" "rds_monitoring_all_iam_role" {
  name               = "${var.resource_name}-role-all-rds-monitor"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.rds-assume-role-policy.json
}

# Attach RDS Enhanced Monitoring role policy(ies)
resource "aws_iam_role_policy_attachment" "rds_monitoring_all_iam_role_policies_attach" {
    role       = aws_iam_role.rds_monitoring_all_iam_role.id
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "random_id" "snapshot" {
  byte_length = 8

  keepers = {
    engine_mode = var.db_engine_mode
  }
}


resource "aws_rds_cluster_parameter_group" "cluster_parameter_group" {
  name   = "${var.resource_name}-cluster-parameter-group"
  family = var.db_parameter_group_family
  description = "RDS default cluster parameter group"

  dynamic "parameter" {
    for_each = var.instance_parameter_group_settings
    content {
      name  = parameter.value.name
      value = parameter.value.value
    } 
  }
}

resource "aws_db_parameter_group" "instance_parameter_group" {
  name   = "${var.resource_name}-db-parameter-group"
  family = var.db_parameter_group_family

  dynamic "parameter" {
    for_each = var.instance_parameter_group_settings
    content {
      name  = parameter.value.name
      value = parameter.value.value
    } 
  }
}

resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier      = var.resource_name
  cluster_identifier_prefix = var.cluster_identifier_prefix

  database_name = var.application_name
  master_username = var.snapshot_identifier == null || var.global_cluster_identifier == null ? var.sql_admin_username : null
  master_password =  var.manage_master_user_password == false ? var.sql_admin_password : null
  manage_master_user_password = var.manage_master_user_password
  
  engine = var.db_engine
  engine_mode = random_id.snapshot.keepers.engine_mode
  engine_version = var.db_engine_version
  port = var.port

  snapshot_identifier = var.snapshot_identifier
  global_cluster_identifier = var.global_cluster_identifier

  replication_source_identifier = var.replication_source_identifier
  source_region = var.source_region

  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.db_engine_mode == "serverless" ? null : var.preferred_backup_window
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = !var.skip_final_snapshot ? "${var.resource_name}-final-${random_id.snapshot.hex}" : null
  copy_tags_to_snapshot = var.copy_tags_to_snapshot

  backtrack_window = var.db_engine == "aurora" && var.db_engine_mode != "serverless" ? var.backtrack_window : null

  preferred_maintenance_window = var.db_engine_mode == "serverless" ? null : var.preferred_maintenance_window

  apply_immediately = var.apply_immediately

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.cluster_parameter_group.name

  db_subnet_group_name = aws_db_subnet_group.data_subnets.id
  
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  iam_roles = var.iam_roles

  deletion_protection = var.deletion_protection

  storage_encrypted = var.storage_encrypted
  kms_key_id = var.kms_key_id
  
  vpc_security_group_ids = var.proxy_security_group_id != "" ? [var.security_group_id, var.proxy_security_group_id] : [var.security_group_id]
  
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  tags = merge(var.common_tags, tomap({"Name" = var.resource_name}))

  dynamic "scaling_configuration" {
    for_each = var.db_engine_mode == "serverless" ? tolist([var.db_engine_mode]) : []

    content {
      auto_pause = true
      max_capacity = var.serverless_max_capacity_units
      min_capacity = var.serverless_min_capacity_units
      seconds_until_auto_pause = var.serverless_seconds_until_pause
    }
    
  }
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count = var.db_engine_mode == "serverless" ? 0 : var.db_instance_count

  identifier = var.identifier
  identifier_prefix  = "${var.resource_name}-${count.index}-"

  cluster_identifier = aws_rds_cluster.rds_cluster.id
  instance_class = var.db_instance_class
  publicly_accessible = var.publicly_accessible

  engine = var.db_engine
  engine_version = var.db_engine_version

  db_subnet_group_name = var.publicly_accessible ? var.db_subnet_group_name : null

  db_parameter_group_name = aws_db_parameter_group.instance_parameter_group.name

  apply_immediately = var.apply_immediately

  monitoring_role_arn = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring_all_iam_role.arn : null
  monitoring_interval = var.monitoring_interval

  promotion_tier = var.promotion_tier

  preferred_maintenance_window = var.preferred_maintenance_window

  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  performance_insights_enabled = var.performance_insights_enabled

  performance_insights_kms_key_id = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null

  copy_tags_to_snapshot = var.copy_tags_to_snapshot

  tags = merge(var.common_tags, tomap({"Name" = var.resource_name}))
  
}