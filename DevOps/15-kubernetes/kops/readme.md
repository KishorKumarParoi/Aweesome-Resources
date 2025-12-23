# 🚀 Kubernetes Installation Using KOPS on AWS EC2

> Complete Guide to Setting Up Kubernetes Cluster with KOPS - Click sections to expand/collapse

---

## 📑 Table of Contents

<details>
<summary><b>📋 Prerequisites & Setup</b></summary>

### Prerequisites

- ✅ AWS account with billing enabled
- ✅ IAM user with appropriate permissions
- ✅ Local machine with: Python3, AWS CLI, kubectl, KOPS
- ✅ Text editor (vi, nano, VS Code)

---

### Install Dependencies in your EC2 / Local Machine

#### Update system
```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl apt-transport-https
```

#### Install kubectl
```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | \
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubectl
```

#### Install AWS CLI
```bash
sudo snap install aws-cli --classic
export PATH="$PATH:/home/ubuntu/.local/bin/"
```

#### Install KOPS
```bash
curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64

chmod +x kops-linux-amd64
sudo mv kops-linux-amd64 /usr/local/bin/kops
```

#### Verify Installations
```bash
kubectl version --client
aws --version
kops version
```

</details>

---

<details>
<summary><b>🔐 AWS IAM User Setup</b></summary>

### Why Separate IAM User?

⚠️ **IMPORTANT:** Never use AWS root account!
- Root account = full access to everything
- If credentials leak = entire AWS account compromised
- Use IAM user with minimal required permissions (Principle of Least Privilege)

---

### Step 1: Create IAM User in AWS Console

**Login to AWS Management Console:**
1. Go to https://console.aws.amazon.com
2. Search for "IAM" service
3. Click "Users" → "Create user"

**User Details:**
```
User name: kops-user

Options:
☑ Provide user access to AWS Management Console
  - Console password: Auto-generated
  - ☑ Users must create a new password at next sign-in
  
☑ Provide user access to the CLI, API, and other interfaces
  - Access key type: Access Key
```

---

### Step 2: Attach Required Permissions

**Search for and attach these policies:**

| Policy | Purpose |
|--------|---------|
| **AmazonEC2FullAccess** | Create/modify EC2 instances, security groups |
| **AmazonS3FullAccess** | Store/manage cluster state in S3 |
| **IAMFullAccess** | Create IAM roles for EC2 instances |
| **AmazonVPCFullAccess** | Create VPC, subnets, routing, gateways |
| (Optional) **AmazonRoute53FullAccess** | DNS management |

---

### Step 3: Get Access Keys

**After user creation:**

1. Click on newly created user (kops-user)
2. Go to "Security credentials" tab
3. Click "Create access key"
4. **IMPORTANT:** Download CSV file immediately

```
⚠️ SAVE THESE SAFELY:
├─ Access Key ID: AKIA...
├─ Secret Access Key: wJal...
└─ Never share or commit to Git!
```

---

### Step 4: Configure AWS CLI

```bash
aws configure

# Enter values:
AWS Access Key ID [None]: AKIA...
AWS Secret Access Key [None]: wJal...
Default region name [None]: us-east-1
Default output format [None]: json
```

**Verify credentials:**
```bash
aws sts get-caller-identity

# Expected output shows your user ARN (not root)
```

---

### Security Best Practices

✅ **DO:**
- Create separate IAM user for KOPS
- Rotate keys every 90 days
- Enable MFA on root account
- Monitor activity with CloudTrail
- Use least privilege permissions

❌ **DON'T:**
- Use AWS root account
- Share credentials
- Commit to Git
- Store in plain text

</details>

---

<details>
<summary><b>🗂️ AWS S3 & Environment Setup</b></summary>

### Step 1: Create S3 Bucket

```bash
# Create bucket
aws s3api create-bucket \
  --bucket kops-kkp-storage-1 \
  --region us-east-1

# Verify created
aws s3 ls
```

**What's S3 bucket for?**
- Stores KOPS cluster configuration
- Stores etcd backups
- Acts as source of truth for cluster state

---

### Step 2: Enable S3 Versioning

```bash
# Enable versioning (prevents accidental data loss)
aws s3api put-bucket-versioning \
  --bucket kops-kkp-storage-1 \
  --versioning-configuration Status=Enabled

# Verify it's enabled
aws s3api get-bucket-versioning \
  --bucket kops-kkp-storage-1

# Expected: "Status": "Enabled"
```

**Why versioning?**
- Recover from accidental deletions
- Keep historical configurations
- Safe for production clusters

---

### Step 3: Set Environment Variables

