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

# HSM
variable "hsm_mode" {
    type = string
}

# VPC
variable "hsm_subnet_ids" {
  description = "list of all private subnets"
  type        = list(string)
}

