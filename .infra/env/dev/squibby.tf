module "squibby" {
  source                = "../../terraform/app-web"
  name                  = "squibby"
  instance_type         = "t3.micro"
  min_size              = 1
  max_size              = 1
  desired_capacity      = 1
  datadog_enabled       = false
  cloud9_enabled        = false
  ecs_launch_type       = "FARGATE"
  alb_health_check_path = "/"
  create_ecr_repo       = true
  
  domain_names = [
    "api.${var.root_domain_name}"
  ]

  environment = {
    ENV      = var.env
    APP_NAME = "Craben"

  }

  secret_names = [
  ]

  env             = var.env
  namespace       = var.namespace
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets
  security_groups = local.security_groups

  iam_instance_profile = local.iam_instance_profile
  key_name             = local.key_name
  image_id             = local.image_id
  root_domain_name     = local.root_domain_name
  zone_id              = local.zone_id
  vpc_id               = local.vpc_id
  alb_security_groups  = local.alb_security_groups
  docker_registry      = local.docker_registry
  docker_image_tag     = local.docker_image_tag
  tls_cert_arn         = local.tls_cert_arn
}
