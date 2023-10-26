data "aws_vpc" "vpc" {
    id = var.vpc_id
}

data "aws_availability_zones" "available" {}

resource "aws_security_group" "sql_database" {
  name = "sql-${var.resource_name}"
  description = "A Security Group for ${var.resource_name} SQL database"
  vpc_id = data.aws_vpc.vpc.id

  tags = var.common_tags

  # Inbound MySQL from private subnets
  ingress {
    from_port = var.port
    to_port = var.port
    protocol = "tcp"
    cidr_blocks = var.cidr_block_private_subnet
  }

  # Inbound ICMP
  ingress {
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = var.cidr_block_private_subnet
  }

  ingress {
    from_port = 3
    to_port = 4
    protocol = "icmp"
    cidr_blocks = var.cidr_block_private_subnet
  }

  # Outbound to private subnet
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = var.cidr_block_private_subnet
  }
}

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

resource "aws_db_parameter_group" "instance_parameter_group" {
  name   = "${var.resource_name}-db-parameter-group"
  family = var.db_parameter_group_family
  description = "RDS default instance parameter group"

  dynamic "parameter" {
    for_each = var.instance_parameter_group_settings
    content {
      name  = parameter.value.name
      value = parameter.value.value
    } 
  }
}

resource "aws_db_instance" "db_instance" {
  identifier = var.resource_name
  allocated_storage = var.allocated_storage
  storage_type = var.storage_type
  engine = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class
  db_name = var.application_name
  username = var.sql_admin_username
  password = var.sql_admin_password
  parameter_group_name = aws_db_parameter_group.instance_parameter_group.name
  vpc_security_group_ids = [aws_security_group.sql_database.id]
  db_subnet_group_name = aws_db_subnet_group.data_subnets.id
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = !var.skip_final_snapshot ? "${var.resource_name}-final-${random_id.snapshot.hex}" : null
  manage_master_user_password = var.manage_master_user_password
}