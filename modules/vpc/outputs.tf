output "vpc_id" {
  value = aws_vpc.devsu_vpc.id
}

output "public_subnets" {
  value = [aws_subnet.devsu_subnet_public1.id, aws_subnet.devsu_subnet_public2.id]
}
