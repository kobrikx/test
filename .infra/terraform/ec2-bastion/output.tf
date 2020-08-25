output "cmd" {
  value = "ssh -fN ubuntu@${aws_route53_record.this.name}"
}
output "security_group" {
  value = aws_security_group.this.id
}
