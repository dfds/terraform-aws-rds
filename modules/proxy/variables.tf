variable "resource_name" {
    description = "Constructed name to use for the resource"
}

variable "vpc_id" {
    description = "Id of the VPC in which to deploy"
}

variable "common_tags" {
    description = "Tags for the resources"
}

variable "secret_arn" {
    description = "Secret Manager Value Arn"
}

variable "secret_kms_arn" {
    description = "Secret Manager Value KMS Arn"
}

variable "port" {
    default = 3306
    description = "The port on which the DB accepts connections. Defaults to 3306"
}

variable "security_group_id" {
    description = "Id of the security group"
}

variable "proxy_debug_logging" {
    description = "Turn on debug logging for the proxy"
    default = false
}

variable "idle_client_timeout" {
    description = "Idle client timeout of the RDS proxy (keep connection alive)"
    default = 1800
}

variable "proxy_require_tls" {
    description = "Require tls on the RDS proxy. Default: true"
    default = true
}

variable "data_subnet_ids" {
    description = "List of the data subnets that the database belongs in"
    type = list
}

variable "db_engine_family" {
    description = "The engine family either MYSQL or POSTGRESQL (defaults to MYSQL)"
    default = "MYSQL"
}

variable "cluster_identifier" {
    description = "DB Cluster Identifier"
    type = string
    default = null
}

variable "instance_identifier" {
    description = "DB Instance Identifier"
    type = string
    default = null
}