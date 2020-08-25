data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {

  secret_names = concat(var.secret_names, [])

  environment = merge(var.environment, {})
  docker_container_command = (var.docker_container_command == [] ? [] : var.docker_container_command)
  docker_container_entrypoint = (var.docker_container_entrypoint == [] ? [] : var.docker_container_entrypoint)

  container_definitions = concat(var.sidecar_container_definitions, [
    {
      name              = var.name
      command           = local.docker_container_command

      image = "${var.docker_image_name}:${var.docker_image_tag}",
      memoryReservation = var.memory_reservation,
      essential = true,

      environment = [for k, v in local.environment : {name = k, value = v}]
      secrets = module.ssm.secrets

      portMappings = var.port_mappings
      PlacementConstraints = var.ecs_launch_type == "EC2" ? [
        {
          type       = "memberOf"
          expression = "attribute:service-group == ${var.task_group}"
        }
      ] : []

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group = aws_cloudwatch_log_group.this.name
          awslogs-region = data.aws_region.current.name
          awslogs-stream-prefix = "main"
        }
      }
    }
  ])


  iam_role_policy = {
    Version = "2012-10-17",
    Statement = concat(var.iam_role_policy_statement, [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        Resource = [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${module.ssm.ssm_parameter_path}/*"
        ]
      }
    ])
  }
}

resource "aws_iam_role_policy" "this" {
  name = "${var.env}-${var.name}-ecs-execution-role-policy"
  role = aws_iam_role.this.id
  policy = jsonencode(local.iam_role_policy)
}

resource "aws_iam_role" "this" {
  name = "${var.env}-${var.name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

module "ssm" {
  source = "hazelops/ssm-secrets/aws"
  version = "~> 1.0"
  env = var.env
  app_name = var.name
  names = local.secret_names
}

// TODO: Add ability to pass sidecar monitoring stuff here (defined globally somewhere else)
resource "aws_ecs_task_definition" "this" {
  family = "${var.env}-${var.name}"
  execution_role_arn = aws_iam_role.this.arn
  cpu = var.cpu
  memory = var.memory

  network_mode = var.ecs_network_mode

  requires_compatibilities = [
    var.ecs_launch_type]
  container_definitions = jsonencode(local.container_definitions)
}

resource "aws_cloudwatch_log_group" "this" {
  name = "${var.env}-${var.name}"

  tags = {
    Env = var.env
    Environment = var.env
    Application = "${var.env}-${var.name}"
  }
}
