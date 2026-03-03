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

#module "iam" {
#  source = "./modules/iam/"
#}

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

#module "ec2" {
#  source = "./modules/ec2/"
#  
#  environment     = var.environment
#  region          = var.region
#  subnets         = var.subnets
#  zone            = var.zone
#  
#  vpc_id = module.vpc.vpc_id
#  ips_uk = var.ips_uk
#  
#  key_name        = var.key_name
#
#  subnet_id_public_a = module.vpc.subnet_id_public_a
#  subnet_id_public_b = module.vpc.subnet_id_public_b
#  subnet_id_public_c = module.vpc.subnet_id_public_c
#  
#}

#module "elasticache" {
#  source = "./modules/elasticache/"
#
#  environment = var.environment
#  #cidr_block_private_a = var.cidr_block_private_a
#  vpc_id = module.vpc.vpc_id
#  subnet_id_private_a = module.vpc.subnet_id_private_a
#  subnets = var.subnets
#  
#  redis_node_type = var.redis_node_type
#  redis_cache_nodes = var.redis_cache_nodes
#  redis_family = var.redis_family
#  redis_version = var.redis_version
#  
#  redis_port = var.redis_port
#}

#module "mysql" {
#  source = "./modules/mysql/"
#  
#  region          = var.region
#  subnets         = var.subnets
#  environment = var.environment
#
#  vpc_id = module.vpc.vpc_id
#  subnet_id_private_a = module.vpc.subnet_id_private_a
#  subnet_id_private_b = module.vpc.subnet_id_private_b
#  subnet_id_private_c = module.vpc.subnet_id_private_c
#    
#  mysql_allocated_storage     = var.mysql_allocated_storage
#  mysql_max_allocated_storage = var.mysql_max_allocated_storage
#  mysql_instance_class        = var.mysql_instance_class
#  mysql_storage_type          = var.mysql_storage_type
#  mysql_engine                = var.mysql_engine
#  mysql_engine_version        = var.mysql_engine_version
#  mysql_family                = var.mysql_family
#}

#module "documentdb" {
#  source = "./modules/documentdb/"
#
#  project_name    = var.project_name
#  environment     = var.environment
#  region          = var.region
#  vpc_id          = module.vpc.vpc_id
#  
#  subnet_id_private_a = module.vpc.subnet_id_private_a
#  subnet_id_private_b = module.vpc.subnet_id_private_b
#  subnet_id_private_c = module.vpc.subnet_id_private_c
#  
#  docdb_instance_class = var.docdb_instance_class
#  docdb_number_instances = var.docdb_number_instances
#  docdb_engine_version = var.docdb_engine_version
#  
#  master_username    = var.master_username
#}

#module "ecs" {
#  source = "./modules/ecs/"
#  
#  account_id = module.base.account_id
#  project_name    = var.project_name
#  environment     = var.environment
#  #region = var.region
#  #subnets         = var.subnets
#  
#  casinoreviews_app_service_name = module.ecs-app.casinoreviews_app_service_name
#}
#
#module "ecs-app" {
#  source = "./modules/ecs-app/"
#  
#  account_id = module.base.account_id
#  project_name    = var.project_name
#  environment     = var.environment
#  region = var.region
#  subnets = var.subnets
#  sg_id_public_to_private = module.vpc.sg_id_public_to_private
#  
#  ecs_cluster_id_casinoreviews = module.ecs.ecs_cluster_id_casinoreviews
#  
#  lb_casinoreviews_target_group_app_arn = module.lb.lb_casinoreviews_target_group_app_arn
#  
#  execute_command_arn = module.ecs.execute_command_arn
#  
#  vpc_id = module.vpc.vpc_id
#
#  subnet_id_private_a = module.vpc.subnet_id_private_a
#  subnet_id_private_b = module.vpc.subnet_id_private_b
#  subnet_id_private_c = module.vpc.subnet_id_private_c
#  
#  app_cpu = var.app_cpu
#  app_memory = var.app_memory
#  app_port = var.app_port
#  container_port = var.container_port
#  container_prot = var.container_prot
#  awslogs_stream_prefix_app = var.awslogs_stream_prefix_app
#  container_path_volume = var.container_path_volume
#  
#  fargate_image_app = var.fargate_image_app
#  fargate_image_app_tag = var.fargate_image_app_tag
#  
#  efs_id_casinoreviews = module.efs.efs_id_casinoreviews
#}
#
#module "ecs-aux" {
#  source = "./modules/ecs-aux/"
#  
#  account_id = module.base.account_id
#  project_name    = var.project_name
#  environment     = var.environment
#  region = var.region
#  subnets = var.subnets
#  
#  ecs_cluster_id_casinoreviews = module.ecs.ecs_cluster_id_casinoreviews
#  
#  lb_casinoreviews_target_group_app_arn = module.lb.lb_casinoreviews_target_group_app_arn
#  
#  execute_command_arn = module.ecs.execute_command_arn
#  
#  vpc_id = module.vpc.vpc_id
#  
#  subnet_id_private_a = module.vpc.subnet_id_private_a
#  subnet_id_private_b = module.vpc.subnet_id_private_b
#  subnet_id_private_c = module.vpc.subnet_id_private_c
#  
#  app_cpu = var.app_cpu
#  app_memory = var.app_memory
#  app_port = var.app_port
#  container_port = var.container_port
#  container_prot = var.container_prot
#  awslogs_stream_prefix_app = var.awslogs_stream_prefix_app
#  container_path_volume = var.container_path_volume
#  
#  fargate_image_app_aux = var.fargate_image_app_aux
#  fargate_image_app_aux_tag = var.fargate_image_app_aux_tag
#  
#  efs_id_casinoreviews = module.efs.efs_id_casinoreviews
#}

