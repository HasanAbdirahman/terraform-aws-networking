locals {
  output_public_subnets = {
    for key in keys(local.public_subnets) : key => {
      availability_zone = aws_subnet.this[key].availability_zone
      subnet_id         = aws_subnet.this[key].id
    }
  }
  output_private_subnets = {
    for key in keys(local.private_subnets) : key => {
      availability_zone = aws_subnet.this[key].availability_zone
      subnet_id         = aws_subnet.this[key].id
    }
  }
}

output "vpc_id" {
  description = "value of the vpc id"
  value       = aws_vpc.this.id
}

output "public_subnets" {
  value       = local.output_public_subnets
  description = "value of the public subnets"
}

output "private_subnets" {
  value       = local.output_private_subnets
  description = "value of the private subnets"
}
