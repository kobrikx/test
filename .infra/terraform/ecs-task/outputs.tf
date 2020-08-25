output "task_definition_arn" {
  value = aws_ecs_task_definition.this.arn
}

output "name" {
  value = var.name
}

output "secrets" {
  value = module.ssm.secrets
}

output "secret_names" {
  value = var.secret_names
}

output "environment" {
  value = local.environment
}

output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.this.name
}
