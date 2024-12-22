output "instance_ami" {
  value = aws_instance.web_SERVER.ami
}

output "instance_arn" {
  value = aws_instance.web_SERVER.arn
}
