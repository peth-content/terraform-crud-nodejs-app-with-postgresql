module "vpc" {
  source = "git::https://github.com/moreno-terraform/aws_vpc.git"
  vpc_name = var.vpc_name
  vpc_cidr_block = var.vpc_cidr_block
  app_subnets_cidr_block = var.app_subnets_cidr_block
  pub_subnets_cidr_block = var.pub_subnets_cidr_block
  tags = var.tags
}