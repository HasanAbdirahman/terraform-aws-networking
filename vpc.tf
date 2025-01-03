locals {
  public_subnets = {
    for key, config in var.subnet_config : key => config if config.public == true
  }
  private_subnets = {
    for key, config in var.subnet_config : key => config if !config.public
  }
}

data "aws_availability_zones" "this" {
  state = "available"
}
resource "aws_vpc" "this" {
  cidr_block = var.vpc_config.cidr_block
  tags = {
    Name = var.vpc_config.name
  }
}


resource "aws_subnet" "this" {
  for_each          = var.subnet_config
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = {
    Name   = each.key
    Access = each.value.public ? "Public" : "Private"
  }

  lifecycle {
    precondition {
      condition     = contains(data.aws_availability_zones.this.names, each.value.az)
      error_message = <<-EOT
          The AZ "${each.value.az}" provided for the subnet "${each.key}" is invalid.

          The AWS region "${data.aws_availability_zones.this.id}" only supports the following AZ
          "[${join("\n", data.aws_availability_zones.this.names)}
      EOT
    }
  }
}


resource "aws_internet_gateway" "igw" {
  count  = length(local.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "public" {
  count  = length(local.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }

}


resource "aws_route_table_association" "main" {
  for_each       = local.public_subnets
  route_table_id = aws_route_table.public[0].id
  subnet_id      = aws_subnet.this["${each.key}"].id
}
