# Ultimate DevOps Project 🚀

Complete DevOps workflow: setup, deployment, and production management.

---

## Project Overview

This project combines:
- Infrastructure setup (AWS EC2)
- Container management (Docker)
- Orchestration (Kubernetes)
- Infrastructure as Code (Terraform)
- Configuration (Ansible)
- Monitoring (CloudWatch, Prometheus, Grafana)

---

## System Setup & Cleanup

### Clear RAM

Free up memory for optimization:

```bash
# Sync and clear cache
sudo sync && sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches' && echo "RAM cleared!"

# Verify free memory
free -h
```

### Clean Docker

Remove unused containers, images, and volumes:

```bash
# Remove stopped containers
docker container prune

# Remove dangling images
docker image prune

# Remove unused volumes
docker volume prune

# Remove all unused resources (aggressive)
docker system prune -af
```

### Restart Services

```bash
# Restart Docker daemon
sudo systemctl restart docker

# Check Docker status
sudo systemctl status docker
```

---

## Install Dependencies

### Go Programming Language

```bash
# Install Go
sudo apt-get install golang-go

# Verify installation
go version
```

### Java Runtime Environment (JRE)

```bash
# Install Java 21 JRE (no compiler)
sudo apt install openjdk-21-jre-headless

# Verify installation
java -version
```

### Node.js & NPM

```bash
# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Verify
node --version
npm --version
```

---

## File Transfer to EC2

### Upload PEM Key

Transfer SSH key to bastion/jump server:

```bash
# Copy PEM file to remote EC2
sudo scp -i ./bastion.pem ./devOps-demo.pem ubuntu@54.196.55.201:/home/ubuntu

# Fix permissions on remote
ssh -i ./bastion.pem ubuntu@54.196.55.201 "chmod 600 ~/devOps-demo.pem"

# Verify
ssh -i ./bastion.pem ubuntu@54.196.55.201 "ls -la ~/devOps-demo.pem"
```

### Upload Application Files

```bash
# Copy entire directory
scp -i bastion.pem -r ./myapp ubuntu@server:/home/ubuntu/

# Copy single file
scp -i bastion.pem package.json ubuntu@server:/home/ubuntu/
```

---

## Keep Process Running with PM2

Process manager for Node.js applications (with auto-restart).

### Install PM2

```bash
# Install PM2 globally
sudo npm install -g pm2

# Or via apt
sudo apt-get install npm
npm install -g pm2
```

### Start Application

```bash
# Start Python HTTP server
pm2 start "python3 -m http.server 3001" --name "website"

# Start Node.js app
pm2 start "node server.js" --name "api"

# Start with custom config
pm2 start app.js --name "myapp" --instances max --exec-mode cluster
```

### Enable Auto-start on Boot

```bash
# Generate startup script
pm2 startup

# Copy and run the output command (looks like):
# sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup ...

# Save PM2 process list
pm2 save
```

### PM2 Commands

```bash
# List running processes
pm2 list

# View detailed process info
pm2 show website

# Monitor processes
pm2 monit

# View logs
pm2 logs website

# Follow logs (tail -f)
pm2 logs website --lines 100 --follow

# Stop process
pm2 stop website

# Restart process
pm2 restart website

# Reload process (zero-downtime)
pm2 reload website

# Delete process from PM2
pm2 delete website

# Delete all processes
pm2 delete all

# Save/load configuration
pm2 save       # Save current list
pm2 resurrect  # Restore saved processes
```

---

## Ecosystem File (pm2.config.js)

Advanced PM2 configuration:

```javascript
module.exports = {
  apps: [
    {
      name: 'api',
      script: 'server.js',
      instances: 'max',
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'development',
        PORT: 3000
      },
      env_production: {
        NODE_ENV: 'production',
        PORT: 3001
      }
    },
    {
      name: 'worker',
      script: 'worker.js',
      instances: 2,
      max_memory_restart: '500M'
    }
  ]
};
```

Start from config:
```bash
pm2 start pm2.config.js
pm2 start pm2.config.js --env production
```

---

## Health Checks & Monitoring

### Basic Health Check

```bash
# Check if server is running
curl http://localhost:3001

# Check with verbose output
curl -v http://localhost:3001

# Test specific endpoint
curl http://localhost:3001/api/health
```

### Verify Security Group

```bash
# Ensure EC2 security group allows port access
# AWS Console → Security Groups → Edit Inbound Rules

# Allow port 3001
Protocol: TCP
Port Range: 3001
Source: 0.0.0.0/0 (or specific IP)
```

### Port Forwarding Test

```bash
# From local machine
ssh -i bastion.pem -L 3001:localhost:3001 ubuntu@ec2-ip

# Now access locally
curl http://localhost:3001
```

---

## Production Checklist

- [ ] Application deployed and running
- [ ] Health checks passing
- [ ] Security group configured
- [ ] PM2 configured for auto-restart
- [ ] Logs being captured
- [ ] Monitoring setup (CloudWatch)
- [ ] Backups configured
- [ ] SSL/TLS certificates installed
- [ ] Firewall rules updated
- [ ] Database configured & backed up
- [ ] Environment variables set securely
- [ ] Crash handling & alerting enabled

---

## Disaster Recovery

### Backup Application

```bash
# Create tarball of application
tar -czf app-backup-$(date +%Y%m%d).tar.gz /home/ubuntu/myapp

# Upload to S3
aws s3 cp app-backup-*.tar.gz s3://my-backups/
```

### Restore Application

```bash
# Download from S3
aws s3 cp s3://my-backups/app-backup-20240101.tar.gz .

# Extract
tar -xzf app-backup-20240101.tar.gz

# Restart with PM2
pm2 restart all
```

---

## Performance Optimization

### Monitor Memory Usage

```bash
# Check application memory
pm2 monit

# Or manually
ps aux | grep node

# Check system memory
free -h

# If memory issues, restart PM2 daemon
pm2 kill
pm2 start pm2.config.js
```

### Database Optimization

```bash
# Check slow queries
sudo tail -f /var/log/mysql/slow.log

# Monitor PostgreSQL
sudo -u postgres psql -c "SELECT * FROM pg_stat_statements"
```

---

## Key Learnings

✅ **Infrastructure**
- EC2 setup and configuration
- Security groups & network security
- IAM roles & policies

✅ **Containerization**
- Docker images & containers
- Docker Compose for orchestration
- Multi-stage builds for optimization

✅ **Orchestration**
- Kubernetes deployments
- Scaling & auto-scaling
- Service discovery

✅ **Infrastructure as Code**
- Terraform for reproducible infrastructure
- State management
- Module organization

✅ **Configuration Management**
- Ansible for automation
- Idempotent operations
- Secrets management with Vault

✅ **Monitoring & Observability**
- CloudWatch metrics
- Application logging
- Performance monitoring

✅ **Process Management**
- PM2 for production apps
- Auto-restart & clustering
- Zero-downtime reloads

---

**Project Status:** 🔄 In Progress
**Last Updated:** December 22, 2025
