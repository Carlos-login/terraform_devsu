resource "aws_vpc" "devsu_vpc" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "devsu_subnet_public1" {
  vpc_id            = aws_vpc.devsu_vpc.id
  cidr_block        = var.public_subnet_cidrs[0]
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "devsu_subnet_public2" {
  vpc_id            = aws_vpc.devsu_vpc.id
  cidr_block        = var.public_subnet_cidrs[1]
  availability_zone = "us-east-1b"
}

resource "aws_internet_gateway" "devsu_gw" {
  vpc_id = aws_vpc.devsu_vpc.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.devsu_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devsu_gw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.devsu_subnet_public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.devsu_subnet_public2.id
  route_table_id = aws_route_table.public.id
}
