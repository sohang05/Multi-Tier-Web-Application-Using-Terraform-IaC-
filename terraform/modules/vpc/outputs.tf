output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "public_subnets" {
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  description = "List of public subnet IDs"
}

output "private_subnets" {
  value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  description = "List of private subnet IDs"
}

output "igw_id" {
  value       = aws_internet_gateway.igw.id
  description = "Internet Gateway ID"
}

output "nat_gateway_id" {
  value       = aws_nat_gateway.nat.id
  description = "NAT Gateway ID"
}
