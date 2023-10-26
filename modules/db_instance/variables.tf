variable "resource_name" {
    description = "Constructed name to use for the resource"
}

variable "common_tags" {
    description = "Tags for the resources"
}

variable "application_name" {
    description = "The name of the application. Used to name and tag resources. This CAN NOT contain hyphens or underscores"
}

variable "environment" {
    description = "The environment of the application. I.e Production, Test. Used to name and tag resources"
}

variable "private_subnet_ids" {
    description = "List of the private subnets that the database can communicate with"
    type = list
}

variable "data_subnet_ids" {
    description = "List of the data subnets that the database belongs in"
    type = list
}

variable "sql_admin_username" {
    description = "Username for the SQL administrator"
}

variable "sql_admin_password" {
    description = "Password for the SQL administrator"
}

variable "db_instance_count" {
    description = "Number of SQL instances to run"
}

variable "db_instance_class" {
    description = "DB instance class. Defaults to db.t3.small"
    default = "db.t3.small"
}

variable "db_engine_mode" {
    description = "The engine mode of the database. Defaults to serverless"
    default = "serverless"
}

variable "vpc_id" {
    description = "Id of the VPC in which to deploy"
}

variable "serverless_seconds_until_pause" {
    description = "Optional. Seconds to wait until RDS Serverless instance pauses"
    default = 600
    type = number
} 

variable "serverless_min_capacity_units" {
    description = "Minimum capacity units for RDS serverless instance. Defaults to 1"
    default = 1
}

variable "serverless_max_capacity_units" {
    description = "Optional. Minimum capacity units for RDS serverless instance"
    default = null
}

variable "cidr_block_private_subnet" {
    type = list
    description = "A list of CIDR blocks for private subnets. Used for SQL security group"
}

variable "backup_retention_period" {
    description = "Number of days to retain backups for. Defaults to 7"
    default = 7
}

variable "preferred_backup_window" {
    description = "The daily time range during which automated backups are created if automated backups are enabled. Defaults to 02:00-04:00. Does not apply to serverless mode"
    default = "02:00-04:00"
}

variable "iam_database_authentication_enabled" {
    description = "Specifies whether or mappings of AWS IAM accounts to database accounts is enabled. Defaults to false"
    default = "false"
}

variable "deletion_protection" {
    description = "The database can't be deleted when this value is set to true. Defaults to false"
    default = false
}

variable "skip_final_snapshot" {
    description = "Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. Defaults to true"
    default = true
}

variable "final_snapshot_identifier" {
    description = "Optional. Override the name of your final DB snapshot when this DB cluster is deleted."
    default = null
}

variable "db_engine" {
    description = "The name of the database engine to be used for this DB cluster. Defaults to aurora. Valid Values: aurora, aurora-mysql, aurora-postgresql"
    default = "aurora"
}

variable "db_engine_family" {
    description = "The engine family either MYSQL or POSTGRESQL (defaults to MYSQL)"
    default = "MYSQL"
}

variable "db_parameter_group_family" {
    description = "The database parameter group family name"
}

variable "backtrack_window" {
    description = "The target backtrack window, in seconds for aurora. Defaults to 0 which is disabled. Cannot be used with serverless"
    default = 0
}

variable "db_engine_version" {
    description = "The database engine version. Updating this argument results in an outage. See the Aurora MySQL and Aurora Postgres documentation for your configured engine to determine this value"
}

variable "storage_encrypted" {
    description = "Specifies whether the DB cluster is encrypted. Defaults to true"
    default = true
}

variable "kms_key_id" {
    description = "Optional. The ARN for a Customer KMS encryption key"
    default = null
}

variable "cluster_identifier_prefix" {
    description = "Optional. Creates a unique cluster identifier beginning with the specified prefix. Conflicts with cluster_identifier."
    default = null
}

variable "copy_tags_to_snapshot" {
    description = "Optional. Copy all Cluster tags to snapshots"
    default = null
}

variable "preferred_maintenance_window" {
    default = "sun:00:00-sun:02:00"
    description = "The weekly time range during which system maintenance can occur, in (UTC). Defaults to sun:00:00-sun:02:00. Does not apply to serverless mode"
}

variable "port" {
    default = 3306
    description = "The port on which the DB accepts connections. Defaults to 3306"
}

variable "snapshot_identifier" {
    default = null
    description = "Optional. Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot."
}

variable "global_cluster_identifier" {
    default = null
    description = "Optional. The global cluster identifier specified on aws_rds_global_cluster"
}

variable "replication_source_identifier" {
    default = null
    description = "Optional. ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica."
}

variable "apply_immediately" {
    default = false
    description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. Defaults to false"
}

variable "iam_roles" {
    default = null
    description = "Optional. A List of ARNs for the IAM roles to associate to the RDS Cluster"
}

variable "source_region" {
    default = null
    description = "Optional. The source region for an encrypted replica DB cluster"
}

variable "enabled_cloudwatch_logs_exports" {
    type = list
    default = null
    description = " Optional. List of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: audit, error, general, slowquery. Not supported by Serverless"
}

variable "publicly_accessible" {
    default = false
    description = "Control if db instance is publicly accessible. Defaults to false"
}

variable "identifier" {
    default = null
    description = "Optional. The indentifier for the RDS instance. Conflicts with identifier_prefix"
}

variable "db_subnet_group_name" {
    default = null
    description = "Optional. A DB subnet group to associate with this DB instance"
}

variable "monitoring_interval" {
    default = 0
    description = "Optional. The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. Valid Values: 0, 1, 5, 10, 15, 30, 60"
}

variable "promotion_tier" {
    default = null
    description = "Optional. Failover Priority setting on instance level. The reader who has lower tier has higher priority to get promoter to writer"
}

variable "auto_minor_version_upgrade" {
    default = null
    description = "Optional. Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window"
}

variable "performance_insights_enabled" {
    default = false
    description = "Specifies whether Performance Insights is enabled or not. Defaults to false"
}

variable "performance_insights_kms_key_id" {
    default = null
    description = "Optional. The ARN for the KMS key to encrypt Performance Insights data. "
}

variable "allocated_storage" {
    description = "Amount of storage (in GB) allocated to DB (non-aurora only)"
    default = 20
}

variable "storage_type" {
    description = "Database storage type (default gp2 - general purpose)"
    default = "gp2"
}

variable "instance_parameter_group_settings" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "A list of instance parameter group settings"
  default     = []
}

variable "manage_master_user_password" {
    description = "Set to true to allow RDS to manage the master user password in Secrets Manager. Default True"
    default = true
}