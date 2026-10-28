resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

locals {
  subnets = {
    public_a = {
      cidr = "10.20.1.0/24"
      az   = var.availability_zones[0]
      tier = "public"
    }
    public_b = {
      cidr = "10.20.2.0/24"
      az   = var.availability_zones[1]
      tier = "public"
    }
    app_a = {
      cidr = "10.20.11.0/24"
      az   = var.availability_zones[0]
      tier = "app"
    }
    app_b = {
      cidr = "10.20.12.0/24"
      az   = var.availability_zones[1]
      tier = "app"
    }
    db_a = {
      cidr = "10.20.21.0/24"
      az   = var.availability_zones[0]
      tier = "db"
    }
    db_b = {
      cidr = "10.20.22.0/24"
      az   = var.availability_zones[1]
      tier = "db"
    }
  }
}

resource "aws_subnet" "main" {
  for_each = local.subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.tier == "public"

  tags = {
    Name        = "${var.project_name}-${replace(each.key, "_", "-")}"
    Tier        = each.value.tier
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-public-rt"
    Tier        = "public"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table" "app" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-app-rt"
    Tier        = "app"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-db-rt"
    Tier        = "db"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_route_table_association" "public" {
  for_each = {
    public_a = aws_subnet.main["public_a"].id
    public_b = aws_subnet.main["public_b"].id
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each = {
    app_a = aws_subnet.main["app_a"].id
    app_b = aws_subnet.main["app_b"].id
    db_a  = aws_subnet.main["db_a"].id
    db_b  = aws_subnet.main["db_b"].id
  }

  subnet_id      = each.value
  route_table_id = each.key == "app_a" || each.key == "app_b" ? aws_route_table.app.id : aws_route_table.db.id
}