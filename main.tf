# Create a VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_ecr_repository" "my_ecr" {
  name                 = "devsu"
// escaneo de vulne
  image_scanning_configuration {
    scan_on_push = true
  }
}
