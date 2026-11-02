# AWS CloudOps Platform

A personal CloudOps portfolio project demonstrating AWS infrastructure provisioning, application deployment, high availability, monitoring, and operational troubleshooting with Terraform.

> **Three tiers. Two Availability Zones. One observable application stack.**

## Architecture

![AWS CloudOps Platform architecture](<docs/screenshots/AWS CloudOps Platform Architecture.png>)

The platform runs in `ap-southeast-1`. An internet-facing ALB accepts HTTPS for the custom domain and routes traffic to a Dockerized Flask application on private EC2 instances managed by an Auto Scaling Group. The app connects to a private Multi-AZ RDS for MySQL database.

## Tech Stack

| Area | Services |
| --- | --- |
| Cloud and IaC | AWS · Terraform |
| Compute and networking | EC2 · Auto Scaling Group · VPC · ALB · Security Groups · VPC Endpoints |
| Data and containers | Amazon RDS for MySQL (Multi-AZ) · Amazon S3 · Docker |
| Operations and security | CloudWatch · IAM · Secrets Manager · Systems Manager · ACM |

## Key Features

- Multi-AZ application deployment across private subnets.
- HTTPS with a custom domain, terminated at the Application Load Balancer.
- Auto Scaling Group uses ELB health checks to replace unhealthy application instances.
- Multi-AZ MySQL database with credentials managed by AWS Secrets Manager.
- Centralized application logs, metrics, dashboards, alarms, and SNS email notifications.
- Terraform-managed infrastructure and repeatable deployment workflow.

## Application

