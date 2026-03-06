# Outputs for the Dev environment
output "dev_vpc_id" {
  description = "The ID of the Dev VPC"
  value       = module.vpc_dev.vpc_id
}

output "dev_subnet_id" {
  description = "The ID of the Dev subnet"
  value       = module.vpc_dev.subnet_id
}

output "dev_instance_public_ip" {
  description = "The public IP of the Dev EC2 instance"
  value       = module.instance_dev.public_ip
}

# Outputs for the Prod environment
output "prod_vpc_id" {
  description = "The ID of the Prod VPC"
  value       = module.vpc_prod.vpc_id
}

output "prod_subnet_id" {
  description = "The ID of the Prod subnet"
  value       = module.vpc_prod.subnet_id
}

output "prod_instance_public_ip" {
  description = "The public IP of the Prod EC2 instance"
  value       = module.instance_prod.public_ip
}

