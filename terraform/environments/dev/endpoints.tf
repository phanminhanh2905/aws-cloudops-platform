
# ============================================================
# SSM Interface Endpoint
# ============================================================

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-southeast-1.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.main["app_a"].id,
    aws_subnet.main["app_b"].id
  ]

  security_group_ids  = [aws_security_group.endpoint.id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.project_name}-ssm-endpoint"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# SSM Messages Interface Endpoint
# ============================================================

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-southeast-1.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.main["app_a"].id,
    aws_subnet.main["app_b"].id
  ]

  security_group_ids  = [aws_security_group.endpoint.id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.project_name}-ssmmessages-endpoint"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# CloudWatch Logs Interface Endpoint
# ============================================================

resource "aws_vpc_endpoint" "logs" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-southeast-1.logs"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.main["app_a"].id,
    aws_subnet.main["app_b"].id
  ]

  security_group_ids  = [aws_security_group.endpoint.id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.project_name}-logs-endpoint"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# S3 Gateway Endpoint
# ============================================================

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-southeast-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.app.id
  ]

  tags = {
    Name        = "${var.project_name}-s3-endpoint"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# Secrets Manager Endpoint
# ============================================================

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-southeast-1.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.main["app_a"].id,
    aws_subnet.main["app_b"].id
  ]

  security_group_ids  = [aws_security_group.endpoint.id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.project_name}-secretsmanager-endpoint"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}