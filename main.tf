provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      BuiltWith   = "Terraform"
      Project     = var.project_name
    }
  }
}

locals {
  name_suffix = "${var.project_name}-${var.environment}-${var.aws_region}"
}

module "vpc" {
  source = "./modules/vpc/"
  name = "vpc-${local.name_suffix}"
  
  environment     = var.environment
  region          = var.aws_region
  
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs

  # DNS configuration
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  
  name_suffix = local.name_suffix
}

module "ec2_bastion" {
  source = "./modules/ec2/"
  
  environment     = var.environment
  region          = var.aws_region
  
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  whitelisted_ips = var.whitelisted_ips
  cloudhsm_security_group_id = module.hsm.cloudhsm_security_group_id
  
  name_suffix = local.name_suffix
}

module "kms" {
  source = "./modules/kms/"
  name = "kms-${local.name_suffix}"
  kms_key_alias = var.kms_key_alias
  
  environment     = var.environment
  region          = var.aws_region

  name_suffix = local.name_suffix
}

module "s3" {
  source = "./modules/s3/"
  bucket_name = "bucket-cgicom-${local.name_suffix}"
  
  kms_s3_key_id = module.kms.kms_s3_key_id
  kms_s3_key_arn = module.kms.kms_s3_key_arn
  
  environment     = var.environment
  region          = var.aws_region

  name_suffix = local.name_suffix
}

module "hsm" {
  source = "./modules/hsm/"
  hsm_subnet_ids = module.vpc.private_subnet_ids
  hsm_mode = var.hsm_mode

  environment     = var.environment
  region          = var.aws_region

  name_suffix = local.name_suffix
}
