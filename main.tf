terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Main VPC"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1a"
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main IGW"
  }
}

resource "aws_route_table" "rtable" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Main Route Table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.rtable.id
}

resource "aws_security_group" "allow_ping" {
  name        = "allow_ping_within_subnet"
  description = "Allow ICMP ping requests within the same subnet"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = -1              # ICMP type code for Echo Reply. Use -1 for all types.
    to_port     = -1              # ICMP code for Echo Reply. Use -1 for all codes.
    protocol    = "icmp"
    cidr_blocks = [aws_subnet.main.cidr_block]
  }

 ingress {
    from_port   = 22              # SSH port
    to_port     = 22              # SSH port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # Adjust this to a more restrictive range for better security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"            # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ping_within_subnet"
  }
}
resource "random_password" "password" {
  count  = var.instance_count
  length = 16
  special = true
}

resource "aws_instance" "vm" {
  count                       = var.instance_count
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.allow_ping.id]
  key_name                    = "KEY_PAIR"

  tags = {
    Name = "VM-${count.index}"
  }
}

