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

#create admin IAM role for the instance 
resource "aws_iam_role" "admin_jenkins_role" {
  name = "admin_jenkins_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#create EC2 instance profile
resource "aws_iam_instance_profile" "admin_jenkins_profile" {
  name = "admin_jenkins_profile"
  role = "${aws_iam_role.admin_jenkins_role.name}"
}

#Create IAM Policies for the IAM role
resource "aws_iam_role_policy" "admin_policy" {
  name = "admin_policy"
  role = "${aws_iam_role.admin_jenkins_role.id}"
#the below policy gives full admin rights to jenkins server be careful with this
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

#start t2micro ec2 instance 
resource "aws_instance" "web" {
  ami             = data.aws_ami.amazon_linux.id
  instance_type   = "t2.micro" #free tier
  key_name        = var.key_name #key pair must already exist in AWS
  security_groups = [aws_security_group.jenkins_sg.name]
  iam_instance_profile = "${aws_iam_instance_profile.admin_jenkins_profile.name}"
  user_data       = "${file("install_jenkins.sh")}"
  tags = {
    Name = "Jenkins"
  }
}