variable "net_env" {
  description = " Deployment Environment - HCP VPC"
  type        = string
  default     = "hcp"
}

locals {
  net_vpc_cidr_block = "${var.net_subnet_block_prefix}0/${var.net_vpc_cidr_mask}"
  net_vpc_name       = "${var.net_env}-vpc"
  net_subnet_count   = length(var.net_priv_subnet_azs)
  net_newbits        = format(var.net_subnet_blocks - var.net_vpc_cidr_mask)
}

variable "net_aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "net_subnet_block_prefix" {
  description = "AWS VPC CIDR block Prefix"
  default     = "10.0.1."
}

variable "net_vpc_cidr_mask" {
  description = "VPC CIDR block subnet mask"
  default     = "24"
}

variable "net_subnet_blocks" {
  description = "Subnet mask for subnets created from VPC CIDR block"
  default     = "26"
}

variable "net_priv_subnet_azs" {
  description = "Availability zones withing the region"
  type        = list(string)
  default = [
    "us-east-1a"
  ]
}