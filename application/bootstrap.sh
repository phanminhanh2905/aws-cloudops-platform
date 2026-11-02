#!/bin/bash
set -Eeuo pipefail

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

APP_PORT="${app_port}"
S3_BUCKET="${s3_bucket_name}"
S3_OBJECT="${s3_object_key}"
AWS_REGION="ap-southeast-1"

RDS_HOST="${rds_endpoint}"
RDS_SECRET_ARN="${rds_secret_arn}"

APP_IMAGE="techworld-app:1.0"
CONTAINER_NAME="techworld-app"

echo "Starting CloudOps bootstrap..."

# ------------------------------------------------------------
# Install dependencies
# ------------------------------------------------------------

dnf install -y docker jq

systemctl enable --now docker

# ------------------------------------------------------------
# Download Docker image from S3
# ------------------------------------------------------------

mkdir -p /opt/cloudops

aws s3 cp \
  "s3://$${S3_BUCKET}/$${S3_OBJECT}" \
  /opt/cloudops/techworld-app.tar \
  --region "$AWS_REGION"

docker load -i /opt/cloudops/techworld-app.tar

# ------------------------------------------------------------
# Retrieve RDS master credentials
# ------------------------------------------------------------

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$RDS_SECRET_ARN" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.password')

# ------------------------------------------------------------
# Wait for RDS
# ------------------------------------------------------------

echo "Waiting for RDS..."

for i in $(seq 1 60); do
  if python3 -c "import socket; s=socket.create_connection(('$RDS_HOST',3306),timeout=3); s.close()" 2>/dev/null; then
    echo "RDS port is reachable."
    break
  fi

  if [ "$i" -eq 60 ]; then
    echo "RDS connection timeout."
    exit 1
  fi

  sleep 10
done

# ------------------------------------------------------------
# Initialize database schema
# ------------------------------------------------------------

docker run --rm \
  --entrypoint python \
  -e DB_HOST="$RDS_HOST" \
  -e DB_PORT=3306 \
  -e DB_USER="$DB_USER" \
  -e DB_PASSWORD="$DB_PASSWORD" \
  -e DB_NAME=techworld \
  "$APP_IMAGE" \
  -c '
import os
import pymysql

conn = pymysql.connect(
    host=os.environ["DB_HOST"],
    port=3306,
    user=os.environ["DB_USER"],
    password=os.environ["DB_PASSWORD"],
    connect_timeout=10,
    autocommit=True,
    client_flag=pymysql.constants.CLIENT.MULTI_STATEMENTS
)

with open("/app/schema.sql", "r") as f:
    sql = f.read()

with conn.cursor() as cur:
    for statement in sql.split(";"):
        statement = statement.strip()
        if statement:
            cur.execute(statement)

conn.close()
print("Database schema initialized.")
'

# ------------------------------------------------------------
# Run application container
# ------------------------------------------------------------

docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

docker run -d \
  --name "$CONTAINER_NAME" \
  --restart always \
  --log-driver awslogs \
  --log-opt awslogs-region="$AWS_REGION" \
  --log-opt awslogs-group="/aws/ec2/cloudops-platform/application" \
  --log-opt awslogs-stream="$(hostname)" \
  -p "$${APP_PORT}:$${APP_PORT}" \
  -e APP_PORT="$${APP_PORT}" \
  -e DB_HOST="$${RDS_HOST}" \
  -e DB_PORT=3306 \
  -e DB_NAME=techworld \
  -e DB_USER="$${DB_USER}" \
  -e DB_PASSWORD="$${DB_PASSWORD}" \
  "$${APP_IMAGE}"

# ------------------------------------------------------------
# Install CloudWatch Agent
# ------------------------------------------------------------

AGENT_RPM="https://amazoncloudwatch-agent-ap-southeast-1.s3.ap-southeast-1.amazonaws.com/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm"

curl -fSL "$AGENT_RPM" -o /tmp/amazon-cloudwatch-agent.rpm
rpm -U /tmp/amazon-cloudwatch-agent.rpm

# ------------------------------------------------------------
# CloudWatch Agent configuration
# ------------------------------------------------------------

cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'CONFIG'
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "metrics": {
    "namespace": "CloudOpsLab/EC2",
    "metrics_collected": {
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": ["used_percent"],
        "resources": ["/"],
        "metrics_collection_interval": 60
      }
    }
  }
}
CONFIG

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s

echo "CloudOps bootstrap completed."