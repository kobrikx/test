output "this_task_definition_arn" {
  value = module.task.task_definition_arn
}

output "name" {
  value = var.name
}

output "ecs_cluster" {
  value = var.ecs_cluster
}

output "secrets" {
  value = module.task.secrets
}

output "secret_names" {
  value = module.task.secret_names
}
output "environment" {
  value = local.environment
}

output "cloudwatch_log_group" {
  value = module.task.cloudwatch_log_group
}
