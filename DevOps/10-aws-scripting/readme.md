# AWS Shell Scripting & Automation 🔧

Automate AWS operations with shell scripts.

---

## EC2 Instance Management

### List EC2 Instances

```bash
# List all EC2 instance IDs
aws ec2 describe-instances | jq '.Reservations[].Instances[].InstanceId'
```

### Get Instance Details

```bash
# List running instances with details
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]' --output table

# Get instance by tag
aws ec2 describe-instances --filters "Name=tag:Name,Values=my-instance"

# Get specific instance ID
aws ec2 describe-instances --instance-ids i-1234567890abcdef0
```

---

## Common AWS CLI Commands

### Regions & Availability Zones

```bash
# List all regions
aws ec2 describe-regions

# List availability zones in region
aws ec2 describe-availability-zones --region us-east-1
```

### Security Groups

```bash
# List security groups
aws ec2 describe-security-groups

# Get specific security group
aws ec2 describe-security-groups --group-ids sg-12345678

# Create security group
aws ec2 create-security-group --group-name my-sg --description "My security group"

# Add ingress rule
aws ec2 authorize-security-group-ingress --group-id sg-12345678 --protocol tcp --port 22 --cidr 0.0.0.0/0
```

### S3 Bucket Operations

```bash
# List all S3 buckets
aws s3 ls

# List bucket contents
aws s3 ls s3://my-bucket/

# Upload file to S3
aws s3 cp myfile.txt s3://my-bucket/

# Download from S3
aws s3 cp s3://my-bucket/myfile.txt .

# Sync directory to S3
aws s3 sync ./local-folder s3://my-bucket/
```

### Key Pairs

```bash
# List key pairs
aws ec2 describe-key-pairs

# Create key pair
aws ec2 create-key-pair --key-name my-key

# Delete key pair
aws ec2 delete-key-pair --key-name my-key
```

---

## Useful Bash Tips

### Use jq for JSON parsing

```bash
# Pretty print JSON
aws ec2 describe-instances | jq '.'

# Extract specific field
aws ec2 describe-instances | jq '.Reservations[0].Instances[0].InstanceId'

# Filter results
aws ec2 describe-instances | jq '.Reservations[] | select(.Instances[0].State.Name=="running")'
```

### Parse Output with awk/grep

```bash
# Filter running instances
aws ec2 describe-instances | grep "RUNNING"

# Extract IP addresses
aws ec2 describe-instances | grep "PrivateIpAddress" | awk '{print $2}'
```

---

## Script Example

Basic AWS instance management script:

```bash
#!/bin/bash

# List running instances
function list_instances() {
    aws ec2 describe-instances \
        --filters "Name=instance-state-name,Values=running" \
        --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' \
        --output table
}

# Start instance
function start_instance() {
    aws ec2 start-instances --instance-ids $1
}

# Stop instance
function stop_instance() {
    aws ec2 stop-instances --instance-ids $1
}

# Main
case $1 in
    list) list_instances ;;
    start) start_instance $2 ;;
    stop) stop_instance $2 ;;
    *) echo "Usage: $0 {list|start|stop} [instance-id]" ;;
esac
```

---

**Last Updated:** December 22, 2025
