provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu_lts" {
    most_recent = true

    filter {
      name = "name"

      values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-*-*.04-amd64-server-*"]
    }

    filter {

        name = "virtualization-type"
        values = ["hvm"]
    }
owners = ["099720109477"]
}
module "vpc_dev" {
  source      = "./modules/vpc"
  cidr_vpc    = var.dev_cidr_vpc
  vpc_name    = "Dev-VPC"
  cidr_subnet = var.dev_cidr_subnet
  azone       = var.dev_azone
  subnet_name = "Dev-Subnet"
  sg_name     = "Dev-Security-Group"
}

module "instance_dev" {
  source            = "./modules/instance"
  ami               = data.aws_ami.ubuntu_lts.id
  instance_type     = var.dev_instance_type
  subnet_id         = module.vpc_dev.subnet_id
  key_name          = var.dev_key_name
  instance_count    = var.instance_count_dev
  instance_name     = "Dev-Instance"
  security_group_id = module.vpc_dev.security_group_id
}

module "vpc_prod" {
  source      = "./modules/vpc"
  cidr_vpc    = var.prod_cidr_vpc
  vpc_name    = "Prod-VPC"
  cidr_subnet = var.prod_cidr_subnet
  azone       = var.prod_azone
  subnet_name = "Prod-Subnet"
  sg_name     = "Prod-Security-Group"
}

module "instance_prod" {
  source            = "./modules/instance"
  ami            = data.aws_ami.ubuntu_lts.id
  instance_type     = var.prod_instance_type
  instance_count    = var.instance_count_prod
  subnet_id         = module.vpc_prod.subnet_id
  key_name          = var.prod_key_name
  instance_name     = "Prod-Instance"
  security_group_id = module.vpc_prod.security_group_id
}

