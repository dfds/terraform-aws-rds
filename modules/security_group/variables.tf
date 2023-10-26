variable "resource_name" {
    description = "Constructed name to use for the resource"
}

variable "common_tags" {
    description = "Tags for the resources"
}

variable "vpc_id" {
    description = "Id of the VPC in which to deploy"
}

variable "port" {
    default = 3306
    description = "The port on which the DB accepts connections. Defaults to 3306"
}

variable "cidr_block_private_subnet" {
    type = list
    description = "A list of CIDR blocks for private subnets. Used for SQL security group"
}

variable "cidr_block_data_subnet" {
    type = list
    description = "A list of CIDR blocks for data subnets. Used for SQL security group"
}