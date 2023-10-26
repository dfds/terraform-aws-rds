data "aws_vpc" "vpc" {
    id = var.vpc_id
}

resource "aws_db_proxy" "db_proxy" {
  name = var.resource_name
  debug_logging = var.proxy_debug_logging
  engine_family = var.db_engine_family
  idle_client_timeout = var.idle_client_timeout
  require_tls = var.proxy_require_tls
  role_arn = aws_iam_role.proxy.arn
  vpc_security_group_ids = [var.security_group_id, aws_security_group.proxy_security_group.id]
  vpc_subnet_ids = var.data_subnet_ids

  auth {
    auth_scheme = "SECRETS"
    iam_auth = "DISABLED"
    secret_arn = var.secret_arn
  }
}

resource "aws_db_proxy_default_target_group" "proxy_target_group" {
  db_proxy_name = aws_db_proxy.db_proxy.name

  connection_pool_config {
    max_connections_percent = 100
    max_idle_connections_percent = 50
    session_pinning_filters = ["EXCLUDE_VARIABLE_SETS"]
  }
}

resource "aws_db_proxy_target" "proxy_target" {
  db_cluster_identifier = var.cluster_identifier #? aws_rds_cluster.rds_cluster.id : null
  db_instance_identifier = var.instance_identifier # !local.isAurora ? aws_db_instance.db_instance.id : null
  db_proxy_name = aws_db_proxy.db_proxy.name
  target_group_name = aws_db_proxy_default_target_group.proxy_target_group.name
}

data "aws_iam_policy_document" "proxy_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "proxy" {
  name = "proxy-${var.resource_name}"
  assume_role_policy = data.aws_iam_policy_document.proxy_assume_role.json
}

data "aws_iam_policy_document" "secrets_manager_proxy_policy_document" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      var.secret_arn
    ]
  }

  statement {
    actions = [
      "kms:Decrypt"
    ]
    resources = [var.secret_kms_arn]
    condition {
      test = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "secretsmanager.eu-central-1.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_policy" "secrets_manager_proxy_policy" {
  name   = "${var.resource_name}-secrets-manager-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.secrets_manager_proxy_policy_document.json
}

resource "aws_iam_policy_attachment" "proxy_policy_attachment" {
  name       = "proxy-policy-${var.resource_name}"
  roles      = [aws_iam_role.proxy.name]
  policy_arn = aws_iam_policy.secrets_manager_proxy_policy.arn
}

resource "aws_security_group" "proxy_security_group" {
  name = "proxy-${var.resource_name}"
  description = "A security group for ${var.resource_name} database proxy"
  vpc_id = data.aws_vpc.vpc.id

  tags = var.common_tags

  # Proxy requires self referencing inbound rule
  ingress {
    from_port = var.port
    to_port = var.port
    protocol = "tcp"
    self = true
  }

  # Allow outbound all traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}