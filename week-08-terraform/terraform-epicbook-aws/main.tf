resource "aws_vpc" "epicbook" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "epicbook-vpc"
    Project = "EpicBook"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.epicbook.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "epicbook-public-subnet"
    Project = "EpicBook"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.epicbook.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name    = "epicbook-private-subnet"
    Project = "EpicBook"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id                  = aws_vpc.epicbook.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name    = "epicbook-private-subnet-2"
    Project = "EpicBook"
  }
}

resource "aws_internet_gateway" "epicbook" {
  vpc_id = aws_vpc.epicbook.id

  tags = {
    Name    = "epicbook-igw"
    Project = "EpicBook"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.epicbook.id

  tags = {
    Name    = "epicbook-public-rt"
    Project = "EpicBook"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.epicbook.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ec2" {
  name        = "epicbook-ec2-sg"
  description = "Security group for EpicBook EC2 instance"
  vpc_id      = aws_vpc.epicbook.id

  tags = {
    Name    = "epicbook-ec2-sg"
    Project = "EpicBook"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_http" {
  security_group_id = aws_security_group.ec2.id

  description = "Allow HTTP access to EpicBook"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "ec2_ssh" {
  security_group_id = aws_security_group.ec2.id

  description = "Allow SSH from my IP only"
  cidr_ipv4   = "102.89.34.123/32"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ec2_outbound" {
  security_group_id = aws_security_group.ec2.id

  description = "Allow outbound traffic from EpicBook EC2"
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_security_group" "rds" {
  name        = "epicbook-rds-sg"
  description = "Security group for EpicBook MySQL RDS"
  vpc_id      = aws_vpc.epicbook.id

  tags = {
    Name    = "epicbook-rds-sg"
    Project = "EpicBook"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_mysql" {
  security_group_id = aws_security_group.rds.id

  description                  = "Allow MySQL from EpicBook EC2 only"
  referenced_security_group_id = aws_security_group.ec2.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_db_subnet_group" "epicbook" {
  name = "epicbook-db-subnet-group-terraform"

  subnet_ids = [
    aws_subnet.private.id,
    aws_subnet.private_2.id
  ]

  tags = {
    Name    = "epicbook-db-subnet-group"
    Project = "EpicBook"
  }
}

resource "aws_db_instance" "epicbook" {
  identifier = "epicbook-mysql"

  engine         = "mysql"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = "epicbook"
  username = "admin"
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.epicbook.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false
  multi_az            = false
  storage_encrypted   = true

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name    = "epicbook-mysql"
    Project = "EpicBook"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "epicbook" {
  key_name   = "epicbook-ssh"
  public_key = file(pathexpand("~/.ssh/epicbook-aws.pub"))

  tags = {
    Name    = "epicbook-ssh"
    Project = "EpicBook"
  }
}

resource "aws_instance" "epicbook" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = true

  key_name = aws_key_pair.epicbook.key_name

  root_block_device {
    volume_size = 12
    volume_type = "gp3"
    encrypted   = true
  }

  volume_tags = {
    Name    = "epicbook-root-volume"
    Project = "EpicBook"
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name    = "epicbook-ec2"
    Project = "EpicBook"
  }
}