#module "ecs-api" {
#  source = "./modules/ecs-api/"
#  
#  project_name = var.project_name
#  account_id = module.base.account_id
#  
#  environment     = var.environment
#  region = var.region
#  subnets = var.subnets
#  
#  ecs_cluster_id_blexr = module.ecs.ecs_cluster_id_blexr
#  deny_iam_except_tagged_roles_arn = module.ecs.deny_iam_except_tagged_roles_arn
#  execute_command_arn = module.ecs.execute_command_arn
#  server_secret_policy_arn = module.ecs.server_secret_policy_arn
#  
#  fargate_image_next = var.fargate_image_next
#  
#  lb_vso_target_group_next_arn = module.lb.lb_vso_target_group_next_arn
#
#  subnet_id_private_a = module.vpc.subnet_id_private_a
#  subnet_id_private_b = module.vpc.subnet_id_private_b
#  subnet_id_private_c = module.vpc.subnet_id_private_c
#  
#  redis_port = var.redis_port
#  
#  api_cpu = var.api_cpu
#  api_memory = var.api_memory
#  api_port = var.api_port
#  container_port = var.container_port
#  container_prot = var.container_prot
#  awslogs_stream_prefix_api = var.awslogs_stream_prefix_api
#  container_path_volume = var.container_path_volume
#  
#  #region          = var.region
#  #subnets         = var.subnets
#  
#}

#module "lb" {
#  source = "./modules/lb/"
#  
#  project_name    = var.project_name
#  environment = var.environment
#  region = var.region
#  subnets = var.subnets
#
#  subnet_id_public_a = module.vpc.subnet_id_public_a
#  subnet_id_public_b = module.vpc.subnet_id_public_b
#  subnet_id_public_c = module.vpc.subnet_id_public_c
#  
#  vpn_blexr = var.vpn_blexr
#  ips_custom = var.ips_custom
#  ip_blocks_cloudflare = var.ip_blocks_cloudflare
#  
#  vpc_id = module.vpc.vpc_id
#}
#
#module "efs" {
#  source = "./modules/efs/"
#  
#  project_name    = var.project_name
#  environment = var.environment
#  region = var.region
#  subnets = var.subnets
#
#  subnet_id_private_a = module.vpc.subnet_id_private_a
#  subnet_id_private_b = module.vpc.subnet_id_private_b
#  subnet_id_private_c = module.vpc.subnet_id_private_c
#  
#  vpc_id          = module.vpc.vpc_id
#}
#
#module "lambda" {
#  source = "./modules/lambda/"
#  
#  sg_id_public_to_private = module.vpc.sg_id_public_to_private
#  
#  subnet_id_private_a = module.vpc.subnet_id_private_a
#  subnet_id_private_b = module.vpc.subnet_id_private_b
#  subnet_id_private_c = module.vpc.subnet_id_private_c
#}
#
#module "apigateway" {
#  source = "./modules/apigateway/"
#  
#  lambda_function_signature_invoke_arn = module.lambda.lambda_function_signature_invoke_arn
#  lambda_function_signature_function_name = module.lambda.lambda_function_signature_function_name
#
#  region          = var.region
#}
#