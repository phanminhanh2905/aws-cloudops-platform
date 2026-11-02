
# ============================================================
# CloudWatch Alarm Notifications
# ============================================================

resource "aws_sns_topic" "cloudwatch_alarms" {
  name = "${var.project_name}-cloudwatch-alarms"

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_sns_topic_subscription" "cloudwatch_alarms_email" {
  topic_arn = aws_sns_topic.cloudwatch_alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# ============================================================
# Application Log Group
# ============================================================

resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/ec2/cloudops-platform/application"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.project_name}-application-logs"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# Auto Scaling Group Availability Alarm
# ============================================================

resource "aws_cloudwatch_metric_alarm" "asg_capacity" {
  alarm_name          = "${var.project_name}-asg-capacity-low"
  alarm_description   = "Application ASG has fewer than two InService instances"
  namespace           = "AWS/AutoScaling"
  metric_name         = "GroupInServiceInstances"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  threshold           = 2
  comparison_operator = "LessThanThreshold"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }

  treat_missing_data = "notBreaching"
  alarm_actions      = [aws_sns_topic.cloudwatch_alarms.arn]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# ALB Unhealthy Target Alarm
# ============================================================

resource "aws_cloudwatch_metric_alarm" "unhealthy_targets" {
  alarm_name          = "${var.project_name}-unhealthy-targets"
  alarm_description   = "One or more application targets are unhealthy"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    LoadBalancer = aws_lb.app.arn_suffix
    TargetGroup  = aws_lb_target_group.app.arn_suffix
  }

  treat_missing_data = "notBreaching"
  alarm_actions      = [aws_sns_topic.cloudwatch_alarms.arn]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# EC2 CPU Alarm
# ============================================================

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-high-cpu"
  alarm_description   = "Average application EC2 CPU exceeds threshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = var.cpu_alarm_threshold
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }

  treat_missing_data = "notBreaching"
  alarm_actions      = [aws_sns_topic.cloudwatch_alarms.arn]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# CloudWatch Dashboard
# ============================================================

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title   = "Application EC2 CPU Utilization"
          view    = "timeSeries"
          stacked = false
          region  = "ap-southeast-1"
          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "AutoScalingGroupName",
              aws_autoscaling_group.app.name
            ]
          ]
          period = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title   = "ALB Request Count"
          view    = "timeSeries"
          stacked = false
          region  = "ap-southeast-1"
          metrics = [
            [
              "AWS/ApplicationELB",
              "RequestCount",
              "LoadBalancer",
              aws_lb.app.arn_suffix
            ]
          ]
          period = 60
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          title   = "Healthy Application Targets"
          view    = "timeSeries"
          stacked = false
          region  = "ap-southeast-1"
          metrics = [
            [
              "AWS/ApplicationELB",
              "HealthyHostCount",
              "LoadBalancer",
              aws_lb.app.arn_suffix,
              "TargetGroup",
              aws_lb_target_group.app.arn_suffix
            ]
          ]
          period = 60
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          title   = "ALB Target Response Time"
          view    = "timeSeries"
          stacked = false
          region  = "ap-southeast-1"
          metrics = [
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              "LoadBalancer",
              aws_lb.app.arn_suffix,
              "TargetGroup",
              aws_lb_target_group.app.arn_suffix
            ]
          ]
          period = 60
        }
      }
    ]
  })
}

# ============================================================
# Outputs
# ============================================================

output "alb_dns_name" {
  description = "Public DNS name of the application ALB"
  value       = aws_lb.app.dns_name
}

output "cloudwatch_dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}
