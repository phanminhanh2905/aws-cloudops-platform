
# ============================================================
# Application Security Group
# ============================================================

resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "Security group for application instances"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Allow app instance outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-app-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# Application Load Balancer Security Group
# ============================================================

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow HTTP traffic from internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidr
  }

  tags = {
    Name        = "${var.project_name}-alb-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# VPC Endpoint Security Group
# ============================================================

resource "aws_security_group" "endpoint" {
  name        = "${var.project_name}-endpoint-sg"
  description = "Allow HTTPS from application instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTPS from application instances"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    description = "Allow outbound IPv4 traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-endpoint-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# ALB -> Application EC2
# ============================================================

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.alb.id

  description = "Application traffic from ALB"
  ip_protocol = "tcp"
  from_port   = var.app_port
  to_port     = var.app_port
}

resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.app.id

  description = "Forward traffic to application instances"
  ip_protocol = "tcp"
  from_port   = var.app_port
  to_port     = var.app_port
}

# ============================================================
# RDS Security Group
# ============================================================

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow MySQL traffic from application EC2"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-rds-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_app" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.app.id

  ip_protocol = "tcp"
  from_port   = 3306
  to_port     = 3306

  description = "Allow MySQL from application EC2"
}