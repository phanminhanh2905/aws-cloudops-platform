
# ============================================================
# Global
# ============================================================

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "cloudops-lab"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

# ============================================================
# Networking
# ============================================================

variable "vpc_cidr" {
  description = "CIDR block for the project VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones used by the lab"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Exactly two Availability Zones must be specified."
  }
}

# ============================================================
# Compute / Auto Scaling
# ============================================================

variable "app_instance_type" {
  description = "EC2 instance type for application instances"
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  description = "Minimum number of application instances"
  type        = number
  default     = 1
}

variable "asg_desired_capacity" {
  description = "Desired number of application instances"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of application instances"
  type        = number
  default     = 2
}

variable "app_port" {
  description = "Application listening port"
  type        = number
  default     = 8080
}

# ============================================================
# Load Balancer
# ============================================================

variable "alb_ingress_cidr" {
  description = "CIDR allowed to access the public ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ============================================================
# Logging
# ============================================================

variable "log_retention_days" {
  description = "CloudWatch application log retention"
  type        = number
  default     = 7
}

# ============================================================
# Monitoring
# ============================================================

variable "cpu_alarm_threshold" {
  description = "CPU utilization alarm threshold"
  type        = number
  default     = 70
}

variable "alarm_email" {
  description = "Email address subscribed to CloudWatch alarm notifications"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.alarm_email))
    error_message = "alarm_email must be a valid email address."
  }
}


# ============================================================
# S3 Bucket
# ============================================================

variable "s3_bucket_name" {
  description = "S3 bucket name for storing application tar file"
  type        = string
  default     = "techworld-registry-temp"
}

variable "s3_object_key" {
  description = "S3 object key for the application tar file"
  type        = string
  default     = "techworld-app.tar"
}
