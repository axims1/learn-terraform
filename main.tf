
# Data Source: Fetch the latest Bitnami Tomcat AMI
data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami owner ID
}

# Data Source: Fetch the Default VPC
data "aws_vpc" "default" {
  default = true
}

# Security Group
resource "aws_security_group" "blog" {
  name        = "BLOG SERVER SG"
  description = "Allow HTTP and HTTPS. Allow all outbound traffic."
  vpc_id      = data.aws_vpc.default.id
}

# Security Group Rules for HTTP
resource "aws_security_group_rule" "blog_http_in" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.blog.id
}

# Security Group Rules for HTTPS
resource "aws_security_group_rule" "blog_https_in" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.blog.id
}

# Outbound Rules: Allow All
resource "aws_security_group_rule" "blog_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.blog.id
}

# EC2 Instance
resource "aws_instance" "web" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.blog.id]

  tags = {
    Name = "terraform bootcamp"
  }

  # Lifecycle block to ensure destroy is allowed
  lifecycle {
    prevent_destroy = false
  }
}
