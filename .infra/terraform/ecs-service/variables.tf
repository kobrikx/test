variable "env" {
}

variable "name" {}

variable "namespace" {}

variable "memoryReservation" {
  default = 1024
}
variable "environment" {
  //  type = list(object({name=string, value=string}))
  type = map(string)
}

variable "ecs_platform_version" {
  default = "LATEST"
}

variable "secret_names" {
  type = list(string)
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_service_name" {
  type    = string
  default = ""
}

variable "docker_image_name" {
  type = string
}

variable "docker_image_tag" {
  type = string
}

variable "docker_container_port" {
  type    = number
  default = 3000
}

variable "alb_aux_ports" {
  default = []
}

variable "docker_container_command" {
  type    = list(string)
  default = []
}

variable "docker_container_entrypoint" {
  type    = list(string)
  default = []
}

variable "docker_container_depends_on" {
  type    = list(any)
  default = []
}

variable "service_type" {
  type = string
}

variable "service_group" {
  type = string
}

variable "service_desired_count" {
  default = 1
}

variable "deployment_minimum_healthy_percent" {
  default = 100
}
variable "target_group_arn" {
  default = null

}

variable "sidecar_container_definitions" {
  default = []
}

variable "iam_role_policy_statement" {
  default = []
}

variable "ecs_launch_type" {
  default = "FARGATE"
}

variable "cpu" {
  default     = 256
  description = "Fargate CPU value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
}

variable "memory" {
  default     = 512
  description = "Fargate Memory value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
}

variable "subnets" {
  default = []
}

variable "security_groups" {
  default = []
}

variable "assign_public_ip" {
  default = false
}

variable "ecs_service_discovery_enabled" {
  default = false
}

variable "aws_service_discovery_private_dns_namespace" {
  default = ""
}

variable "ecs_network_mode" {
  default = "awsvpc"
}


variable "resource_requirements" {
  default = []
}

variable "volumes" {
  default = []
}

variable "ecs_service_deployed" {
  default = false
}

# https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
variable "schedule_expression" {
  description = "List of Cron-like Cloudwatch Event Rule schedule expressions"
  type        = list
  default     = []
}

locals {
  web_service_types = ["web", "api", "proxy"]
  secret_names      = concat(var.secret_names, [])
  environment       = merge(var.environment, {})
  port_mappings = (contains(local.web_service_types, var.service_type) ?
    [
      {
        containerPort = var.docker_container_port,
        // In case of bridge an host use a dynamid port (0)
        hostPort = var.ecs_network_mode == "awsvpc" ? var.docker_container_port : 0
      }
  ] : [])
}
