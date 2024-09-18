resource "aws_key_pair" "root" {
  key_name   = var.ec2_key_pair_name
  public_key = var.ssh_public_key

  lifecycle {
    ignore_changes = [
      public_key
    ]
  }
}
module "vpc" {
  source  = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.env}-vpc"
  cidr = "10.30.0.0/16"

  azs = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ]
  public_subnets = [
    "10.30.10.0/23",
    "10.30.12.0/23",
    "10.30.14.0/23"
  ]



  private_subnets = [
    "10.30.20.0/23",
    "10.30.22.0/23",
    "10.30.24.0/23"
  ]
  //  database_subnets    = ["10.0.21.0/24", "10.0.22.0/24"]
  //  elasticache_subnets = ["10.0.31.0/24", "10.0.32.0/24"]
  //
  enable_nat_gateway = var.nat_gateway_enabled
  //  single_nat_gateway = var.env == "prod" ? false : true
  single_nat_gateway = true
  enable_vpn_gateway = false

  enable_dns_hostnames       = true
  enable_dns_support         = true
  manage_default_network_acl = true
  default_network_acl_name   = "${var.env}-${var.namespace}"
  tags                       = {
    Terraform = "true"
    Env       = var.env
  }
}

resource "aws_security_group" "default_permissive" {
  name        = "${var.env}-default-permissive"
  vpc_id      = module.vpc.vpc_id
  description = "Managed by Terraform"



  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform = "true"
    Env       = var.env
    Name      = "${var.env}-default-permissive"
  }
}
