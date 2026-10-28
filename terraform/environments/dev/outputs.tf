output "vpc_id" {
  description = "ID of the project VPC"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "Subnet IDs grouped by subnet name"
  value = {
    for name, subnet in aws_subnet.main :
    name => subnet.id
  }
}