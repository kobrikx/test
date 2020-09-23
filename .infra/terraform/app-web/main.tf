module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"

  create_asg = var.ecs_launch_type == "EC2" ? true : false
  create_lc  = var.ecs_launch_type == "EC2" ? true : false
  name       = local.name

  # Launch configuration
  lc_name = local.name

  # Auto scaling group
  asg_name                     = local.name
  image_id                     = var.image_id
  instance_type                = var.instance_type
  security_groups              = var.security_groups
  iam_instance_profile         = var.iam_instance_profile
  key_name                     = var.key_name
  target_group_arns            = module.alb.target_group_arns
  recreate_asg_when_lc_changes = true
  user_data                    = data.template_file.asg_ecs_user_data.rendered

  vpc_zone_identifier       = var.private_subnets
  health_check_type         = var.health_check_type
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Env"
      values              = var.env
      propagate_at_launch = true
    },
    {
      key                 = "Cluster"
      value               = local.namespace
      propagate_at_launch = true
  }, ]
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name               = local.name
  load_balancer_type = "application"
  internal           = var.public ? false : true
  vpc_id             = var.vpc_id
  security_groups    = var.alb_security_groups
  subnets            = var.public ? var.public_subnets : var.private_subnets

  //  # See notes in README (ref: https://github.com/terraform-providers/terraform-provider-aws/issues/7987)
  //  access_logs = {
  //    bucket = module.log_bucket.this_s3_bucket_id
  //  }

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
  }, ]

  https_listeners = concat(
    [
      {
        port               = 443
        protocol           = "HTTPS"
        certificate_arn    = var.tls_cert_arn
        target_group_index = 0
    }, ], var.cloud9_enabled ?
    [
      {
        port               = 18443
        protocol           = "HTTPS"
        certificate_arn    = var.tls_cert_arn
        target_group_index = 1
  }, ] : [])

  target_groups = concat([
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
        matcher             = var.alb_health_check_valid_response_codes
      }

      tags = {
        Name = var.name
        env  = var.env
        app  = local.name
      }
    }], var.cloud9_enabled ? [
    {
      name_prefix      = local.name_prefix
      backend_protocol = "HTTP"
      // TODO: Add dynamic cloud9 port here
      backend_port         = local.cloud9_port
      target_type          = var.ecs_launch_type == "EC2" ? "instance" : "ip"
      deregistration_delay = 10

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/ide.html"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        // We're ok with 401 - unauthorized for cloud9
        matcher = "200-399,401"
      }

      tags = {
        Name = var.name
        env  = var.env
        app  = local.name
      }
    }] : []
  )

  tags = {
    env = var.env
    Env = var.env
  }
}

module "ecr" {
  source  = "hazelops/ecr/aws"
  version = "~> 1.0"

  name    = local.ecr_repo_name
  enabled = var.create_ecr_repo
}

// Datadog Monitoring Module (can be enabled/disabled via datadog_enabled)
module "datadog" {
  source  = "hazelops/ecs-datadog-agent/aws"
  version = "~> 1.0"

  app_name             = var.name
  env                  = var.env
  cloudwatch_log_group = module.service.cloudwatch_log_group
  ecs_launch_type      = var.ecs_launch_type
  enabled              = var.datadog_enabled
}

// Cloud9 IDE Debug tool.  (can be enabled/disabled via cloud9_enabled)
module "cloud9" {
  source  = "hazelops/ecs-cloud9/aws"
  version = "~> 1.0"

  app_name             = var.name
  env                  = var.env
  environment          = var.environment
  cloudwatch_log_group = module.service.cloudwatch_log_group
  ecs_launch_type      = var.ecs_launch_type
  ecs_network_mode     = var.ecs_network_mode
  enabled              = var.cloud9_enabled
}

module "service" {
  source = "../../terraform/ecs-service"

  env                   = var.env
  name                  = var.name
  namespace             = var.namespace
  ecs_service_name      = local.ecs_service_name
  ecs_platform_version  = var.ecs_launch_type == "FARGATE" ? var.ecs_platform_version : null
  service_type          = var.service_type
  service_group         = var.service_group
  docker_container_port = var.docker_container_port
  ecs_network_mode      = var.ecs_network_mode
  cpu                   = var.cpu
  memory                = var.memory
  volumes               = var.volumes
  subnets               = var.private_subnets
  security_groups       = var.security_groups

  docker_container_command                    = var.docker_container_command
  aws_service_discovery_private_dns_namespace = var.aws_service_discovery_private_dns_namespace

  sidecar_container_definitions = concat(
    var.datadog_enabled ? [
      module.datadog.container_definition] : [], var.cloud9_enabled ? [
    module.cloud9.container_definition] : []
  )

  docker_container_depends_on = concat(
    // TODO: This needs to be pulled from datadog agent module output
    var.datadog_enabled ? [
      {
        containerName = "datadog-agent",
        condition     = "START"
    }, ] : []
  )

  alb_aux_ports = var.cloud9_enabled ? [
    {
      name         = "cloud9"
      port         = local.cloud9_port
      target_group = length(module.alb.target_group_arns) >= 2 ? module.alb.target_group_arns[1] : ""
  }] : []

  ecs_cluster_name          = local.ecs_cluster_name
  ecs_launch_type           = var.ecs_launch_type
  service_desired_count     = var.desired_capacity
  ecs_service_deployed      = false
  docker_image_name         = var.docker_image_name != "" ? var.docker_image_name : "${var.docker_registry}/${var.namespace}-${var.name}"
  docker_image_tag          = var.docker_image_tag
  iam_role_policy_statement = var.iam_role_policy_statement
  secret_names              = var.secret_names

  environment = merge(var.environment, {
    DD_SERVICE_NAME = var.name
    APP_NAME        = var.name
  })
  #  TODO: instead of hardcoding the index, better use dynamic lookup by a canonical name
  target_group_arn = length(module.alb.target_group_arns) >= 1 ? module.alb.target_group_arns[0] : ""

}

resource "aws_route53_record" "this" {
  count   = length(local.domain_names)
  zone_id = var.zone_id
  name    = local.domain_names[count.index]
  type    = "A"

  alias {
    name                   = module.alb.this_lb_dns_name
    zone_id                = module.alb.this_lb_zone_id
    evaluate_target_health = true
  }
}

