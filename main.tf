provider "aws" {
    region = "us-east-2"
}

# ESTO CREA LA VPC

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc-tipizone"
  }
}

# ZONAS DE DISPONIBILIDAD

locals {
  availability_zones = [
    "us-east-2a",
    "us-east-2b",
    "us-east-2c"
  ]
}

# SUBNEDES PUBLICAS

locals {
  pub_subnets_cidr = [
    "10.0.10.0/24",
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
}

resource "aws_subnet" "public_subnets" {
  count                   = 3
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.pub_subnets_cidr[count.index]
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "pubsub-tipizone-${count.index + 1}"
  }
}

# SUBNEDES PRIVADAS

locals {
  priv_subnets_cidr = [
    "10.0.60.0/24",
    "10.0.61.0/24",
    "10.0.62.0/24"
  ]
}

resource "aws_subnet" "private_subnets" {
  count                   = 3
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.priv_subnets_cidr[count.index]
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "privsub-tipizone-${count.index + 1}"
  }
}

# ESTO ES EL IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw-tipi"
  }
}

# ROUTE TABLE
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# ESTO METE LAS SUBNETS PUBLICAS A LA RT
resource "aws_route_table_association" "public_rt_association" {
  count          = 3
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.rt.id
}