variable "env" {
}

variable "namespace" {}

variable "name" {}

variable "service_type" {
  default = "web"
}
variable "service_group" {
  default = "web"
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
  default = true
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

variable "alb_security_groups" {}

variable "docker_registry" {}

variable "docker_image_tag" {}

variable "docker_container_port" {
  default = 3000
}

variable "ecs_launch_type" {
  default = "FARGATE"
}

variable "health_check_type" {
  default = "EC2"
}

variable "alb_health_check_path" {
  default = "/health"
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

variable "datadog_enabled" {
  default = true
}

variable "cloud9_enabled" {
  default = false
}

variable "cpu" {
  default = 256
  description = "Fargate CPU value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
}

variable "memory" {
  default = 512
  description = "Fargate Memory value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
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

variable "tls_cert_arn" {
}
