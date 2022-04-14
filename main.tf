terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Allow Jenkins Traffic"
  vpc_id      = var.vpc_id
#inbound http only from the specified IPs var.cidr_block
  ingress {
    description      = "Allow from Personal CIDR block"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = [var.cidr_block]
  }
#inbound ssh only from the specified IPs var.cidr_block
  ingress {
    description      = "Allow SSH from Personal CIDR block"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.cidr_block]
  }
#allows outbound traffic to anywhere
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Jenkins SG"
  }
}
#find the most recent aws linux ami
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"] # Canonical
}
#start t2micro ec2 instance 
resource "aws_instance" "web" {
  ami             = data.aws_ami.amazon_linux.id
  instance_type   = "t2.micro" #free tier
  key_name        = var.key_name #key pair must already exist in AWS
  security_groups = [aws_security_group.jenkins_sg.name]
  user_data       = "${file("install_jenkins.sh")}"
  tags = {
    Name = "Jenkins"
  }
}