locals {
  name = "${var.env}-bastion"
}

# TODO: This needs to become an autoscale of one instance
resource "aws_instance" "this" {
  ami                         = "ami-04b9e92b5572fa0d1"
  key_name                    = var.ec2_key_pair_name
  instance_type               = var.instance_type

  vpc_security_group_ids = concat(var.ext_security_groups, [
    aws_security_group.this.id
  ])
  subnet_id = var.public_subnets[0]
  associate_public_ip_address = true

  tags = {
    Terraform   = "true"
    Env = var.env
    Name = local.name
  }
}

resource "aws_route53_record" "this" {
  zone_id = var.zone_id
  name =  "${var.name}.${var.env}.${var.root_domain_name}"
  type = "A"
  ttl = "900"
  records = [aws_instance.this.public_ip]
}


# TODO: install Fail2ban
resource "aws_security_group" "this" {
  name   = "${var.env}-bastion"
  vpc_id = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform   = "true"
    Env = var.env
    Name = "${var.env}-bastion"
  }
}
