output "sg_arn" {
  # should not be billed
  value = aws_security_group.allow_tcp.arn
}