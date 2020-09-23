data "aws_caller_identity" "current" {}

data "aws_route53_zone" "root" {
  name         = "${var.root_domain_name}."
  private_zone = false
}

data "template_file" "asg_ecs_user_data" {
  template = file("${path.module}/ecs_user_data.sh.tpl")

  vars = {
    ecs_cluster_name = local.ecs_cluster_name
    service_group    = var.service_group
  }
}