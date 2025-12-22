# E-commerce DevOps Project 🚀

Complete guide for containerizing and deploying an e-commerce application.

## Table of Contents
1. [EC2 SSH Connection](#ec2-ssh-connection)
2. [Docker Engine Installation](#docker-engine-installation)
3. [Kubectl Installation](#kubectl-installation)
4. [Terraform Installation](#terraform-installation)
5. [Docker Compose](#docker-compose)
6. [EC2 Volume Resize](#resize-ec2-volume)

---

## EC2 SSH Connection

### Connect to EC2 Instance
```bash
# Connect to EC2 instance
ssh -i devOps-demo.pem ubuntu@52.204.118.38

# Fix permission on PEM file
chmod 600 devOps-demo.pem
```

---

## Docker Engine Installation

Complete Docker installation with buildx plugin support.

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Test Docker Installation
```bash
sudo docker run hello-world
```

### Add Ubuntu User to Docker Group
```bash
# Avoid using 'sudo' with docker commands
sudo usermod -aG docker ubuntu

# Logout and login again for changes to take effect
```

### Docker Compose Help
```bash
docker compose -h
```

---

## Kubectl Installation

Kubernetes command-line tool for managing clusters.

```bash
# 1. Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# 2. Validate binary
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

# 3. Check kubectl
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

# 4. Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# 5. Verify installation (client version)
kubectl version --client

# 6. Detailed version info
kubectl version --client --output=yaml

# 7. Check both server and client versions
kubectl version
```

---

## Terraform Installation

Infrastructure as Code tool for AWS.

```bash
# 1. Update and install dependencies
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

# 2. Add GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

# 3. Verify GPG key
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

# 4. Add terraform repository to apt
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# 5. Update and install terraform
sudo apt update
sudo apt-get install terraform

# 6. Verify installation
terraform -help plan

# 7. Setup bash autocomplete
touch ~/.bashrc
terraform -install-autocomplete
```

---

## Resize EC2 Volume

Expand your EC2 instance storage.

### Step 1: Check Current Disk Usage
```bash
df -h
lsblk
```

### Step 2: Increase Volume Size
- Go to AWS EC2 Console → Storage → Volumes
- Select your volume → Modify
- Increase size and monitor "Volume state"

### Step 3: Verify Volume Increase
```bash
lsblk
# xvda should show increased size, but xvda1 partition unchanged
```

### Step 4: Install cloud-guest-utils (if needed)
```bash
sudo apt install cloud-guest-utils
```

### Step 5: Grow the Partition
```bash
sudo growpart /dev/xvda 1
# Output: CHANGED: partition=1 start=2099200 old: size=14677983 end=16777182 new: size=31455199 end=33554398

# Verify
lsblk
# xvda1 should now show 15G (or your new size)
```

### Step 6: Update File System
```bash
# For ext4
sudo resize2fs /dev/xvda1

# Output:
# resize2fs 1.47.0 (5-Feb-2023)
# Filesystem at /dev/xvda1 is mounted on /; on-online resizing required
# old_desc_blocks = 1, new_desc_blocks = 2
# The filesystem on /dev/xvda1 is now 3931899 (4k) blocks long.

# Verify final size
df -h
lsblk
```

### Step 7: Verify Port Access
```bash
# Backend server should run on port 3001 or 8080
# Make sure Security Group allows port 22 (SSH) and your app port
curl http://3.87.86.145:8080
```

---

**Last Updated:** December 22, 2025
