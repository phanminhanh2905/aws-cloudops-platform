data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

output "aws_account_id" {
  description = "AWS account used by this Terraform configuration"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_caller_arn" {
  description = "Identity used by Terraform"
  value       = data.aws_caller_identity.current.arn
}

output "aws_region" {
  description = "AWS region used by this configuration"
  value       = data.aws_region.current.region
}
