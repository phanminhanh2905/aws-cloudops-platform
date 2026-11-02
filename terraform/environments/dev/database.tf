# ============================================================
# DB Subnet Group
# ============================================================

resource "aws_db_subnet_group" "main" {
  name        = "${var.project_name}-db-subnet-group"
  description = "Private database subnets across two AZs"

  subnet_ids = [
    aws_subnet.main["db_a"].id,
    aws_subnet.main["db_b"].id
  ]

  tags = {
    Name        = "${var.project_name}-db-subnet-group"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# RDS MySQL - Multi-AZ
# ============================================================

resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-mysql"

  # Engine
  engine = "mysql"

  # Instance
  instance_class = "db.t3.micro"

  # Storage - minimum size
  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  # Database
  db_name  = "techworld"
  username = "techworld_admin"
  port     = 3306

  # Let AWS manage master password in Secrets Manager
  manage_master_user_password = true

  # Networking
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  # High Availability
  multi_az = true

  # Cost control
  backup_retention_period = 0
  deletion_protection     = false
  skip_final_snapshot     = true

  # Disable additional monitoring options
  monitoring_interval          = 0
  performance_insights_enabled = false
  auto_minor_version_upgrade   = false

  tags = {
    Name        = "${var.project_name}-mysql"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# Outputs
# ============================================================

output "rds_endpoint" {
  description = "RDS MySQL endpoint"
  value       = aws_db_instance.main.endpoint
}

output "rds_address" {
  description = "RDS MySQL hostname"
  value       = aws_db_instance.main.address
}

output "rds_secret_arn" {
  description = "RDS managed master credentials secret ARN"
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}
