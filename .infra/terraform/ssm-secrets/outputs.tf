output "secrets" {
  value = [
    for parameter in aws_ssm_parameter.this :
    {
      name      = parameter.tags.EnvVarName
      valueFrom = parameter.arn
    }
  ]
}

output "ssm_parameter_path" {
  value = local.ssm_parameter_path
}
