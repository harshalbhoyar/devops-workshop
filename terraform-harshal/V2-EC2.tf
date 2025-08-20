  # Configure the AWS Provider
  terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
      }
    }
  }

  provider "aws" {
    # Specifies the desired AWS region for resource provisioning dcdddv .....................................................................................
    region = "us-east-1"
  }


  resource "aws_instance" "demo-server" {
    ami                    = "ami-04b4f1a9cf54c11d0"
    instance_type          = "t2.micro"
    key_name               = "dpp"
    vpc_security_group_ids = [aws_security_group.demo-sg.id]
    subnet_id              = aws_subnet.dpp-public-subnet-01.id
    #   security_groups = [aws_security_group.terraform-security-group.name]
    for_each = toset(["jenkins-master", "build-slave", "ansible"])
    tags = {
      Name = "${each.key}"
    }
  }


  resource "aws_security_group" "demo-sg" {
    name        = "demo-sg"
    description = "SSH Access"
    vpc_id      = aws_vpc.dpp-vpc.id

    #Incoming traffic
    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] #replace it with your ip address
    }

    #Outgoing traffic
    egress {
      from_port   = 0
      protocol    = "-1"
      to_port     = 0
      cidr_blocks = ["0.0.0.0/0"]
    }

    #Incoming traffic
    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] #replace it with your ip address
    }

    ingress {
    description      = "Jenkins port"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

    #Outgoing traffic
    egress {
      from_port   = 0
      protocol    = "-1"
      to_port     = 0
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "ssh-prot"
    }

  }

  resource "aws_vpc" "dpp-vpc" {
    cidr_block = "10.1.0.0/16"
    tags = {
      Name = "dpp-vpc"
    }

  }
  resource "aws_subnet" "dpp-public-subnet-01" {
    vpc_id                  = aws_vpc.dpp-vpc.id
    cidr_block              = "10.1.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1a"
    tags = {
      Name = "dpp-public-subent-01"
    }
  }
  resource "aws_subnet" "dpp-public-subnet-02" {
    vpc_id                  = aws_vpc.dpp-vpc.id
    cidr_block              = "10.1.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1b"
    tags = {
      Name = "dpp-public-subent-02"
    }
  }
  resource "aws_internet_gateway" "dpp-igw" {
    vpc_id = aws_vpc.dpp-vpc.id
    tags = {
      Name = "dpp-igw"
    }
  }
  resource "aws_route_table" "dpp-public-rt" {
    vpc_id = aws_vpc.dpp-vpc.id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.dpp-igw.id
    }
  }
  resource "aws_route_table_association" "dpp-rta-public-subnet-01" {
    subnet_id      = aws_subnet.dpp-public-subnet-01.id
    route_table_id = aws_route_table.dpp-public-rt.id
  }
  resource "aws_route_table_association" "dpp-rta-public-subnet-02" {
    subnet_id      = aws_subnet.dpp-public-subnet-02.id
    route_table_id = aws_route_table.dpp-public-rt.id
  }





