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

  # Outbound https to data subnet
  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = var.cidr_block_data_subnet
  }
}