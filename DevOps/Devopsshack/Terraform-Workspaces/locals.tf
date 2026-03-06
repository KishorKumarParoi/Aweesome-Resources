# locals.tf
locals {
  vpc_name     = "${terraform.workspace}-vpc"
  sg_name      = "${terraform.workspace}-sg"
  iname        = "${terraform.workspace}-instance"
  subnet_name  = "${terraform.workspace}-subnet"
}
