# General Variables
variable "region" {
  description = "AWS region where resources will be created"
}

# Dev Environment Variables
variable "dev_cidr_vpc" {
  description = "CIDR block for the Dev VPC"
}

variable "dev_cidr_subnet" {
  description = "CIDR block for the Dev subnet"
}

variable "dev_azone" {
  description = "Availability zone for the Dev subnet"
}


variable "dev_instance_type" {
  description = "Instance type for the Dev EC2 instance"
}

variable "dev_key_name" {
  description = "Key name for SSH access to Dev EC2 instance"
}

# Prod Environment Variables
variable "prod_cidr_vpc" {
  description = "CIDR block for the Prod VPC"
}

variable "prod_cidr_subnet" {
  description = "CIDR block for the Prod subnet"
}

variable "prod_azone" {
  description = "Availability zone for the Prod subnet"
}



variable "prod_instance_type" {
  description = "Instance type for the Prod EC2 instance"
}

variable "prod_key_name" {
  description = "Key name for SSH access to Prod EC2 instance"
}

variable "instance_count_dev" {}
variable "instance_count_prod" {}
