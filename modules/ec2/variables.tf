# Core Vaariables
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "name_suffix" {
  description = "project_name + environment + aws_region"
  type        = string
}

# VPC
variable "vpc_id" {
  type        = string
}

variable "public_subnet_ids" {
  type        = list(string)
}

# EC2
variable "whitelisted_ips" {
    type = list(string)
}

# HSM
variable "cloudhsm_security_group_id" {
  type        = string
}