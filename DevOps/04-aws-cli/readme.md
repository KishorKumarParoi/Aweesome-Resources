# AWS CLI & SSH Configuration ☁️

AWS command-line setup and secure SSH key management.

---

## SSH Connection Setup

### Initial SSH Connection (Without Key)
```bash
# Attempt connection without key
ssh ubuntu@34.239.181.190
# Error: Permission denied (publickey)
```

### SSH Connection With PEM Key
```bash
# Try with PEM key
ssh -i test.pem ubuntu@34.239.181.190
# Error: WARNING: UNPROTECTED PRIVATE KEY FILE!
# Permissions 0644 for 'test.pem' are too open
```

### Fix PEM File Permissions
```bash
# Set correct permissions
chmod 600 test.pem

# Now retry connection
ssh -i test.pem ubuntu@34.239.181.190
# Success! ✅
```

---

## PEM File Permissions

**Why?** SSH requires strict permissions (600) for security:
- Owner can read/write only
- Group and others have no permissions
- Prevents unauthorized access

```
chmod 600    = rw-------  (600)
```

---

## AWS CLI Commands

### List EC2 Instances
```bash
# List all EC2 instance IDs
aws ec2 describe-instances | jq '.Reservations[].Instances[].InstanceId'
```

### Other Useful AWS CLI Commands
```bash
# List all regions
aws ec2 describe-regions

# Describe security groups
aws ec2 describe-security-groups

# List S3 buckets
aws s3 ls

# List running instances with details
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]' --output table
```

---

**Last Updated:** December 22, 2025
