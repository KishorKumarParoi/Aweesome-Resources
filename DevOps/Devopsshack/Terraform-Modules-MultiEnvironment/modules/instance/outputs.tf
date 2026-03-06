output "public_ip" {
  value = [for instance in aws_instance.instance : instance.public_ip]
}