**TechWorld:** [https://techworld.pma-server.site](https://techworld.pma-server.site)

The demo is available while the lab infrastructure is running.

## Screenshots

### 1. Application

| Screenshot | Description |
| --- | --- |
| <a href="docs/screenshots/17-web-homepage.png"><img src="docs/screenshots/17-web-homepage.png" width="420" alt="TechWorld homepage"></a> | TechWorld homepage served over HTTPS. |
| <a href="docs/screenshots/18-web-technologies-page.png"><img src="docs/screenshots/18-web-technologies-page.png" width="420" alt="TechWorld technologies page"></a> | Application technologies page. |

### 2. Networking

| Screenshot | Description |
| --- | --- |
| <a href="docs/screenshots/01-vpc-overview.png"><img src="docs/screenshots/01-vpc-overview.png" width="420" alt="VPC overview"></a> | Lab VPC and network layout. |
| <a href="docs/screenshots/02-vpc-subnets.png"><img src="docs/screenshots/02-vpc-subnets.png" width="420" alt="VPC subnets"></a> | Public, application, and database subnets across two AZs. |
| <a href="docs/screenshots/03-alb-overview.png"><img src="docs/screenshots/03-alb-overview.png" width="420" alt="Application Load Balancer"></a> | Internet-facing Application Load Balancer. |
| <a href="docs/screenshots/15-vpc-endpoints.png"><img src="docs/screenshots/15-vpc-endpoints.png" width="420" alt="VPC endpoints"></a> | Interface and S3 Gateway endpoints for private AWS service access. |

### 3. Compute & Auto Scaling

| Screenshot | Description |
| --- | --- |
| <a href="docs/screenshots/04-target-group-health.png"><img src="docs/screenshots/04-target-group-health.png" width="420" alt="Target group health"></a> | Healthy application targets and health-check status. |
| <a href="docs/screenshots/05-asg-overview.png"><img src="docs/screenshots/05-asg-overview.png" width="420" alt="Auto Scaling Group"></a> | Auto Scaling Group capacity and configuration. |
| <a href="docs/screenshots/06-ec2-instances.png"><img src="docs/screenshots/06-ec2-instances.png" width="420" alt="EC2 instances"></a> | Application EC2 instances across Availability Zones. |

### 4. Database & Storage

| Screenshot | Description |
| --- | --- |
| <a href="docs/screenshots/07-rds-configuration.png"><img src="docs/screenshots/07-rds-configuration.png" width="420" alt="RDS configuration"></a> | Private Multi-AZ RDS for MySQL configuration. |
| <a href="docs/screenshots/08-rds-connectivity.png"><img src="docs/screenshots/08-rds-connectivity.png" width="420" alt="RDS connectivity"></a> | Database connectivity and network configuration. |
| <a href="docs/screenshots/22-s3-object-file.png"><img src="docs/screenshots/22-s3-object-file.png" width="420" alt="S3 application image object"></a> | Application image artifact stored in Amazon S3. |

### 5. Security

| Screenshot | Description |
| --- | --- |
| <a href="docs/screenshots/13-acm-certificate.png"><img src="docs/screenshots/13-acm-certificate.png" width="420" alt="ACM certificate"></a> | Issued ACM certificate for the application domain. |
| <a href="docs/screenshots/14-security-group.png"><img src="docs/screenshots/14-security-group.png" width="420" alt="Security group rules"></a> | Security group rules for the application tiers. |
| <a href="docs/screenshots/16-system-manager-nodes.png"><img src="docs/screenshots/16-system-manager-nodes.png" width="420" alt="Systems Manager managed nodes"></a> | App instances registered as Systems Manager managed nodes. |
| <a href="docs/screenshots/19-secrets-manager.png"><img src="docs/screenshots/19-secrets-manager.png" width="420" alt="Secrets Manager"></a> | RDS-managed database credential in Secrets Manager. |

### 6. Monitoring & Logging

| Screenshot | Description |
| --- | --- |
| <a href="docs/screenshots/09-cloudwatch-dashboard.png"><img src="docs/screenshots/09-cloudwatch-dashboard.png" width="420" alt="CloudWatch dashboard"></a> | CloudWatch dashboard for application operations. |
| <a href="docs/screenshots/10-cloudwatch-log-stream.png"><img src="docs/screenshots/10-cloudwatch-log-stream.png" width="420" alt="CloudWatch application logs"></a> | Centralized application log stream. |
| <a href="docs/screenshots/11-cloudwatch-alarms.png"><img src="docs/screenshots/11-cloudwatch-alarms.png" width="420" alt="CloudWatch alarms"></a> | Availability, target health, and CPU alarms. |
| <a href="docs/screenshots/12-sns-topics.png"><img src="docs/screenshots/12-sns-topics.png" width="420" alt="SNS alarm notifications"></a> | SNS topic and confirmed email subscription for alarm notifications. |

### 7. Infrastructure as Code

| Screenshot | Description |
| --- | --- |
| <a href="docs/screenshots/20-terraform-plan-no-changes.png"><img src="docs/screenshots/20-terraform-plan-no-changes.png" width="420" alt="Terraform plan with no changes"></a> | Terraform plan reporting no pending infrastructure changes. |
| <a href="docs/screenshots/21-terraform-structures.png"><img src="docs/screenshots/21-terraform-structures.png" width="420" alt="Terraform project structure"></a> | Terraform environment and configuration files. |

## Deployment

Prerequisites: Terraform, AWS CLI credentials for the target account, and the required application image in S3. Set an email address for SNS alarm notifications before planning:

```bash
cd terraform/environments/dev
export TF_VAR_alarm_email="you@example.com"

terraform init
terraform validate
terraform plan
# Review the plan before applying changes.
terraform apply
```

Confirm the SNS subscription from the email AWS sends after deployment.

AWS Region: `ap-southeast-1`

## Key Learning Outcomes

- AWS infrastructure design and provisioning with Terraform.
- High availability and Auto Scaling behavior across Availability Zones.
- Application, network, and bootstrap troubleshooting.
- Cloud monitoring, centralized logging, and alarm notifications.
- Infrastructure security and cost-aware operations.

## Disclaimer

This is a personal learning and portfolio project. It is not a production reference. AWS resources can incur ongoing charges; review costs and destroy the lab when it is no longer needed.
