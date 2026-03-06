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

resource "aws_vpc" "my-vpc" {

    cidr_block = var.cidr_vpc

tags = {

    Name = var.vpc_name
}
}

resource "aws_subnet" "my-subnet" {

    vpc_id = aws_vpc.my-vpc.id 
    cidr_block = var.cidr_subnet
    map_public_ip_on_launch = true
    availability_zone = var.azone 

    tags = {

        Name = var.subnet_name
    }
}


resource "aws_security_group" "my-sg" {

    vpc_id = aws_vpc.my-vpc.id 
    name="SG-1"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }

    egress  {

        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
tags = {
  Name = var.sg_name
}


}


resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my-vpc.id 

  tags =  {

    Name = "My-IGW"
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my-vpc.id 

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id 
  }

  tags = {

    Name = "MyRouteTable"
  }
}

resource "aws_route_table_association" "my_route_table_association" {
  subnet_id = aws_subnet.my-subnet.id 
  route_table_id = aws_route_table.my_route_table.id 
}


resource "aws_instance" "my_instance" {
    count = var.instance_count
    ami = data.aws_ami.ubuntu_lts.id
    key_name = var.key 
    subnet_id = aws_subnet.my-subnet.id 
    vpc_security_group_ids = [aws_security_group.my-sg.id]
    instance_type = var.itype
    
    provisioner "file" {
	source = "aditya.txt"
	destination = "/home/ubuntu/aditya.txt"
		
	connection {

	type = "ssh"
	user = "ubuntu"
	private_key = file("/home/ubuntu/Day-2/DevOps-Shack.pem")
	host = self.public_ip
	}

	
	}

	provisioner "local-exec" {

	command = "echo Instance created with Public IP : ${self.public_ip}"
}

	provisioner "remote-exec" {

	inline = [

	"sudo apt update",
	"sudo apt install -y maven"
	]

	connection {

	type = "ssh"
	user = "ubuntu"
	private_key = file("/home/ubuntu/Day-2/DevOps-Shack.pem")
	host = self.public_ip
}
	}

    tags = {

        Name = "${var.iname}-${count.index + 1}"

    }
root_block_device {
  volume_size = 15
  volume_type = "gp2"
}

}
