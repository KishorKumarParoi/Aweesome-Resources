variable "region" {
  description = "AWS Region"
}

variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}


variable "cidr_subnet" {
  description = "CIDR block for the subnet"
  default     = "10.0.1.0/24"
}

variable "azone" {
  description = "Availability zone for the subnet"
  default     = "ap-south-1a"
}

variable "key" {
  description = "Key pair for SSH access"
}

variable "itype" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  default     = 1
}


