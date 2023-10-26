variable "resource_name" {
    description = "Constructed name to use for the resource"
}

variable "common_tags" {
    description = "Tags for the resources"
}

variable "private_subnet_ids" {
    description = "List of the private subnets that the database can communicate with"
    type = list
}

variable "secret_description" {
  description = "This field is the description for the secret manager object"
}

variable "rotation_days" {
  description = "How often in days the secret will be rotated"
}

variable "recovery_window_in_days" {
  description = "How many days it will take to delete the secret"
}

variable "db_client_username" {
  description = "The MySQL/Aurora username you chose during RDS creation or another one that you want to rotate"
}

variable "db_client_password" {
  description = "The password that you want to rotate, this will be changed after the creation"
}

variable "enable_secret_rotation" {
    description = "Provision a lambda to rotate the secret (defaults to true)"
    default = true
}

variable "application_name" {
  description = "The name of the application. Used to name and tag resources. This CAN NOT contain hyphens or underscores"
}

variable "host_endpoint" {
  description = "Host Endpoint"
}

variable "reader_endpoint" {
  description = "Reader Endpoint"
}

variable "proxy_endpoint" {
  description = "Proxy Endpoint"
}

variable "db_engine_family" {
  description = "DB Engine Family"
}

variable "port" {
  description = "Database port"
}

variable "service_iam_username" {
  description = "The service IAM username to add GetSecretValue permission to"
    type = string
    default = null
}

variable "suffix" {
    description = "Suffix used for naming resources. I.e applicationname-suffix. Leave blank if not required"
    default = ""
}

variable "suffix_separator" {
    description = "Suffix separator used for naming resources. For example, defining _ will name resources as applicationname_suffix. Defining - will name resources as applicationname-suffix. Leave blank if not required"
    default = ""
}