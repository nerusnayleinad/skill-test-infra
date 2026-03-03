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
variable "name" {
  description = "Name of the VPC"
  type        = string
}

# KMS 
variable "kms_key_alias" {
  description = "Alias of External KMS Key"
  type        = string
}