```bash
# Set for current session
export KOPS_STATE_STORE=s3://kops-kkp-storage-1
export KOPS_CLUSTER_NAME=demok8scluster1.k8s.local
export AWS_REGION=us-east-1
export AWS_ZONE=a
```

**Make persistent (add to ~/.bashrc or ~/.zshrc):**
```bash
echo 'export KOPS_STATE_STORE=s3://kops-kkp-storage-1' >> ~/.bashrc
echo 'export KOPS_CLUSTER_NAME=demok8scluster1.k8s.local' >> ~/.bashrc
echo 'export AWS_REGION=us-east-1' >> ~/.bashrc
echo 'export AWS_ZONE=a' >> ~/.bashrc

source ~/.bashrc
```

**Verify variables are set:**
```bash
echo $KOPS_STATE_STORE
echo $KOPS_CLUSTER_NAME
```

---

### Benefits of Environment Variables

```
Without:
  kops create cluster --name=demok8scluster1.k8s.local \
    --state=s3://kops-kkp-storage-1 ...
  (long & repetitive)

With:
  kops create cluster ...
  (clean & simple)
```

</details>

---

<details>
<summary><b>🌐 AWS Route53: Custom Domain (Optional)</b></summary>

> This section is **OPTIONAL** - You can skip if using default DNS

### Why Use Custom Domain?

```
Without custom domain:        With custom domain:
├─ Hard to remember IP        ├─ Easy domain name
├─ IP changes after redeploy   ├─ Domain stays same
├─ Not professional            ├─ Professional
└─ API: 10.0.1.10:6443        └─ API: api.kishordev.me:6443
```

---

### Step 1: Register Domain

**Option A:** Use existing domain
- Update nameservers to Route53
- Takes 24-48 hours

**Option B:** Register via Route53
- ~$10-15/year
- Instant setup

**Option C:** Use subdomain
- Create k8s.example.com
- Update parent domain nameservers

---

### Step 2: Create Route53 Hosted Zone

```bash
# Create hosted zone
aws route53 create-hosted-zone \
  --name kishordev.me \
  --caller-reference $(date +%s)

# Expected output includes:
# "Id": "/hostedzone/Z1234567890ABC"
# "NameServers": ["ns-123.awsdns-45.com", ...]
```

