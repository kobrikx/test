variable "env" {}
variable "vpc_id" {}
variable "root_domain_name" {}
variable "zone_id" {}
variable "public_subnets" {}
variable "ec2_key_pair_name" {}
variable "instance_type" {
  default = "t3.nano"
}
variable "name" {
  default = "bastion"
}
variable "ext_security_groups" {
  description = "External security groups to add to bastion host"
  type = list(any)
  default = []
}
