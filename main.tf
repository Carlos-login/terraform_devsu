# Create a VPC
resource "aws_vpc" "devsu_vpc" {
  cidr_block = "10.0.0.0/16"
}


resource "aws_subnet" "devsu_subnet_public1" {
  vpc_id     = aws_vpc.devsu_vpc.id
  cidr_block = "10.0.0.0/24"

}

resource "aws_subnet" "devsu_subnet_public2" {
  vpc_id     = aws_vpc.devsu_vpc.id
  cidr_block = "10.0.1.0/24"

}

resource "aws_ecr_repository" "my_ecr" {
  name                 = "devsu"
// escaneo de vulne
  image_scanning_configuration {
    scan_on_push = true
  }
}


