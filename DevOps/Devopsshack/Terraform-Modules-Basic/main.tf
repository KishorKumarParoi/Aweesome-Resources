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

module "vpc" {
  source       = "./modules/vpc"
  cidr_vpc     = var.cidr_vpc
  vpc_name     = var.vpc_name
  cidr_subnet  = var.cidr_subnet
  azone        = var.azone
  subnet_name  = var.subnet_name
  sg_name      = var.sg_name
}

module "instance" {
  source            = "./modules/instance"
  instance_count    = var.instance_count
  ami               = data.aws_ami.ubuntu_lts.id
  key_name          = var.key
  instance_type     = var.itype
  subnet_id         = module.vpc.subnet_id
  security_group_id = module.vpc.security_group_id
  instance_name     = var.iname
}

