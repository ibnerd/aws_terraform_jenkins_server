variable "aws_region" {
  description = "AWS region to create resources"
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "AWS VPC ID where ec2 will be launched"
  
}

variable "cidr_block" {
  description = "my personal IP"
  
}

variable "key_name" {
  description = "value"
}