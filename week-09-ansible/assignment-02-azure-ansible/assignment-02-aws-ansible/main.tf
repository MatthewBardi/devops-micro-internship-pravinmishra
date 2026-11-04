
# Latest Ubuntu 24.04 LTS AMI from Canonical
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Register the Week 09 SSH public key with AWS
resource "aws_key_pair" "week09" {
  key_name   = "week09-aws-ansible-key"
  public_key = file(pathexpand(var.public_key_path))

  tags = {
    Name = "week09-aws-ansible-key"
  }
}


# Training VPC
resource "aws_vpc" "week09" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "week09-ansible-vpc"
  }
}

# Public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.week09.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "week09-public-subnet"
  }
}

# Private subnet for db1
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.week09.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "week09-private-subnet"
  }
}

# Internet gateway
resource "aws_internet_gateway" "week09" {
  vpc_id = aws_vpc.week09.id

  tags = {
    Name = "week09-internet-gateway"
  }
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.week09.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.week09.id
  }

  tags = {
    Name = "week09-public-routes"
  }
}

# Associate public subnet with route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


# Security group for public Ubuntu servers
resource "aws_security_group" "public_servers" {
  name        = "week09-public-servers-sg"
  description = "SSH access for Week 09 public servers"
  vpc_id      = aws_vpc.week09.id

  tags = {
    Name = "week09-public-servers-sg"
  }
}

# Allow HTTP access to Week 09 web servers
resource "aws_vpc_security_group_ingress_rule" "public_http" {
  security_group_id = aws_security_group.public_servers.id

  description = "Allow HTTP access to Week 09 web servers"

  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"
}

# SSH access from approved public IP
resource "aws_vpc_security_group_ingress_rule" "public_ssh" {
  security_group_id = aws_security_group.public_servers.id

  description = "SSH from approved public IP"
  cidr_ipv4   = var.ssh_allowed_cidr
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

# Outbound access for public servers
resource "aws_vpc_security_group_egress_rule" "public_outbound" {
  security_group_id = aws_security_group.public_servers.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

# Security group for private database server
resource "aws_security_group" "database" {
  name        = "week09-database-sg"
  description = "Private database server access"
  vpc_id      = aws_vpc.week09.id

  tags = {
    Name = "week09-database-sg"
  }
}

# SSH from public servers to private database
resource "aws_vpc_security_group_ingress_rule" "database_ssh" {
  security_group_id = aws_security_group.database.id

  description                  = "SSH from public servers"
  referenced_security_group_id = aws_security_group.public_servers.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}

# MySQL from public-server security group
resource "aws_vpc_security_group_ingress_rule" "database_mysql" {
  security_group_id = aws_security_group.database.id

  description                  = "MySQL from application tier"
  referenced_security_group_id = aws_security_group.application.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

# Outbound traffic for database server
resource "aws_vpc_security_group_egress_rule" "database_outbound" {
  security_group_id = aws_security_group.database.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}


# Separate security group for app1
resource "aws_security_group" "application" {
  name        = "week09-application-sg"
  description = "Application server access"
  vpc_id      = aws_vpc.week09.id

  tags = {
    Name = "week09-application-sg"
  }
}

# SSH to app1 from approved public IP
resource "aws_vpc_security_group_ingress_rule" "application_ssh" {
  security_group_id = aws_security_group.application.id

  description = "SSH from approved public IP"
  cidr_ipv4   = var.ssh_allowed_cidr
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

# Outbound connections from app1
resource "aws_vpc_security_group_egress_rule" "application_outbound" {
  security_group_id = aws_security_group.application.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}


# Three public Ubuntu servers: web1, web2, app1
resource "aws_instance" "public_servers" {
  for_each = toset([
    "web1",
    "web2",
    "app1"
  ])

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.week09.key_name

  subnet_id = aws_subnet.public.id

  associate_public_ip_address = true

  vpc_security_group_ids = [
    each.key == "app1" ?
    aws_security_group.application.id :
    aws_security_group.public_servers.id
  ]

  credit_specification {
    cpu_credits = "standard"
  }

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "week09-${each.key}"
    Role = each.key
  }
}

# Private Ubuntu database server
resource "aws_instance" "database" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.week09.key_name

  subnet_id = aws_subnet.private.id

  associate_public_ip_address = false

  vpc_security_group_ids = [
    aws_security_group.database.id
  ]

  credit_specification {
    cpu_credits = "standard"
  }

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "week09-db1"
    Role = "db1"
  }
}


# Allow private database server to use app1 package proxy
resource "aws_vpc_security_group_ingress_rule" "application_proxy" {
  security_group_id = aws_security_group.application.id

  description                  = "Package proxy access from db1"
  referenced_security_group_id = aws_security_group.database.id
  from_port                    = 3128
  to_port                      = 3128
  ip_protocol                  = "tcp"
}
