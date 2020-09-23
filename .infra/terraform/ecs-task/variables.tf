variable "env" {}

variable "name" {}

variable "memory_reservation" {
  default = 256
}

variable "cpu" {
  default     = 256
  description = "Fargate CPU value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
}

variable "memory" {
  default     = 512
  description = "Fargate Memory value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
}


variable "environment" {
  //  type = list(object({name=string, value=string}))
  type = map(string)
}

variable "secret_names" {
  type    = list(string)
  default = []
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

variable "port_mappings" {
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

variable "sidecar_container_definitions" {
  default = []
}

variable "task_group" {
  type    = string
  default = "api"
}

variable "iam_role_policy_statement" {
  default = []
}

variable "ecs_launch_type" {
  default = "FARGATE"
}

variable "ecs_network_mode" {
  default = "awsvpc"
}

variable "ecs_network_configuration" {
  default = {}
  type    = map(any)
}

variable "ecs_task_family_name" {
  default = ""
}

variable "resource_requirements" {
  default = []
}

variable "volumes" {
  default = []
}

# https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
variable "schedule_expression" {
  description = "List of Cron-like Cloudwatch Event Rule schedule expressions"
  type        = list
  default     = []
}

locals {
  secret_names                = concat(var.secret_names, [])
  environment                 = merge(var.environment, {})
  docker_container_command    = (var.docker_container_command == [] ? [] : var.docker_container_command)
  docker_container_entrypoint = (var.docker_container_entrypoint == [] ? [] : var.docker_container_entrypoint)

  container_definitions = concat(var.sidecar_container_definitions, [
    {
      "name"    = var.name
      "command" = local.docker_container_command

      "image"                = "${var.docker_image_name}:${var.docker_image_tag}"
      "resourceRequirements" = var.resource_requirements

      "cpu"               = var.cpu
      "memoryReservation" = var.memory_reservation
      "essential"         = true

      mountPoints = [
        for volume in var.volumes :
        lookup(volume, "mount_point", {})
      ]

      environment    = [for k, v in local.environment : { name = k, value = v }]
      "secrets"      = module.ssm.secrets
      "portMappings" = var.port_mappings
      "PlacementConstraints" = var.ecs_launch_type == "EC2" ? [
        {
          "type"       = "memberOf"
          "expression" = "attribute:service-group == ${var.task_group}"
        }
      ] : []

      logConfiguration = {
        "logDriver" = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "main"
        }
      }
      dependsOn = var.docker_container_depends_on
      # TODO: Make it work with foreach
      // lookup(var.volumes, "docker_volume_configuration", [])
      // length(var.volumes > 0) ? var.volumes[0]["mount_point"] : []
    }
  ])


  iam_role_policy = {
    "Version" = "2012-10-17",
    "Statement" = concat(var.iam_role_policy_statement, [
      {
        "Effect" = "Allow",
        "Action" = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" = "*"
      },
      {
        "Effect" = "Allow",
        "Action" = [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        "Resource" = [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${module.ssm.ssm_parameter_path}/*"
        ]
      }
    ])
  }
}

