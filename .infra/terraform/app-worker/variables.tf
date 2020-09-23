variable "env" {}

variable "namespace" {}

variable "name" {}

variable "ecs_service_name" {
  default = ""
}

variable "ecs_platform_version" {
  default = "LATEST"
}

variable "service_type" {
  default = "worker"
}

variable "service_group" {
  default = "worker"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "environment" {
  //  type = list(object({name=string, value=string}))
  type = map(string)
}

variable "public" {
  # TOOD: this should be changed to false when all services assume that
  default = false
}

variable "secret_names" {
  type = list(string)
}

variable "public_subnets" {}

variable "private_subnets" {}

variable "security_groups" {}

variable "iam_instance_profile" {}

variable "iam_role_policy_statement" {
  default = []
}

variable "key_name" {}

variable "image_id" {}

variable "root_domain_name" {
}
variable "domain_names" {
  default = []
}

variable "zone_id" {}

variable "vpc_id" {}

variable "docker_registry" {}

variable "docker_image_tag" {}

variable "docker_image_name" {
  default = ""
}

variable "docker_container_port" {
  default = 3000
}

variable "docker_container_command" {
  type    = list(string)
  default = []
}


variable "ecs_launch_type" {
  default = "FARGATE"
}

variable "ecs_cluster_name" {
  default = ""
}


variable "health_check_type" {
  default = "EC2"
}


variable "min_size" {
  default = 1
}

variable "max_size" {
  default = 1
}

variable "desired_capacity" {
  default = 1
}

variable "deployment_minimum_healthy_percent" {
  default = 50
}

variable "datadog_enabled" {
  default = true
}

variable "cloud9_enabled" {
  default = false
}

variable "cpu" {
  default     = 256
  description = "Fargate CPU value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
}

variable "memory" {
  default     = 512
  description = "Fargate Memory value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
}


variable "gpu" {
  default = 0
}

variable "aws_service_discovery_private_dns_namespace" {
  default = ""
}

variable "ecs_service_discovery_enabled" {
  default = false
}

variable "ecs_network_mode" {
  default = "awsvpc"
}

variable "create_ecr_repo" {
  default = false
}

variable "ecr_repo_name" {
  default = ""
}

variable "resource_requirements" {
  default = []
}

variable "root_block_device_size" {
  default = "50"
}

variable "root_block_device_type" {
  default = "gp2"
}

variable "volumes" {
  default = []
}

variable "efs_enabled" {
  default = false
}

variable "efs_mount_point" {
  default = "/mnt/efs"
}

variable "efs_root_directory" {
  default = "/"
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
  name             = "${var.env}-${var.name}"
  ecs_service_name = var.ecs_service_name != "" ? var.ecs_service_name : "${var.env}-${var.name}"
  name_prefix      = "${substr(var.name, 0, 5)}-"
  namespace        = "${var.env}-${var.namespace}"
  ecs_cluster_name = var.ecs_cluster_name != "" ? var.ecs_cluster_name : local.namespace
  //domain_names    = concat( ["${var.name}.${var.env}.${var.root_domain_name}"], var.domain_names)
  domain_names  = ["${var.name}.${var.env}.${var.root_domain_name}"]
  ecr_repo_name = var.ecr_repo_name != "" ? var.ecr_repo_name : "${var.namespace}-${var.name}"

  volumes = var.efs_enabled ? [
    {
      "name" = "efs",
      "mount_point" = {
        "sourceVolume"  = "efs"
        "containerPath" = var.efs_mount_point,
        "readOnly"      = null
      }

      efs_volume_configuration = [
        {
          file_system_id : module.efs.id
          root_directory : var.efs_root_directory
          transit_encryption : "ENABLED"
          transit_encryption_port : 2999
          authorization_config = {}
        }
      ]
    }
  ] : []
}
