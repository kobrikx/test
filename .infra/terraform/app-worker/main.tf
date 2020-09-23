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
  recreate_asg_when_lc_changes = true

  root_block_device = [
    {
      volume_size = var.root_block_device_size
      volume_type = var.root_block_device_type
    },
  ]

  user_data                 = data.template_file.asg_ecs_user_data.rendered
  vpc_zone_identifier       = var.private_subnets
  health_check_type         = var.health_check_type
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "env"
      value               = var.env
      propagate_at_launch = true
    },
    {
      key                 = "cluster"
      value               = local.namespace
      propagate_at_launch = true
    },
    {
      key                 = "service-groups"
      value               = var.service_group
      propagate_at_launch = true
    },
  ]
}

module "ecr" {
  source  = "hazelops/ecr/aws"
  version = "~> 1.0"

  name    = local.ecr_repo_name
  enabled = var.create_ecr_repo
}

module "efs" {
  source  = "cloudposse/efs/aws"
  version = "~> 0.18"

  enabled   = var.efs_enabled
  namespace = var.namespace
  stage     = var.env
  name      = var.name
  region    = data.aws_region.current.name
  vpc_id    = var.vpc_id

  # This is a workaround for 2-zone legacy setups
  subnets = length(regexall("legacy", var.env)) > 0 ? [
    var.private_subnets[0],
  var.private_subnets[1]] : var.private_subnets
  security_groups = var.security_groups
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

// Cloud9 IDE Debug tool
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

  env              = var.env
  name             = var.name
  namespace        = var.namespace
  ecs_service_name = local.ecs_service_name

  # This is needed for adding features from newer platforms
  ecs_platform_version     = var.ecs_launch_type == "FARGATE" ? var.ecs_platform_version : null
  service_type             = var.service_type
  service_group            = var.service_group
  docker_container_port    = var.docker_container_port
  ecs_network_mode         = var.ecs_network_mode
  docker_container_command = var.docker_container_command
  cpu                      = var.cpu
  memory                   = var.memory
  volumes                  = local.volumes
  subnets                  = var.private_subnets
  security_groups          = var.security_groups

  #List of Cron-like Cloudwatch Event Rule(schedule expressions).
  schedule_expression = var.schedule_expression
  #[INFO] Can be removed if not needed

  deployment_minimum_healthy_percent          = var.deployment_minimum_healthy_percent
  aws_service_discovery_private_dns_namespace = var.aws_service_discovery_private_dns_namespace

  resource_requirements = var.gpu > 0 ? [
    {
      type  = "GPU"
      value = tostring(var.gpu)
  }] : []

  sidecar_container_definitions = concat(
    var.datadog_enabled ? [
    module.datadog.container_definition] : []
  )

  ecs_cluster_name          = local.ecs_cluster_name
  ecs_launch_type           = var.ecs_launch_type
  service_desired_count     = var.desired_capacity
  ecs_service_deployed      = var.schedule_expression == [] ? false : true
  docker_image_name         = var.docker_image_name != "" ? var.docker_image_name : "${var.docker_registry}/${var.namespace}-${var.name}"
  docker_image_tag          = var.docker_image_tag
  iam_role_policy_statement = var.iam_role_policy_statement
  secret_names              = var.secret_names

  environment = merge(var.environment, {
    DD_SERVICE_NAME = var.name
  })

}

