provider "aws" {
  region = "us-east-1"
}


resource "aws_instance" "my_instance" {
  ami           = "ami-"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id

  # Attach
  vpc_security_group_ids = [aws_security_group.my_security_group.id, aws_security_group.my_security_group_port_and_vpc_cidr_only.id]

  tags = {
    Name = "my-ec2-instance"
  }
}

// aws_vpc
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-vpc"
  }
}


// aws_subnet
resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "my-subnet"
  }
}

// aws_internet_gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-igw"
  }
}


resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "my-route-table"
  }
}

resource "aws_route_table_association" "my_route_table_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  name        = "my-security-group"
  description = "Security group for allowing SSH and HTTP access"

  ingress {
    description = "Allow SSH from 0.0.0.0/0"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    description = "Allow SSH to 0.0.0.0/0"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = {
    Name = "my-security-group"
  }
}

resource "aws_security_group" "my_security_group_port_and_vpc_cidr_only" {
  vpc_id      = aws_vpc.my_vpc.id
  name        = "my_security_group_port_and_vpc_cidr_only"
  description = "Security group allowing SSH and port 3000 within VPC CIDR range"

  ingress {
    description = "Allow SSH from VPC CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.my_vpc.cidr_block]
  }

  ingress {
    description = "Allow port 3000 from VPC CIDR"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.my_vpc.cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-security-group"
  }
}


resource "aws_instance" "ec2-bastion-host" {
  ami           = "ami-" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id

  vpc_security_group_ids = [aws_security_group.my_security_group.id, aws_security_group.my_security_group_port_and_vpc_cidr_only.id]

  key_name = ""

  tags = {
    Name = "ec2-bastion-host"
  }
}