locals {
  name = "${var.env}-${var.name}"
  name_prefix = "${substr(var.name, 0, 5)}-"
  namespace = "${var.env}-${var.namespace}"
  //  domain_names = concat( ["${var.name}.${var.env}.${var.root_domain_name}"], var.domain_names)
  domain_names = ["${var.name}.${var.env}.${var.root_domain_name}"]
}

data "aws_route53_zone" "root" {
  name         = "${var.root_domain_name}."
  private_zone = false
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"
  create_asg = var.ecs_launch_type == "EC2" ? true : false
  create_lc = var.ecs_launch_type == "EC2" ? true : false
  name = local.name

  # Launch configuration
  lc_name = local.name
  # Auto scaling group
  asg_name                  = local.name

  image_id             = var.image_id
  instance_type        = var.instance_type
  security_groups      = var.security_groups
  iam_instance_profile = var.iam_instance_profile
  key_name             = var.key_name
  target_group_arns    = module.alb.target_group_arns
  recreate_asg_when_lc_changes = true

  # TODO: place this into a file if needed, as now we don't have any other tpl files yet, and we're not modularized here
  user_data = <<-EOT
    #!/bin/bash
    # ECS config
    {
      echo "ECS_CLUSTER=${local.namespace}"
      echo "ECS_INSTANCE_ATTRIBUTES={\"service-group\":\"${var.service_group}\"}"
    } >> /etc/ecs/ecs.config
    start ecs
    echo "Done"
  EOT

  vpc_zone_identifier       = var.private_subnets
  health_check_type         = var.health_check_type
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  wait_for_capacity_timeout = 0


  tags = [
    {
      key                 = "Env"
      value               = var.env
      propagate_at_launch = true
    },
    {
      key                 = "Cluster"
      value               = local.namespace
      propagate_at_launch = true
    },
  ]
}




module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name = local.name

  load_balancer_type = "application"

  vpc_id          = var.vpc_id
  security_groups = var.alb_security_groups

  subnets         = var.public ? var.public_subnets : var.private_subnets

  //  # See notes in README (ref: https://github.com/terraform-providers/terraform-provider-aws/issues/7987)
  //  access_logs = {
  //    bucket = module.log_bucket.this_s3_bucket_id
  //  }

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    },
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = var.tls_cert_arn
      target_group_index = 0
    },
  ]

  target_groups = [
    {
      name_prefix          = local.name_prefix

      backend_protocol     = "HTTP"
      backend_port         = var.docker_container_port
      target_type          = var.ecs_launch_type == "EC2" ? "instance" : "ip"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = var.alb_health_check_path
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      },
      tags = {
        Name = var.name
        env = var.env
        app = local.name
      }
    }
  ]

  tags = {
    env     = var.env
    Env     = var.env
  }
}

// Datadog Monitoring Module (can be enabled/disabled via datadog_enabled)
module "datadog" {
  source = "hazelops/ecs-datadog-agent/aws"
  version = "~> 1.0"


  app_name = var.name
  env = var.env
  cloudwatch_log_group = module.service.cloudwatch_log_group
  ecs_launch_type = var.ecs_launch_type
}

// Cloud9 IDE Debug tool
module "cloud9" {
  source = "hazelops/ecs-cloud9/aws"
  version = "~> 1.0"
  app_name = var.name
  env = var.env
  environment = var.environment
  cloudwatch_log_group = module.service.cloudwatch_log_group
  ecs_launch_type = var.ecs_launch_type
  ecs_network_mode = var.ecs_network_mode
}

module "service" {
  env = var.env
  name = var.name
  service_type = var.service_type
  service_group = var.service_group
  source = "../../terraform/ecs-service"
  docker_container_port = var.docker_container_port
  ecs_network_mode = var.ecs_network_mode
  cpu = var.cpu
  memory = var.memory
  subnets = var.private_subnets
  security_groups = var.security_groups
  aws_service_discovery_private_dns_namespace = var.aws_service_discovery_private_dns_namespace

  sidecar_container_definitions = concat(
  var.datadog_enabled ? [module.datadog.container_definition] : [],
  var.cloud9_enabled ? [module.cloud9.container_definition] : [],
  )

  ecs_launch_type = var.ecs_launch_type
  service_desired_count = var.desired_capacity
  docker_image_name = "${var.docker_registry}/${var.namespace}-${var.name}"
  docker_image_tag = var.docker_image_tag
  ecs_cluster = local.namespace
  iam_role_policy_statement = var.iam_role_policy_statement

  environment = merge(var.environment, {
    DD_SERVICE_NAME = var.name
  })

//  secret_names = var.secret_names

  // TODO: instead of hardcoding the index, better use dynamic lookup by a canonical name
  target_group_arn = length(module.alb.target_group_arns) >= 1 ? module.alb.target_group_arns[0] : ""
}

resource "aws_route53_record" "this" {
  count = length(local.domain_names)
  zone_id = var.zone_id
  name = local.domain_names[count.index]
  type = "A"

  alias {
    name                   = module.alb.this_lb_dns_name
    zone_id                = module.alb.this_lb_zone_id
    evaluate_target_health = true
  }
}

module "ecr" {
  source = "hazelops/ecr/aws"
  version = "~> 1.0"
  name = "${var.namespace}-${var.name}"
}

data "aws_caller_identity" "current" {}
