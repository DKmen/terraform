#Output the VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
  sensitive   = true
}

#Output the VPC CIDR Block
output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.vpc.cidr_block
}

#Output the VPC Name
output "vpc_name" {
  description = "The name of the VPC"
  value       = aws_vpc.vpc.tags.Name
}