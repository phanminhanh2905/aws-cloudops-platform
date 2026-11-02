
# ============================================================
# Amazon Linux 2023 AMI
# ============================================================

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# ============================================================
# Launch Template
# ============================================================

resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-app-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.app_instance_type

  vpc_security_group_ids = [
    aws_security_group.app.id
  ]

  iam_instance_profile {
    name = aws_iam_instance_profile.app_ec2.name
  }

  user_data = base64encode(
    templatefile("${path.module}/../../../application/bootstrap.sh", {
      app_port       = var.app_port
      s3_bucket_name = var.s3_bucket_name
      s3_object_key  = var.s3_object_key
      rds_endpoint   = aws_db_instance.main.address
      rds_secret_arn = aws_db_instance.main.master_user_secret[0].secret_arn
    })
  )

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 8
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.project_name}-app-instance"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name        = "${var.project_name}-app-volume"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }

  tags = {
    Name        = "${var.project_name}-app-launch-template"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# Auto Scaling Group
# ============================================================

resource "aws_autoscaling_group" "app" {
  name             = "${var.project_name}-app-asg"
  min_size         = var.asg_min_size
  desired_capacity = var.asg_desired_capacity
  max_size         = var.asg_max_size
  vpc_zone_identifier = [
    aws_subnet.main["app_a"].id,
    aws_subnet.main["app_b"].id
  ]

  target_group_arns = [
    aws_lb_target_group.app.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 180
  metrics_granularity       = "1Minute"

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  launch_template {
    id      = aws_launch_template.app.id
    version = aws_launch_template.app.latest_version
  }

  # Keep the two-AZ deployment balanced when replacing instances.
  termination_policies = ["OldestLaunchTemplate"]

  dynamic "tag" {
    for_each = {
      Name        = "${var.project_name}-app-instance"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.ssm_core,
    aws_iam_role_policy_attachment.cloudwatch_agent,
    aws_iam_role_policy.s3_get_object,
    aws_iam_role_policy.rds_secret_read
  ]

  lifecycle {
    ignore_changes = [
      desired_capacity
    ]
  }
}

# ============================================================
# Outputs
# ============================================================

output "amazon_linux_ami_id" {
  description = "Latest matching Amazon Linux 2023 AMI ID"
  value       = data.aws_ami.amazon_linux.id
}

output "launch_template_id" {
  description = "Application Launch Template ID"
  value       = aws_launch_template.app.id
}

output "autoscaling_group_name" {
  description = "Application Auto Scaling Group name"
  value       = aws_autoscaling_group.app.name
}
