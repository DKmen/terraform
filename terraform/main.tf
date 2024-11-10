#Retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

#Define locals
locals {
  theme        = "ap-management-dev"
  application  = "terraform-demo"
  service_name = "ec2-${var.vpc_name}-${var.aws_region}"
}

#Generate a random string for the S3 bucket name
resource "random_string" "random" {
  length  = 10
  special = false
  upper   = false
}

#Define the VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = var.vpc_name
    Environment = "demo_environment"
    Terraform   = "true"
    Theme       = local.theme
    Application = local.application
    Service     = local.service_name
  }
}

#Deploy the private subnets
resource "aws_subnet" "private_subnets" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]

  tags = {
    Name        = each.key
    Terraform   = "true"
    Theme       = local.theme
    Application = local.application
    Service     = local.service_name
  }
}

#Deploy the public subnets
resource "aws_subnet" "public_subnets" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value + 100)
  availability_zone       = tolist(data.aws_availability_zones.available.names)[each.value]
  map_public_ip_on_launch = true

  tags = {
    Name        = each.key
    Terraform   = "true"
    Theme       = local.theme
    Application = local.application
    Service     = local.service_name
  }
}

#Create route tables for public and private subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
    #nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name        = "demo_public_rtb"
    Terraform   = "true"
    Theme       = local.theme
    Application = local.application
    Service     = local.service_name
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    # gateway_id     = aws_internet_gateway.internet_gateway.id
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name        = "demo_private_rtb"
    Terraform   = "true"
    Theme       = local.theme
    Application = local.application
    Service     = local.service_name
  }
}

#Create route table associations
resource "aws_route_table_association" "public" {
  depends_on     = [aws_subnet.public_subnets]
  route_table_id = aws_route_table.public_route_table.id
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
}

resource "aws_route_table_association" "private" {
  depends_on     = [aws_subnet.private_subnets]
  route_table_id = aws_route_table.private_route_table.id
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
}

#Create Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "demo_igw"
    Terraform   = "true"
    Theme       = local.theme
    Application = local.application
    Service     = local.service_name
  }
}

#Create EIP for NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name        = "demo_igw_eip"
    Terraform   = "true"
    Theme       = local.theme
    Application = local.application
    Service     = local.service_name
  }
}

#Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  depends_on    = [aws_subnet.public_subnets]
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnets["public_subnet_1"].id
  tags = {
    Name        = "demo_nat_gateway"
    Terraform   = "true"
    Theme       = local.theme
    Application = local.application
    Service     = local.service_name
  }
}

#Create Default Security Group
resource "aws_security_group" "default_sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "Allow HTTP traffic from the VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all traffic to the VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "demo_default_sg"
    Terraform   = "true"
    Theme       = local.theme
    Application = local.application
    Service     = local.service_name
  }
}

#Create EC2 Instance
resource "aws_instance" "web" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnets["public_subnet_1"].id
  vpc_security_group_ids = [aws_security_group.default_sg.id]
  tags = {
    Name        = "demo_web_server"
    Terraform   = "true"
    Theme       = local.theme
    Application = local.application
    Service     = local.service_name
  }
}

#Create S3 Bucket with random name
resource "aws_s3_bucket" "my-new-S3-bucket" {
  bucket = "my-new-tf-test-bucket-${random_string.random.result}"
  tags = {
    Name        = "My S3 Bucket"
    Purpose     = "Intro to Resource Blocks Lab"
    Terraform   = "true"
    Theme       = local.theme
    Application = local.application
    Service     = local.service_name
  }
}

resource "aws_s3_bucket_acl" "my_new_bucket_acl" {
  bucket = aws_s3_bucket.my-new-S3-bucket.id
  acl    = "private"
}

#Set the bucket ACL to BucketOwnerPreferred
resource "aws_s3_bucket_ownership_controls" "my_new_bucket_acl" {
  bucket = aws_s3_bucket.my-new-S3-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

#Generate ssh key
resource "tls_private_key" "generated" {
  algorithm = "RSA"
}
resource "local_file" "private_key_pem" {
  content  = tls_private_key.generated.private_key_pem
  filename = "MyAWSKey.pem"
}