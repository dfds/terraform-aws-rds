locals {
  name        = var.use_name_prefix ? null : var.name
  name_prefix = var.use_name_prefix ? "${var.name}-" : null

  description = coalesce(var.description, format("%s subnet group", var.name))
}

resource "aws_db_subnet_group" "this" {
  name        = local.name
  name_prefix = local.name_prefix
  description = local.description
  subnet_ids  = var.subnet_ids

  tags = var.tags
}
