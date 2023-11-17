locals {
  config = {
    postgres = {
      prod = {
        "instance_class": "db.r6g.xlarge",
        "allocated_storage": 500
      }
    }
  }

  default_config = local.config[var.engine][var.environment]
  instance_class = var.instance_class != null ? var.instance_class : local.default_config.instance_class
  allocated_storage = var.allocated_storage != null ? var.allocated_storage : local.default_config.allocated_storage
}

module "rds_instance" {
  source = "./modules/rds_instance"
  count  = var.create_db_instance ? 1 : 0

  identifier = var.identifier
  engine = var.engine
  engine_version = var.engine_version
  instance_class = local.instance_class
  allocated_storage = local.allocated_storage
  #storage_type
  storage_encrypted = true

  db_name                             = var.db_name
  username = var.username
  password = local.password
  port = local.port
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  multi_az = local.multi_az
  manage_master_user_password = var.manage_master_user_password
  #vpc_security_group_ids

}