
# ============================================================
# EC2 Assume Role Policy
# ============================================================

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# ============================================================
# EC2 IAM Role
# ============================================================

resource "aws_iam_role" "app_ec2" {
  name               = "${var.project_name}-app-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name        = "${var.project_name}-app-ec2-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# Systems Manager Permissions
# ============================================================

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.app_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ============================================================
# CloudWatch Agent Permissions
# ============================================================

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.app_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# ============================================================
# Get Tar file from S3
# ============================================================

resource "aws_iam_role_policy" "s3_get_object" {
  name = "${var.project_name}-s3-get-object-policy"
  role = aws_iam_role.app_ec2.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "arn:aws:s3:::${var.s3_bucket_name}/${var.s3_object_key}"
      }
    ]
  })
}

# ============================================================
# RDS secret read from Secrets Manager
# ============================================================

resource "aws_iam_role_policy" "rds_secret_read" {
  name = "${var.project_name}-rds-secret-read"
  role = aws_iam_role.app_ec2.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = aws_db_instance.main.master_user_secret[0].secret_arn
      }
    ]
  })
}

# ============================================================
# EC2 Instance Profile
# ============================================================

resource "aws_iam_instance_profile" "app_ec2" {
  name = "${var.project_name}-app-ec2-profile"
  role = aws_iam_role.app_ec2.name

  tags = {
    Name        = "${var.project_name}-app-ec2-profile"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
