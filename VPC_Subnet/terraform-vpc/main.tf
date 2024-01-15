locals {
  az_a           = "${var.region}a" # eu-central-1a
  az_b           = "${var.region}b" # eu-central-1b
  az_c           = "${var.region}c" # eu-central-1c
  cidr_a         = "10.0.1.0/24"
  cidr_b         = "10.0.2.0/24"
  cidr_c         = "10.0.3.0/24"
  private_cidr_a = "10.0.4.0/24"
  private_cidr_b = "10.0.5.0/24"
  private_cidr_c = "10.0.6.0/24"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main VPC"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.cidr_a
  availability_zone       = local.az_a
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet A"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.cidr_b
  availability_zone       = local.az_b
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet B"
  }
}


resource "aws_subnet" "subnet_c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.cidr_c
  availability_zone       = local.az_c
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet C"
  }
}
# erstellen der Privaten subnet von a - c 
resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.private_cidr_a
  availability_zone       = local.az_a
  map_public_ip_on_launch = false
  tags = {
    Name = "Private Subnet A"
  }
}
resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.private_cidr_b
  availability_zone       = local.az_b
  map_public_ip_on_launch = false
  tags = {
    Name = "Private Subnet B"
  }
}
resource "aws_subnet" "private_subnet_c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.private_cidr_c
  availability_zone       = local.az_c
  map_public_ip_on_launch = false
  tags = {
    Name = "Private Subnet C"
  }
}
# Internetgatway für mein public subnet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "TF Internet Gateway"
  }
}
# elastic ip für Nat gateway a - c 
resource "aws_eip" "eip_a" {
  domain                    = "vpc"
  associate_with_private_ip = local.private_cidr_a
  tags = {
    Name = "EIP A"
  }
}

resource "aws_eip" "eip_b" {
  domain                    = "vpc"
  associate_with_private_ip = local.private_cidr_b
  tags = {
    Name = "EIP B"
  }
}

resource "aws_eip" "eip_c" {
  domain                    = "vpc"
  associate_with_private_ip = local.private_cidr_c
  tags = {
    Name = "EIP C"
  }
}

# Nat gatway for private subnet 
resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.eip_a.id
  subnet_id     = aws_subnet.private_subnet_a.id
  tags = {
    Name = "NAT Gateway A"
  }
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.eip_b.id
  subnet_id     = aws_subnet.private_subnet_b.id
  tags = {
    Name = "NAT Gateway B"
  }
}

resource "aws_nat_gateway" "nat_c" {
  allocation_id = aws_eip.eip_c.id
  subnet_id     = aws_subnet.private_subnet_c.id
  tags = {
    Name = "NAT Gateway C"
  }
}


resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "TF Route Table"
  }
}
# routingtable für private subnet a - c 
resource "aws_route_table" "private_rt_a" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_a.id
  }
  tags = {
    Name = "Private Route Table A"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_rt_a.id
}

resource "aws_route_table" "private_rt_b" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_b.id
  }
  tags = {
    Name = "Private Route Table B"
  }
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_rt_b.id
}

resource "aws_route_table" "private_rt_c" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_c.id
  }
  tags = {
    Name = "Private Route Table C"
  }
}

resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_subnet_c.id
  route_table_id = aws_route_table.private_rt_c.id
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.subnet_c.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "sg" {
  name        = "tf_sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "test_a" {
  ami                    = "ami-065ab11fbd3d0323d"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet_a.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
    Name = "test_a"
  }
}

resource "aws_instance" "test_b" {
  ami                    = "ami-065ab11fbd3d0323d"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet_b.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
    Name = "test_b"
  }
}

resource "aws_instance" "test_c" {
  ami                    = "ami-065ab11fbd3d0323d"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet_c.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
    Name = "test_c"
  }
}