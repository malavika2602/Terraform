terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.4.0"
    }
  }

  required_version = ">= 0.12"
}

provider "aws" {
  region = "ap-south-1"
  
}


// VPC
resource "aws_vpc" "Test-vpc" {
  cidr_block = "10.10.0.0/16"
}

// Subnet
resource "aws_subnet" "Test_Subnet" {
  vpc_id     = aws_vpc.Test-vpc.id
  cidr_block = "10.10.1.0/24"

  tags = {
    Name = "Main"
  }
}

// Security Group
resource "aws_security_group" "Test_secgrp" {
  name = "Test_secgrp"

  vpc_id = aws_vpc.Test-vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
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

// EC2 Instance
resource "aws_instance" "Test-server" {
  ami                    = "ami-0a0f1259dd1c90938"
  key_name               = "Test"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.Test_Subnet.id
  vpc_security_group_ids = [aws_security_group.Test_secgrp.id]
}
