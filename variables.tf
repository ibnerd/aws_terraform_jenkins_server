variable "aws_region" {
  description = "AWS region to create resources"
  default     = "us-east-1"
}
#the variables below will be declared during terraform plan 
#DO NOT HARDCODE THESE! THIS CAN LEAVE SENSITIVE DATA EXPOSED
variable "vpc_id" {
  description = "AWS VPC ID where ec2 will be launched"
  
}

variable "cidr_block" {
  description = "allowed IP range for ingress traffic"
  
}

variable "key_name" {
  description = "key value pair, must already exist in AWS"
}