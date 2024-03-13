resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

output "vpc_id" {
  value       = aws_vpc.main.id
  sensitive   = false
  description = "VPC id"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index] # Replace with actual AZ

  tags = {
    Name                        = "${var.public_subnet_name}-${count.index + 1}"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = "1"
    # Add other tags as needed
  }

  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index] # Replace with actual AZ

  tags = {
    Name                              = "${var.private_subnet_name}-${count.index + 1}"
    "kubernetes.io/cluster/eks"       = "shared"
    "kubernetes.io/role/internal-alb" = "1"
    # Add other tags as needed
  }
}

# Create Elastic IPs
resource "aws_eip" "nat_public" {
  #count      = length(var.public_subnet_cidr_blocks)
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

# Create NAT Gateways
resource "aws_nat_gateway" "nat_gateway" {
  #count         = length(var.public_subnet_cidr_blocks)
  allocation_id = aws_eip.nat_public.id
  subnet_id     = aws_subnet.public[0].id
  depends_on = [aws_internet_gateway.igw]
}

# Create public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public"
    # Add other tags as needed
  }
}

# Create private route table
resource "aws_route_table" "private" {
  count  = length(var.public_subnet_cidr_blocks)
  vpc_id = aws_vpc.main.id
   
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "private"
    # Add other tags as needed
  }
}

# Create association for public subnet route table
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create associations for private subnet route table
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
  # route_table_id = aws_route_table.private.id
}
