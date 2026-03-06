output "publicip" {

    value = [ for instance in aws_instance.my_instance : instance.public_ip ]
}

output "debug" {
value = data.aws_ami.ubuntu_lts
}
