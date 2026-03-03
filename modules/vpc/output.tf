# Public Subnet Outputs
output "vpc_id" {
  value = aws_vpc.task1.id
}

output "public_subnet_ids" {
  value = aws_subnet.task1_private_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.task1_private_subnet[*].id
}