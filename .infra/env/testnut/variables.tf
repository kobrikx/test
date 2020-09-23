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

variable "docker_registry" {}

variable "docker_image_tag" {}
