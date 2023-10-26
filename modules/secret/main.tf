data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_subnet" "firstsub" {  id = var.private_subnet_ids[0] }

data "aws_iam_policy_document" "rotation_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_rotation" {
  count = var.enable_secret_rotation ? 1 : 0
  name = "rotation-lambda-${var.resource_name}"
  assume_role_policy = data.aws_iam_policy_document.rotation_policy.json
}

resource "aws_iam_policy_attachment" "lambdabasic" {
  count = var.enable_secret_rotation ? 1 : 0
  name       = "lambda-basic-policy-${var.resource_name}"
  roles      = [aws_iam_role.lambda_rotation[0].name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "SecretsManagerRDSMySQLRotationSingleUserRolePolicy" {
  count = var.enable_secret_rotation ? 1 : 0
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DetachNetworkInterface",
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecretVersionStage",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:*",
    ]
  }
  statement {
    actions = ["secretsmanager:GetRandomPassword"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "SecretsManagerRDSMySQLRotationSingleUserRolePolicy" {
  count = var.enable_secret_rotation ? 1 : 0
  name = "SecretsManagerRDSMySQLRotationSingleUserRolePolicy-${var.resource_name}"
  path = "/"
  policy = data.aws_iam_policy_document.SecretsManagerRDSMySQLRotationSingleUserRolePolicy[0].json
}

resource "aws_iam_policy_attachment" "SecretsManagerRDSMySQLRotationSingleUserRolePolicy" {
  count = var.enable_secret_rotation ? 1 : 0
  name = "SecretsManagerRDSMySQLRotationSingleUserRolePolicy-${var.resource_name}"
  roles = [aws_iam_role.lambda_rotation[0].name]
  policy_arn = aws_iam_policy.SecretsManagerRDSMySQLRotationSingleUserRolePolicy[0].arn
}

resource "aws_security_group" "lambda" {
  vpc_id = data.aws_subnet.firstsub.vpc_id
  name = "Lambda-SecretManager-${var.resource_name}"
  tags = {
      Name  = "Lambda-SecretManager-${var.resource_name}"
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

variable "filename" { default = "rotate-code-mysql"}

resource "aws_lambda_function" "rotate-code-mysql" {
  count = var.enable_secret_rotation ? 1 : 0
  filename           = "${path.module}/${var.filename}.zip"
  function_name      = "${var.resource_name}-${var.filename}"
  role               = aws_iam_role.lambda_rotation[0].arn
  handler            = "lambda_function.lambda_handler"
  source_code_hash   = filebase64sha256("${path.module}/${var.filename}.zip")
  runtime            = "python2.7"
  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }
  timeout            = 30
  description        = "Conducts an AWS SecretsManager secret rotation for RDS MySQL using single user rotation scheme"
  environment {
    variables = { #https://docs.aws.amazon.com/general/latest/gr/rande.html#asm_region
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.${data.aws_region.current.name}.amazonaws.com"
    }
  }
}

resource "aws_lambda_permission" "allow_secret_manager_call_Lambda" {
  count = var.enable_secret_rotation ? 1 : 0  
  function_name = aws_lambda_function.rotate-code-mysql[0].function_name
  statement_id = "AllowExecutionSecretManager"
  action = "lambda:InvokeFunction"
  principal = "secretsmanager.amazonaws.com"
}

data "aws_iam_policy_document" "secret_kms_policy" { 
  statement {
    sid = "Enable IAM User Permissions"
    actions = ["kms:*"]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

data "aws_iam_policy_document" "secret_kms_policy_with_rotation" {
  statement {
    sid = "Enable IAM User Permissions"
    actions = ["kms:*"]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid = "Allow use of the key"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = var.enable_secret_rotation ? [aws_iam_role.lambda_rotation[0].arn] : [""]
    }
  }

  statement {
    sid = "Allow attachment of persistent resources"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = var.enable_secret_rotation ? [aws_iam_role.lambda_rotation[0].arn] : [""]
    }
    condition {
      test = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values = ["true"]
    }
  }
}

resource "aws_kms_key" "secret" {
  description = "Key for secret ${var.resource_name}"
  enable_key_rotation = true
  policy = var.enable_secret_rotation ? data.aws_iam_policy_document.secret_kms_policy_with_rotation.json : data.aws_iam_policy_document.secret_kms_policy.json
}

resource "aws_kms_alias" "secret" {
  name = "alias/${var.resource_name}"
  target_key_id = aws_kms_key.secret.key_id
}

resource "aws_secretsmanager_secret" "secret" {
  description = var.secret_description
  kms_key_id = aws_kms_key.secret.key_id
  name = var.resource_name
  recovery_window_in_days = var.recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "secret" {
  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
  secret_id = aws_secretsmanager_secret.secret.id
  secret_string = <<EOF
{
  "username": "${var.db_client_username}",
  "engine": "${var.db_engine_family}",
  "dbname": "${var.application_name}",
  "host": "${var.host_endpoint}",
  "password": "${var.db_client_password == "" ? random_password.password[0].result : var.db_client_password}",
  "port": "${var.port}",
  "dbInstanceIdentifier": "${var.resource_name}",
  "readonlyhost": "${(var.reader_endpoint != null ? var.reader_endpoint : "")}",
  "proxyhost": "${var.proxy_endpoint}"
}
  EOF
}

resource "aws_secretsmanager_secret_rotation" "rotation" {
  count = var.enable_secret_rotation ? 1 : 0
  secret_id           = aws_secretsmanager_secret.secret.id
  rotation_lambda_arn = aws_lambda_function.rotate-code-mysql[0].arn
  rotation_rules {
    automatically_after_days = var.rotation_days
  }
}

resource "random_password" "password" {
  count = var.db_client_password == "" ? 1 : 0
  length = 16
  special = true
  override_special = "_%@"
}

data "aws_iam_user" "service_iam_user" {
    count = var.service_iam_username != null ? 1 : 0
    user_name = var.service_iam_username
}

data "aws_iam_policy_document" "policy_document" {
	statement {
	effect = "Allow"
	actions = ["secretsmanager:GetSecretValue"]
	resources = [aws_secretsmanager_secret.secret.arn]
    }
	statement {
		effect = "Allow"
		actions = [
			"kms:Decrypt",
			"kms:GenerateDataKey*"
		]
		resources = ["${aws_kms_alias.secret.target_key_arn}"]
	}
}

resource "aws_iam_policy" "policy" {
    count = var.service_iam_username != null ? 1 : 0
    name = "${var.application_name}-rdssecretspolicy${var.suffix_separator}${var.suffix}"
    policy = "${data.aws_iam_policy_document.policy_document.json}"
}

resource "aws_iam_user_policy_attachment" "policy_attachment" {
    count = var.service_iam_username != null ? 1 : 0
    user = data.aws_iam_user.service_iam_user[0].user_name
    policy_arn = "${aws_iam_policy.policy[0].arn}"
}