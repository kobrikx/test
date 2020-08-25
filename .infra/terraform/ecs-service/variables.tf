variable "env" {
}

variable "name" {}

variable "memoryReservation" {
  default = 1024
}
variable "environment" {
//  type = list(object({name=string, value=string}))
  type = map(string)
}

//variable "secret_names" {
//  type = list(string)
//}

variable "ecs_cluster" {
  type = string
}

variable "docker_image_name" {
  type = string
}

variable "docker_image_tag" {
  type = string
}

variable "docker_container_port" {
  type = number
  default = 3000
}

variable "docker_container_command" {
  type = list(string)
  default = []
}

variable "docker_container_entrypoint" {
  type = list(string)
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
variable "target_group_arn" {
  default = null

}

variable "sidecar_container_definitions" {
  type = list(any)
  default = []
}

variable "iam_role_policy_statement" {
  default = []
}

variable "ecs_launch_type" {
  default = "FARGATE"
}

variable "cpu" {
  default = 256
  description = "Fargate CPU value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
}

variable "memory" {
  default = 512
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
