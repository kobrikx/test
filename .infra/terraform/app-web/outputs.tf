output "this_target_group_arn" {
  value = length(module.alb.target_group_arns) >= 1 ? module.alb.target_group_arns[0] : ""
}

output "this_task_definition_arn" {
  value = module.service.this_task_definition_arn
}

output "cloudwatch_log_group" {
  value = module.service.cloudwatch_log_group
}

output "alb_dns_name" {
  value = module.alb.this_lb_dns_name
}

output "alb_dns_zone" {
  value = module.alb.this_lb_zone_id
}