**Save the Hosted Zone ID** (you'll need it later)

---

### Step 3: Update Nameservers (if domain elsewhere)

1. Login to your domain registrar (GoDaddy, Namecheap, etc.)
2. Find "Nameservers" or "DNS Settings"
3. Replace with Route53 nameservers from Step 2
4. Save changes
5. Wait 24-48 hours for propagation

---

### Step 4: Create DNS A Record

```bash
# After cluster is running, get control-plane IP
CONTROL_PLANE_IP=$(aws ec2 describe-instances \
  --region us-east-1 \
  --filters "Name=tag:kops.k8s.io/instancegroup,Values=control-plane-us-east-1a" \
  --query 'Reservations[*].Instances[0].PublicIpAddress' \
  --output text)

# Create DNS record
aws route53 change-resource-record-sets \
  --hosted-zone-id Z1234567890ABC \
  --change-batch '{
    "Changes": [{
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "api.kishordev.me",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [{"Value": "'$CONTROL_PLANE_IP'"}]
      }
    }]
  }'

# Verify DNS
nslookup api.kishordev.me
```

---

### Step 5: Update KOPS Cluster Config

```bash
kops edit cluster

# In editor, find:
# spec:
#   masterPublicName: api.demok8scluster1.k8s.local
#
# Change to:
# spec:
#   masterPublicName: api.kishordev.me

# Save & exit (:wq)

# Apply changes
kops update cluster --yes
```

---

### Troubleshooting DNS

```bash
# Check nameservers updated
nslookup kishordev.me

# Check DNS record
aws route53 list-resource-record-sets \
  --hosted-zone-id Z1234567890ABC

# Test resolution
nslookup api.kishordev.me 8.8.8.8

# Clear DNS cache (if needed)
# Linux: sudo systemctl restart systemd-resolved
# Mac: sudo dscacheutil -flushcache
# Windows: ipconfig /flushdns
```

</details>

---

<details>
<summary><b>⚙️ Create Kubernetes Cluster Configuration</b></summary>

### Step 1: Create Cluster Config

```bash
# Full command with all parameters
kops create cluster \
  --name=${KOPS_CLUSTER_NAME} \
  --state=${KOPS_STATE_STORE} \
  --zones=${AWS_REGION}${AWS_ZONE} \
  --node-count=1 \
  --node-size=t2.micro \
  --control-plane-size=t2.micro \
  --control-plane-volume-size=8 \
  --node-volume-size=8
```

**Parameter Explanations:**

| Parameter | Value | Meaning |
|-----------|-------|---------|
| `--name` | demok8scluster1.k8s.local | Cluster identifier |
| `--state` | s3://kops-kkp-storage-1 | Where to store config |
| `--zones` | us-east-1a | AWS region & availability zone |
| `--node-count` | 1 | Number of worker nodes |
| `--node-size` | t2.micro | Worker instance type |
| `--control-plane-size` | t2.micro | Master instance type |
| `--control-plane-volume-size` | 8 | Master disk size (GB) |
| `--node-volume-size` | 8 | Worker disk size (GB) |

---

### What Gets Generated?

✅ **Configuration Created (117 AWS resources):**
- 2 EC2 Launch Templates (control-plane + nodes)
- 2 Auto Scaling Groups
- 3 Security Groups
- 2 IAM Roles + Profiles
- 1 Network Load Balancer
- 2 Target Groups
- 2 EBS Volumes (40GB total)
- VPC + Subnets
- 8 Keypairs (certificates)
- 9 Secrets
- Kubernetes manifests

❌ **NOT Created Yet:**
- Actual EC2 instances
- Real AWS resources
- Running Kubernetes

**Why?** To let you review before deployment

---

### Expected Output

```bash
I1222 22:12:57.183217    2433 executor.go:113] Tasks: 43 done / 117 total
I1222 22:12:57.271139    2433 executor.go:113] Tasks: 65 done / 117 total
...
I1222 22:12:58.788541    2433 executor.go:113] Tasks: 117 done / 117 total; 0 can run

Will create resources:
  AutoscalingGroup/control-plane-us-east-1a...
  AutoscalingGroup/nodes-us-east-1a...
  SecurityGroup/api-elb...
  SecurityGroup/masters...
  SecurityGroup/nodes...
  ... (117 total resources)

Cluster configuration has been created.

Must specify --yes to apply changes
```

---

### Next Step

```bash
# Review configuration (optional)
kops edit cluster

# Then proceed to build cluster
kops update cluster --yes
```

</details>

---

<details>
<summary><b>🔍 Review Cluster Configuration</b></summary>

### Open Configuration Editor

```bash
kops edit cluster --state=${KOPS_STATE_STORE}
```

This opens your cluster spec in YAML format

---

### Key Configuration Sections

#### 1. Networking
```yaml
spec:
  networkCIDR: 172.20.0.0/16          # VPC network range
  serviceClusterIPRange: 100.64.0.0/13 # Service IP range
```

#### 2. ETCD (Database)
```yaml
  etcd:
    - name: main
      encryptionConfig: true           # Encrypt at rest
      volumes:
        - size: 20                     # 20 GB
          type: gp3                    # Fast SSD
          iops: 3000                   # Performance
```

#### 3. API Server
```yaml
  kubeAPIServer:
    anonymousAuth: false               # Require authentication
    tlsMinVersion: VersionTLS12        # Strong encryption
```

#### 4. Kubelet (Node Agent)
```yaml
  kubelet:
    maxPods: 110                       # Max pods per node
    readOnlyPort: 0                    # Disable insecure port
```

---

### Common Modifications

**Increase max pods per node:**
```yaml
kubelet:
  maxPods: 300  # From default 110
```

**Enable network policies:**
```yaml
networking:
  cilium:
    enableNetworkPolicy: true
```

**Change log level:**
```yaml
kubeAPIServer:
  logLevel: debug  # From info
```

---

### Save & Exit

- **Vi/Vim:** `:wq` (colon, w, q, enter)
- **Nano:** `Ctrl+X`, `Y`, `Enter`
- **VS Code:** `Ctrl+S`, close editor

**Note:** Changes take effect after `kops update cluster --yes`

</details>

---

<details>
<summary><b>🔨 Build Kubernetes Cluster</b></summary>

### Step 1: Apply Configuration to AWS

```bash
kops update cluster \
  --name=${KOPS_CLUSTER_NAME} \
  --state=${KOPS_STATE_STORE} \
  --yes
```

**What `--yes` does:**
- Actually creates AWS resources
- Launches EC2 instances
- Installs Kubernetes components
- Cannot be undone easily!

---

### Timeline (5-15 minutes)

```
T+0s:    Command starts
T+1m:    AWS resources creating
T+3m:    EC2 instances launching
T+5m:    cloud-init running (installing Kubernetes)
T+8m:    Control-plane initializing
T+10m:   Worker nodes joining
T+15m:   All nodes ready!
```

---

### Monitor Progress (In Another Terminal)

**Check node status:**
```bash
watch 'aws ec2 describe-instances \
  --region us-east-1 \
  --query "Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType]" \
  --output table'

# Should show instances transitioning from "pending" to "running"
```

**Check load balancers:**
```bash
aws elbv2 describe-load-balancers \
  --region us-east-1 \
  --query 'LoadBalancers[*].[LoadBalancerName,State.Code]' \
  --output table

# Should show "provisioning" then "active"
```

---

### Expected Output

```
I1222 22:15:00.123456    2433 executor.go:113] Tasks: 0 done / 117 total
...
I1222 22:15:45.654321    2433 executor.go:113] Tasks: 117 done / 117 total

Cluster is starting...
  Control plane: i-042bb92634374fbc0 (pending)
  Node: i-02c9c037ac833510f (pending)

Waiting for cluster to become ready...
```

---

### AWS Resources Created

```
VPC (10.0.0.0/16)
├─ Subnet (10.0.1.0/24)
│  ├─ Security Group (firewall rules)
│  ├─ Network Load Balancer
│  └─ Auto Scaling Groups
│     ├─ Control-Plane ASG
│     │  └─ EC2 Instance i-042bb... (t2.micro)
│     │     ├─ 8GB EBS Volume
│     │     ├─ IP: 10.0.1.10
│     │     └─ Running: etcd, API Server, Controller Manager, Scheduler
│     └─ Nodes ASG
│        └─ EC2 Instance i-02c9... (t2.micro)
│           ├─ 8GB EBS Volume
│           ├─ IP: 10.0.1.20
│           └─ Running: kubelet, kube-proxy, Docker
└─ Internet Gateway
   └─ Routes traffic to/from internet

S3 Bucket (kops-kkp-storage-1)
└─ Stores cluster state & configs
```

</details>

---

<details>
<summary><b>✅ Validate Cluster</b></summary>

### Step 1: Check Cluster Health

```bash
kops validate cluster \
  --name=${KOPS_CLUSTER_NAME} \
  --state=${KOPS_STATE_STORE}
```

**Expected Output (when ready):**
```
Using cluster from /home/ubuntu/.kube/config
Validating cluster demok8scluster1.k8s.local

INSTANCE GROUPS
NAME                    ROLE           MACHINETYPE MIN MAX SUBNETS
control-plane-us-east-1a Master         t2.micro    1   1   us-east-1a
nodes-us-east-1a        Node           t2.micro    1   1   us-east-1a

NODE STATUS
NAME                      ROLE           READY
i-042bb92634374fbc0       master         True
i-02c9c037ac833510f       node           True

Your cluster demok8scluster1.k8s.local is ready ✅
```

---

### What Gets Validated?

✅ **Checks:**
- Control-plane node status
- Worker nodes status  
- API server responding
- Kubelet running on each node
- etcd database healthy
- All system pods running
- Inter-node networking
- DNS resolution

---

### If Not Ready Yet

⏳ **Common reasons:**
- Cloud-init still running (installing Kubernetes)
- Nodes not finished joining cluster
- System pods still starting

**Solution:** Wait 2-5 more minutes and retry

```bash
# Keep retrying until cluster is ready
watch 'kops validate cluster --state=s3://kops-kkp-storage-1'

# Press Ctrl+C to stop watching
```

</details>

---

<details>
<summary><b>🎯 Access Your Cluster</b></summary>

### Step 1: Get Cluster Information

```bash
kubectl cluster-info

# Expected output:
# Kubernetes control plane is running at https://api.demok8scluster1.k8s.local:6443
# CoreDNS is running at https://api.demok8scluster1.k8s.local:6443/api/v1/...
```

---

### Step 2: List All Nodes

```bash
kubectl get nodes

# Expected output:
# NAME                    STATUS   ROLES           AGE   VERSION
# i-042bb92634374fbc0     Ready    control-plane   10m   v1.28.x
# i-02c9c037ac833510f     Ready    <none>          9m    v1.28.x
```

---

### Step 3: List All System Pods

```bash
kubectl get pods -A

# Expected output shows:
# - CoreDNS (DNS service)
# - kube-proxy (networking)
# - etcd (database)
# - API server, Controller Manager, Scheduler
# - Node Termination Handler
# - AWS cloud controller
```

---

### Step 4: Check System Components

```bash
# Check control plane components
kubectl get pods -n kube-system

# Check API server logs
kubectl logs -n kube-system -l component=kube-apiserver

# Check kubelet status
kubectl get nodes -o wide
```

---

### Common kubectl Commands

```bash
# Get resources
kubectl get pods
kubectl get nodes
kubectl get services
kubectl get deployments

# Describe resources
kubectl describe node <node-name>
kubectl describe pod <pod-name>

# View logs
kubectl logs <pod-name>
kubectl logs <pod-name> -f  # Follow logs

# Create/Apply configs
kubectl apply -f deployment.yml
kubectl create deployment nginx --image=nginx

# Delete resources
kubectl delete pod <pod-name>
kubectl delete deployment <deployment-name>

# Get detailed info
kubectl cluster-info
kubectl version
kubectl get events
```

---

### Your Cluster is Ready! 🎉

You can now:
- ✅ Deploy Docker containers
- ✅ Create services
- ✅ Scale applications
- ✅ Update with zero downtime
- ✅ Monitor pods and nodes

</details>

---

<details>
<summary><b>🗑️ Delete Cluster (Cleanup)</b></summary>

### ⚠️ IMPORTANT WARNINGS

**Before deleting:**
- ❌ All data will be LOST
- ❌ All running applications will STOP
- ❌ Cannot be easily undone
- ⏳ Takes 5-10 minutes

---

### Step 1: Delete Cluster

```bash
kops delete cluster \
  --name=${KOPS_CLUSTER_NAME} \
  --state=${KOPS_STATE_STORE} \
  --yes
```

**What gets deleted:**
- ✓ EC2 instances
- ✓ VPC, subnets, security groups
- ✓ Load balancers
- ✓ EBS volumes
- ✓ IAM roles (created by KOPS)
- ✗ S3 bucket (preserved for recovery)
- ✗ IAM user (preserve for future use)

---

### Step 2: Verify Deletion

```bash
# Check instances are gone
aws ec2 describe-instances \
  --region us-east-1 \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name]' \
  --output table

# Should show no instances (or only non-KOPS instances)

# Check load balancers are gone
aws elbv2 describe-load-balancers --region us-east-1
```

---

### Step 3: Clean Up S3 (Optional)

```bash
# List S3 contents
aws s3 ls s3://kops-kkp-storage-1/

# Delete cluster config (optional - for recovery keep it)
aws s3 rm s3://kops-kkp-storage-1/demok8scluster1.k8s.local --recursive

# Delete entire bucket (only if completely done)
aws s3 rb s3://kops-kkp-storage-1 --force
```

---

### Deletion Timeline

```
T+0:    Deletion starts
T+1m:   Instances terminating
T+3m:   Load balancers deleted
T+5m:   VPC being deleted
T+10m:  Cluster completely gone ✓
```

---

### Keep These for Next Cluster

```bash
✅ Save for next deployment:
├─ AWS IAM user (kops-user) - can reuse
├─ AWS Access Keys - can reuse
├─ AWS region preference - can reuse
└─ This README.md - can reuse

❌ Delete after cluster deletion:
├─ kubeconfig file (~/.kube/config)
├─ Cluster-specific configs
└─ SSL certificates (auto-generated)
```

</details>

---

<details>
<summary><b>📚 Understanding What Was Created</b></summary>

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     AWS Cloud (us-east-1)                  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │            VPC (172.20.0.0/16)                      │   │
│  │                                                      │   │
│  │  ┌────────────────────────────────────────────────┐ │   │
│  │  │  Subnet (172.20.0.0/16) - us-east-1a          │ │   │
│  │  │                                                │ │   │
│  │  │  ┌──────────────────┐  ┌──────────────────┐  │ │   │
│  │  │  │   Control-Plane  │  │  Worker Node     │  │ │   │
│  │  │  │  (i-042bb...)    │  │  (i-02c9...)     │  │ │   │
│  │  │  │  t2.micro        │  │  t2.micro        │  │ │   │
│  │  │  │  IP: 10.0.1.10   │  │  IP: 10.0.1.20   │  │ │   │
│  │  │  │                  │  │                  │  │ │   │
│  │  │  │  ✓ etcd          │  │  ✓ kubelet       │  │ │   │
│  │  │  │  ✓ API Server    │  │  ✓ kube-proxy    │  │ │   │
│  │  │  │  ✓ Controller    │  │  ✓ Docker        │  │ │   │
│  │  │  │  ✓ Scheduler     │  │                  │  │ │   │
│  │  │  │                  │  │                  │  │ │   │
│  │  │  └──────────────────┘  └──────────────────┘  │ │   │
│  │  │         ▲                        ▲            │ │   │
│  │  │         └────────────┬───────────┘            │ │   │
│  │  │                      │                       │ │   │
│  │  │              Network Overlay                 │ │   │
│  │  │            (Cilium - CNI Plugin)             │ │   │
│  │  │                                              │ │   │
│  │  │  ┌──────────────────────────────────────┐  │ │   │
│  │  │  │   Network Load Balancer (NLB)       │  │ │   │
│  │  │  │   - Port 443 → API Server           │  │ │   │
│  │  │  │   - Port 3988 → KOPS Controller    │  │ │   │
│  │  │  └──────────────────────────────────────┘  │ │   │
│  │  │                                              │ │   │
│  │  └────────────────────────────────────────────┘ │   │
│  │         ▲                                        │   │
│  │         │                                        │   │
│  │  ┌──────┴──────┐                                │   │
│  │  │ Internet    │                                │   │
│  │  │ Gateway     │                                │   │
│  │  └─────────────┘                                │   │
│  │                                                  │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  S3 Bucket (kops-kkp-storage-1)                 │   │
│  │  - Cluster configuration                        │   │
│  │  - Kubernetes manifests                         │   │
│  │  - etcd backups                                 │   │
│  │  - SSH keys                                     │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
└─────────────────────────────────────────────────────────┘
                         ▲
                         │
                    kubectl commands
                    from your laptop
```

---

### Component Breakdown

#### **1. EC2 Instances (Nodes)**

**Control-Plane (Master) Node:**
```
i-042bb92634374fbc0
├─ Role: Cluster management
├─ Runs:
│  ├─ etcd (distributed database)
│  │  └─ Stores cluster state
│  ├─ API Server
│  │  └─ Central hub - all commands go here
│  ├─ Controller Manager
│  │  └─ Auto-restarts crashed pods
│  ├─ Scheduler
│  │  └─ Assigns pods to nodes
│  ├─ Kubelet (node agent)
│  └─ kube-proxy (networking)
└─ Cannot run user applications
```

**Worker Node:**
```
i-02c9c037ac833510f
├─ Role: Run user applications
├─ Runs:
│  ├─ Kubelet (receives pods from control-plane)
│  ├─ kube-proxy (networking)
│  ├─ Docker (container runtime)
│  └─ User pods/containers
└─ No cluster management services
```

---

#### **2. Storage**

**EBS Volumes:**
```
a.etcd-main (20 GB)
├─ Encrypted: true
├─ Performance: 3000 IOPS
├─ Stores: Kubernetes cluster state
└─ Backed up automatically

a.etcd-events (20 GB)
├─ Encrypted: true
├─ Performance: 3000 IOPS
├─ Stores: Event logs
└─ Backed up automatically
```

---

#### **3. Networking**

**Security Groups (Firewalls):**
```
api-elb security group
├─ Inbound: 0.0.0.0/0 → TCP 443 (public)
└─ Outbound: Allow all

masters security group
├─ Inbound: TCP 443 (API)
├─ Inbound: TCP 2379-2380 (etcd)
├─ Inbound: TCP 10250 (kubelet)
└─ Inbound from nodes: All traffic

nodes security group
├─ Inbound: TCP 10250 (kubelet)
├─ Inbound from masters: All traffic
├─ Inbound from nodes: All traffic
└─ Inbound: TCP 22 (SSH)
```

---

#### **4. Load Balancing**

**Network Load Balancer:**
```
api.demok8scluster1.k8s.local
├─ Type: NLB (high performance, layer 4)
├─ Listener 1:
│  ├─ Port: 443
│  ├─ Target: API Server on control-plane
│  └─ Health check: TCP 443 every 10s
├─ Listener 2:
│  ├─ Port: 3988
│  ├─ Target: KOPS Controller
│  └─ Health check: TCP 3988 every 10s
└─ Cross-zone: Enabled (distributes across AZs)
```

---

#### **5. Auto Scaling**

**Control-Plane ASG:**
```
control-plane-us-east-1a.masters.demok8scluster1.k8s.local
├─ Desired capacity: 1
├─ Min size: 1
├─ Max size: 1
├─ Always exactly 1 control-plane node
└─ Lifecycle hook: Graceful termination
```

**Nodes ASG:**
```
nodes-us-east-1a.demok8scluster1.k8s.local
├─ Desired capacity: 1
├─ Min size: 1
├─ Max size: 1
├─ Can be scaled up: `kops edit ig nodes-us-east-1a`
└─ Lifecycle hook: Drain pods before termination
```

---

#### **6. IAM Roles & Policies**

**Masters Role:**
- EC2 full access (manage instances)
- S3 access (read/write cluster state)
- EBS access (manage volumes)
- CloudFormation access
- AutoScaling access

**Nodes Role:**
- EC2 read access
- S3 read access
- EBS read access
- CloudWatch write access (logging)

</details>

---

<details>
<summary><b>❓ Troubleshooting & FAQ</b></summary>

### Common Issues & Solutions

#### **Issue: AWS credentials not found**

```bash
# Error:
# Unable to locate credentials

# Solution:
aws configure

# Or check credentials file exists:
cat ~/.aws/credentials

# Or set environment variables:
export AWS_ACCESS_KEY_ID=AKIA...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=us-east-1
```

---

#### **Issue: Permission denied**

```bash
# Error:
# User is not authorized to perform: ec2:RunInstances

# Solution:
# User doesn't have required IAM permissions
1. Login as root user to AWS Console
2. Go to IAM → Users → kops-user
3. Attach missing policy
4. Wait 1-2 minutes for permissions to propagate
5. Retry the command
```

---

#### **Issue: Cluster not ready after 15 minutes**

```bash
# Check what's not ready:
kops validate cluster

# Monitor instances:
watch 'aws ec2 describe-instances --region us-east-1'

# Check system pods:
kubectl get pods -n kube-system

# Check logs:
kubectl logs -n kube-system -l component=kubelet

# Common reasons:
# - Cloud-init still installing (wait 5 more minutes)
# - Insufficient permissions
# - Instance type too small
```

---

#### **Issue: Cannot connect to API server**

```bash
# Error:
# The server is unreachable

# Solution:
# 1. Check API server is running
kubectl get nodes

# 2. Check kubeconfig
cat ~/.kube/config

# 3. Check security group allows TCP 443
aws ec2 describe-security-groups \
  --query 'SecurityGroups[*].[GroupName,IpPermissions[0].FromPort]'

# 4. Check load balancer is healthy
aws elbv2 describe-target-health \
  --target-group-arn arn:aws:...
```

---

#### **Issue: Nodes not joining cluster**

```bash
# Check instance logs:
INSTANCE_ID=i-02c9c037ac833510f
aws ec2 get-console-output --instance-id $INSTANCE_ID

# Check system logs:
aws ec2 describe-console-output \
  --instance-id $INSTANCE_ID

# Common reasons:
# - Security group blocking traffic
# - Cloud-init failed
# - Insufficient disk space
```

---

### Frequently Asked Questions

**Q: Can I add more worker nodes?**
```bash
# Edit instance group
kops edit ig nodes-us-east-1a

# Change: maxSize: 5 (was 1)
# Change: desiredCapacity: 3 (was 1)

# Apply:
kops update cluster --yes
```

**Q: Can I change instance types?**
```bash
# Edit instance group
kops edit ig nodes-us-east-1a

# Change: machineType: t2.small (was t2.micro)

# Apply (will replace instances):
kops update cluster --yes
```

**Q: How do I update Kubernetes version?**
```bash
# Edit cluster
kops edit cluster

# Change: kubernetesVersion: 1.29.0

# Apply:
kops update cluster --yes

# Rolling update - no downtime!
```

**Q: How do I SSH into nodes?**
```bash
# Get node IP
kubectl get nodes -o wide

# SSH in
ssh -i ~/.ssh/kube_aws_rsa ubuntu@10.0.1.10
```

**Q: Can I run this cluster for free?**
```
Yes, with limitations:
✅ t2.micro: 750 hours/month free (AWS free tier)
✅ EBS storage: 30 GB/month free
❌ Load balancer: ~$20/month
❌ Data transfer: Minimal cost

Total: ~$20/month (or free with free tier)
```

</details>

---

<details>
<summary><b>📖 Learning Resources</b></summary>

### Official Documentation

- [KOPS Official Docs](https://kops.sigs.k8s.io/)
- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [AWS KOPS Guide](https://kops.sigs.k8s.io/getting_started/aws/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

### AWS Services Used

- [EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [S3 Documentation](https://docs.aws.amazon.com/s3/)
- [VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [IAM Documentation](https://docs.aws.amazon.com/iam/)
- [ELB Documentation](https://docs.aws.amazon.com/elasticloadbalancing/)
- [Route53 Documentation](https://docs.aws.amazon.com/route53/)

### Kubernetes Concepts

- [Pods](https://kubernetes.io/docs/concepts/workloads/pods/) - Smallest deployable units
- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) - Manage pod replicas
- [Services](https://kubernetes.io/docs/concepts/services-networking/service/) - Expose pods to network
- [Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) - Organize resources
- [ConfigMaps & Secrets](https://kubernetes.io/docs/concepts/configuration/) - Store configuration

### Next Steps After Setup

1. **Deploy Your First App**
   ```bash
   kubectl create deployment nginx --image=nginx
   kubectl expose deployment nginx --port=80 --type=LoadBalancer
   kubectl get svc
   ```

2. **Install a Package Manager (Helm)**
   ```bash
   curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
   helm repo add stable https://charts.helm.sh/stable
   ```

3. **Monitor Your Cluster**
   ```bash
   kubectl top nodes
   kubectl top pods -A
   ```

4. **Backup Your Cluster**
   ```bash
   kops export kubecfg --admin
   kubectl get all --all-namespaces -o yaml > backup.yaml
   ```

</details>

---

<details>
<summary><b>✨ Quick Command Reference</b></summary>

### KOPS Commands

```bash
# Cluster Management
kops create cluster --name=... --state=...
kops update cluster --yes
kops validate cluster
kops delete cluster --yes
kops get cluster
kops describe cluster

# Edit Configurations
kops edit cluster
kops edit ig control-plane-us-east-1a
kops edit ig nodes-us-east-1a

# Export kubeconfig
kops export kubecfg --admin
```

### Kubectl Commands

```bash
# Get Resources
kubectl get nodes
kubectl get pods -A
kubectl get services
kubectl get deployments

# Describe Resources
kubectl describe node <name>
kubectl describe pod <name>

# Logs
kubectl logs <pod-name>
kubectl logs -f <pod-name>  # Follow

# Create/Apply
kubectl apply -f deployment.yml
kubectl create deployment nginx --image=nginx

# Delete
kubectl delete pod <name>
kubectl delete deployment <name>

# Scaling
kubectl scale deployment nginx --replicas=5

# Execute Command
kubectl exec -it <pod-name> -- /bin/bash
```

### AWS CLI Commands

```bash
# EC2
aws ec2 describe-instances --region us-east-1
aws ec2 describe-security-groups --region us-east-1

# Load Balancers
aws elbv2 describe-load-balancers --region us-east-1

# S3
aws s3 ls s3://kops-kkp-storage-1/
aws s3api get-object-tagging --bucket kops-kkp-storage-1 --key cluster.yaml

# IAM
aws iam list-users
aws iam list-roles
```

</details>

---

## 🎯 Quick Start Summary

```
1️⃣  SETUP (15 minutes)
    └─ Create IAM user + AWS credentials
    └─ Install kubectl, AWS CLI, KOPS
    └─ Create S3 bucket
    └─ Set environment variables

2️⃣  CREATE (5 minutes)
    └─ kops create cluster ...
    └─ Review configuration (optional)

3️⃣  BUILD (15 minutes)
    └─ kops update cluster --yes
    └─ Monitor progress

4️⃣  VALIDATE (5 minutes)
    └─ kops validate cluster
    └─ kubectl cluster-info

5️⃣  USE (Ongoing)
    └─ Deploy applications
    └─ Manage pods & services
    └─ Scale & update
```

---

## 📞 Support & Help

If you encounter issues:

1. ✅ Check the **Troubleshooting & FAQ** section
2. ✅ Review [KOPS GitHub Issues](https://github.com/kubernetes/kops/issues)
3. ✅ Check [Kubernetes Community](https://kubernetes.io/community/)
4. ✅ Ask on [Stack Overflow](https://stackoverflow.com/questions/tagged/kubernetes)
5. ✅ Mail me - kishor.ruet.cse@gmail.com
---

**Last Updated:** December 23, 2025  
**KOPS Version:** Latest (1.28+)  
**Kubernetes Version:** 1.28+  
**AWS Region:** us-east-1  

---

# ✨ Congratulations! 🎉

You now have a production-grade Kubernetes cluster running on AWS EC2!

**What you've accomplished:**
- ✅ Created IAM user for secure AWS access
- ✅ Set up S3 bucket for cluster state management
- ✅ Generated Kubernetes cluster configuration
- ✅ Deployed 2-node Kubernetes cluster
- ✅ Validated cluster health
- ✅ Learned kubectl commands

##### Never forget to delete the cluster while keeping S3 bucket versioning enabled, enjoy afterwards.

**Next adventure:** Deploy your applications to Kubernetes!

```bash
# Deploy an example app
kubectl create deployment hello-world --image=gcr.io/google-samples/hello-app:1.0
kubectl expose deployment hello-world --port=8080 --type=LoadBalancer
kubectl get svc
# Copy the EXTERNAL-IP and visit it in your browser!
```

Happy Kubernetes journey! 🚀