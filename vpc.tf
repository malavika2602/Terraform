provider "aws"{
    region="ap-south-1"
    alias = "env"
}
resource "aws_vpc" "demo-vpc" {
    cidr_block="10.10.0.0/16"
    tags={
        Name:"demo_vpc"
    }
}
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = "10.10.0.0/24"

  tags = {
    Name = "Main"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = {
    Name = "main"
  }
}

resource "aws_security_group" "demo-secgrp" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.demo-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.demo-vpc.cidr_block]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.demo-vpc.id

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "example"
  }
}

resource "aws_instance" "Test-server" {
  ami                    = "ami-0a0f1259dd1c90938"
  key_name               = "Test"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.demo-secgrp.id]
}
