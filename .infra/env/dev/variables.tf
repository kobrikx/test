# TODO: encapsulate everything into modules, like "api" or "job" which would use terraform locals

variable "env" {}

variable "namespace" {
  default = "nutcorp"
}

variable "aws_profile" {}

variable "aws_region" {
  default = "us-east-1"
}

variable "ssh_public_key" {}

variable "root_domain_name" {
  default = "nutcorp.net"
}

variable "ec2_key_pair_name" {
  default = "dev-nutcorp"
}



variable "nat_gateway_enabled" {
  default = true
  description = "Set it to true to enable NAT Gateway, otherwise nat-instance module will be used"
}

variable "monitor_enabled" {
  default = true
}

# These are generic defaults. Feel free to reuse.
locals {
  env                  = var.env
  namespace            = var.namespace
  public_subnets       = module.vpc.public_subnets
  private_subnets      = module.vpc.private_subnets
  key_name             = aws_key_pair.root.key_name
  image_id             = data.aws_ami.amazon_linux_ecs_generic.id
  root_domain_name     = var.root_domain_name
  vpc_id               = module.vpc.vpc_id
  security_groups      = [aws_security_group.default_permissive.id]
  alb_security_groups  = [aws_security_group.default_permissive.id]
}
