variable "vpc_config" {
  description = "Contains the VPC configuration. More specifically, the required cidr block and name"
  type = object({
    cidr_block = string
    name       = string
  })
  validation {
    condition     = can(cidrnetmask(var.vpc_config.cidr_block))
    error_message = "The vpc cidr must be have valid CIDR block"
  }
}

variable "subnet_config" {
  description = <<-eot
  Shows the subnet configuration and if it's private and public.
  eot

  type = map(object({
    cidr_block = string
    az         = string
    public     = optional(bool, false)
  }))
  validation {
    condition     = alltrue([for subnet in values(var.subnet_config) : can(cidrnetmask(subnet.cidr_block))])
    error_message = "The subnet cidr must be have valid CIDR block"
  }
}
