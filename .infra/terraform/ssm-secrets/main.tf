locals {
  ssm_parameter_path = "${var.env}/${var.app_name}"
}

resource "aws_ssm_parameter" "this" {
  for_each = var.names



  name  = "/${local.ssm_parameter_path}/${each.value}"
  type  = "SecureString"
  value = var.default_value

  lifecycle {
    ignore_changes = [
      value,
    ]
  }

  tags = {
    Application = var.app_name
    EnvVarName  = each.value
  }
}
