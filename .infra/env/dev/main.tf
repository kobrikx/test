provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

resource "aws_key_pair" "root" {
  key_name = var.ec2_key_pair_name
  public_key = var.ssh_public_key
}

data "aws_ami" "amazon_linux_ecs_generic" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"

  name = "${var.env}-vpc"
  cidr = "10.30.0.0/16"

  azs             = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ]
  public_subnets  = [
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
  enable_nat_gateway = true
//  single_nat_gateway = var.env == "prod" ? false : true
  single_nat_gateway = true
  enable_vpn_gateway = false
  enable_s3_endpoint = true
  enable_ecr_api_endpoint = true
  ecr_api_endpoint_security_group_ids = [aws_security_group.default_permissive.id]
  enable_ecr_dkr_endpoint = true
  ecr_dkr_endpoint_security_group_ids = [aws_security_group.default_permissive.id]
  enable_dns_hostnames = true
  enable_dns_support = true

  manage_default_network_acl = true

  tags = {
    Terraform   = "true"
    Env = var.env
  }
}


data "aws_route53_zone" "root" {
  name         = "${var.root_domain_name}."
  private_zone = false
}

resource "aws_route53_record" "env_ns_record" {
  zone_id = data.aws_route53_zone.root.id
  name =  "${var.env}.${var.root_domain_name}"
  type = "NS"
  //  ttl  = "172800"

  // Fast TTL for dev
  ttl  = "60"
  records = aws_route53_zone.env_domain.name_servers
}


resource "aws_route53_zone" "env_domain" {
  name = "${var.env}.${var.root_domain_name}"
}

resource "aws_security_group" "default_permissive" {
  name   = "${var.env}-default-permissive"
  vpc_id = module.vpc.vpc_id

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
    Terraform   = "true"
    Env = var.env
    Name = "${var.env}-default-permissive"
  }
}


module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 2.0"

  name    = "${var.env}-${var.namespace}"
}

module "ec2_profile" {
  source = "terraform-aws-modules/ecs/aws//modules/ecs-instance-profile"
  name    = "${var.env}-${var.namespace}"
}

module "bastion" {
  source = "hazelops/ec2-bastion/aws"
  version = "~> 1.0"
  env = var.env
  vpc_id = local.vpc_id
  zone_id = local.zone_id
  public_subnets = local.public_subnets
  ec2_key_pair_name = local.ec2_key_pair_name
}

output "cmd" {
  description = "Map of useful commands"
  value = {
    tunnel = module.bastion.cmd
  }
}

output "ssh_forward_config" {
  value = module.bastion.ssh_config
}

module "env_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 2.0"

  domain_name =  "${local.env}.${local.root_domain_name}"

  subject_alternative_names = [
    "*.${local.env}.${local.root_domain_name}"
  ]

  zone_id     = local.zone_id

  tags = {
    Name = "${var.env}.${var.root_domain_name}"
  }
}


# These are generic defaults. Feel free to reuse.
locals {
  env = var.env
  namespace = var.namespace
  public_subnets = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  security_groups = [aws_security_group.default_permissive.id]

  iam_instance_profile = module.ec2_profile.this_iam_instance_profile_id
  key_name = var.ec2_key_pair_name
  image_id = data.aws_ami.amazon_linux_ecs_generic.id
  root_domain_name = var.root_domain_name
  zone_id = aws_route53_zone.env_domain.id
  vpc_id = module.vpc.vpc_id
  alb_security_groups = [aws_security_group.default_permissive.id]
  docker_registry = var.docker_registry
  docker_image_tag = var.docker_image_tag
  ec2_key_pair_name = var.ec2_key_pair_name
  tls_cert_arn = module.env_acm.this_acm_certificate_arn
}
