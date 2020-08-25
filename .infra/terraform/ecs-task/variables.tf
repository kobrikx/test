variable "env" {
}

variable "name" {}

variable "memory_reservation" {
  default = 256
}
variable "environment" {
//  type = list(object({name=string, value=string}))
  type = map(string)
}

variable "secret_names" {
  type = list(string)
  default = []
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

variable "port_mappings" {
  default = []
}

variable "docker_container_command" {
  type = list(string)
  default = []
}

variable "docker_container_entrypoint" {
  type = list(string)
  default = []
}

variable "sidecar_container_definitions" {
  type = list(any)
  default = []
}

variable "task_group" {
  type = string
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

variable "cpu" {
  default = 256
  description = "Fargate CPU value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
}

variable "memory" {
  default = 512
  description = "Fargate Memory value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
}
