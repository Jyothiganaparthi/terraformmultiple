resource "aws_vpc" "main" {
  cidr_block       = var.vpc-cidr
  instance_tenancy = "default"

  tags = {
    Name = var.vpc-name
  }
}
resource "aws_subnet" "publicsubnets" {
  count = length(var.public_cidrs)
  vpc_id     = aws_vpc.main.id
  availability_zone = "${element(var.azs,count.index)}"
  cidr_block = "${element(var.public_cidrs,count.index)}"

  tags = {
    Name = "public-subnet-${count.index}"
  }
}
resource "aws_subnet" "privatesubnets" {
  count = length(var.private_cidrs)
  vpc_id     = aws_vpc.main.id
  availability_zone = "${element(var.azs,count.index)}"
  cidr_block = "${element(var.private_cidrs,count.index)}"

  tags = {
    Name = "private-subnet-${count.index}"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.igw
  }
}
resource "aws_route_table" "publicroute" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = var.route1
  }
}
resource "aws_route_table" "privateroute" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }
  tags = {
    Name = var.route2
  }
}
resource "aws_route_table_association" "rta1" {
  count = "${length (var.public_cidrs)}"
  subnet_id   = "${element(aws_subnet.publicsubnets.*.id,count.index)}"
  route_table_id = aws_route_table.publicroute.id
}
resource "aws_route_table_association" "rta2" {
  count = "${length (var.private_cidrs)}"
  subnet_id   = "${element(aws_subnet.privatesubnets.*.id,count.index)}"
  route_table_id = aws_route_table.privateroute.id
}
resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.sec
  }
}
resource "aws_instance" "publicinstance" {
  count =2
  ami           = "ami-0a695f0d95cefc163"
  instance_type = "t2.micro"
  key_name = "key123"
  subnet_id = "${element(aws_subnet.publicsubnets.*.id,count.index)}"
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  associate_public_ip_address = true

  tags = {
    Name = "publicserver-${count.index}"
  }

}
resource "aws_instance" "privateinstance" {
  count =2
  ami           = "ami-0a695f0d95cefc163"
  instance_type = "t2.micro"
  key_name = "key123"
  subnet_id = "${element(aws_subnet.privatesubnets.*.id,count.index)}"
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  associate_public_ip_address = true
  user_data = <<-EOF
          #! /bin/bash
          sudo apt-get update
          sudo apt-get install unzip -y
          sudo apt-get install nginx -y
          EOF
  tags = {
    Name = "privateserver-${count.index}"
  }

}