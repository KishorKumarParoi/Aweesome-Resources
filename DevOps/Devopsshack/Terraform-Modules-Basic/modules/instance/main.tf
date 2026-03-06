
resource "aws_instance" "instance" {
  count                     = var.instance_count
  ami                       = var.ami
  key_name                  = var.key_name
  instance_type             = var.instance_type
  subnet_id                 = var.subnet_id
  vpc_security_group_ids    = [var.security_group_id]

  tags = {
    Name = "${var.instance_name}-${count.index + 1}"
  }

  root_block_device {
    volume_size = 15
    volume_type = "gp2"
  }
}

