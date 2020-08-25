data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  web_service_types = ["web", "api", "proxy", "squibby"]
//  secret_names = concat(var.secret_names, [])
  environment = merge(var.environment, {})
  port_mappings = (contains(local.web_service_types, var.service_type) ?
  [
    {
      containerPort = var.docker_container_port,
      // In case of bridge an host use a dynamid port (0)
      hostPort = var.ecs_network_mode == "awsvpc" ? var.docker_container_port : 0
    }
  ] : [] )
}

module "task" {
  source = "../ecs-task"
  env = var.env
  name = var.name
  ecs_launch_type = var.ecs_launch_type
  docker_image_name = var.docker_image_name
  docker_image_tag = var.docker_image_tag
  docker_container_entrypoint = (var.docker_container_entrypoint == [] ? [] : var.docker_container_entrypoint)
  docker_container_command = (var.docker_container_command == [] ? [] : var.docker_container_command)
  environment = var.environment
//  secret_names = local.secret_names
  port_mappings = local.port_mappings
  cpu = var.cpu
  memory = var.memory
  iam_role_policy_statement = var.iam_role_policy_statement
  sidecar_container_definitions = var.sidecar_container_definitions
  ecs_network_mode = var.ecs_network_mode
}


resource "aws_service_discovery_service" "this" {
  name = var.name
  count = var.ecs_service_discovery_enabled ? 1 : 0

  dns_config {
    namespace_id = var.ecs_service_discovery_enabled ? var.aws_service_discovery_private_dns_namespace.id : ""
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl = 10
      type = "A"
    }

    dns_records {
      ttl  = 10
      type = "SRV"
    }
  }
  health_check_custom_config {
    failure_threshold = 5
  }
}

resource "aws_ecs_service" "this" {
  name = "${var.env}-${var.name}"
  cluster = var.ecs_cluster
  task_definition = module.task.task_definition_arn
  desired_count = var.service_desired_count
  launch_type = var.ecs_launch_type


  dynamic "service_registries" {
    for_each = (var.ecs_launch_type == "FARGATE" && var.ecs_service_discovery_enabled) ? [1] : []
    content {
      registry_arn = var.ecs_service_discovery_enabled ? aws_service_discovery_service.this.arn : ""
      port = var.docker_container_port
    }
  }

  dynamic "network_configuration" {
    for_each = var.ecs_launch_type == "FARGATE" ? [1] : []
    content {
      subnets = var.subnets
      security_groups = var.security_groups
      assign_public_ip = var.assign_public_ip
    }
  }

  dynamic "load_balancer" {
    for_each = local.port_mappings
    content {
      target_group_arn = var.target_group_arn
      container_name   = var.name
      container_port   = var.docker_container_port
    }
  }

  dynamic "placement_constraints" {
    for_each = var.ecs_launch_type == "EC2" ? [1] : []
    content {
      type       = "memberOf"
      expression = "attribute:service-group == ${var.service_group}"
    }
  }

  // Do not overwite external updates back to Terraform value
  // This means we only set that value once - during creation.
  lifecycle {
    ignore_changes = [
      // Ignore as we use SCALE to change the settings.
//      desired_count,
      // Ignore Task Definition ARN changes.
      // Every time we deploy via ecs-deploy and then run Terraform
      //   we will keep the Task Definition deployed with via ecs-delploy
      task_definition
    ]
  }
}
