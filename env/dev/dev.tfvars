project_name = "task1"
environment  = "dev"
aws_region   = "us-east-2"

vpc_cidr = "10.10.0.0/16"
availability_zones = ["us-east-2a", "us-east-2b"]

private_subnet_cidrs = [
  "10.10.101.0/24",
  "10.10.102.0/24"
]

public_subnet_cidrs = [
  "10.10.201.0/24",
  "10.10.202.0/24"
]

# EC2
whitelisted_ips = ["0.0.0.0/0"]

# KMS
kms_key_alias = "task1"

# HSM
hsm_mode = "NON_FIPS"

# Tags
tags = {
  project = "task1"
  environment = "dev"
  region = "us-east-2"
  built-with = "Terraform"
}

private_subnet_tags = {
  Access = "private"
}

public_subnet_tags = {
  Access = "public"
}

# Enable SSM endpoints for dev
#enable_ssm_endpoint = true
#enable_ssmmessages_endpoint = true
#enable_ec2_endpoint = true
#enable_ec2messages_endpoint = true

# Enable flow logs in dev
#enable_flow_log = true