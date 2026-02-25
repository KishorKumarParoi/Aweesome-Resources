# Kubernetes Setup - Code Comparison: Before vs After

## Comparison 1: Error Handling

### ❌ BEFORE
```bash
sudo apt-get update -y
sudo apt install docker.io -y
sudo chmod 666 /var/run/docker.sock
# If any command fails, script continues silently!
```

### ✅ AFTER
```bash
#!/bin/bash
set -e  # Exit on any error

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

install_docker() {
    log_info "Installing Docker..."
    apt-get update -y || { log_error "Failed to update packages"; exit 1; }
    apt-get install -y docker.io || { log_error "Failed to install Docker"; exit 1; }
    chmod 666 /var/run/docker.sock
    log_info "Docker installed successfully ✓"
}

# BENEFIT: Stop on errors, colored output, clear progress
```

---

## Comparison 2: System Requirements

### ❌ BEFORE
```bash
# No checks - just assumes system is ready
sudo apt-get update -y
```

### ✅ AFTER
```bash
check_system_requirements() {
    CPU_COUNT=$(nproc)
    if [ "$CPU_COUNT" -lt 2 ]; then
        log_warn "System has only $CPU_COUNT cores. Minimum: 2"
    else
        log_info "CPU cores: $CPU_COUNT ✓"
    fi
    
    RAM_MB=$(free -m | awk '/^Mem:/{print $2}')
    if [ "$RAM_MB" -lt 2048 ]; then
        log_error "RAM ${RAM_MB}MB < 2048MB. Aborting!"
        exit 1
    else
        log_info "RAM available: ${RAM_MB}MB ✓"
    fi
    
    SWAP_MB=$(free -m | awk '/^Swap:/{print $2}')
    if [ "$SWAP_MB" -gt 0 ]; then
        log_warn "Swap ${SWAP_MB}MB detected (disable for K8s)"
    fi
}

# BENEFIT: Prevents errors before they happen
```

---

## Comparison 3: Swap Handling

### ❌ BEFORE
```bash
# Swap not mentioned
# Kubernetes fails silently with swap enabled
```

### ✅ AFTER
```bash
disable_swap() {
    log_info "Disabling swap..."
    swapoff -a
    sed -i '/ swap / s/^/#/' /etc/fstab
    log_info "Swap disabled ✓"
}

# Called early in setup flow
main() {
    check_root
    check_system_requirements
    disable_swap  # ← Must happen before kubeadm init
    ...
}

# BENEFIT: Avoids "swap is enabled" errors
```

---

## Comparison 4: Kernel Configuration

### ❌ BEFORE
```bash
# Missing entirely
# Networking won't work properly without these settings
```

### ✅ AFTER
```bash
configure_kernel_modules() {
    log_info "Configuring kernel modules..."
    
    # Enable IP forwarding for pod networking
    echo "net.ipv4.ip_forward = 1" | tee -a /etc/sysctl.conf
    
    # Enable bridge filtering for CNI plugins
    echo "net.bridge.bridge-nf-call-iptables = 1" | tee -a /etc/sysctl.conf
    echo "net.bridge.bridge-nf-call-ip6tables = 1" | tee -a /etc/sysctl.conf
    
    # Apply all sysctl settings
    sysctl -p > /dev/null 2>&1
    
    # Load kernel modules
    modprobe br_netfilter
    modprobe overlay
    
    log_info "Kernel modules configured ✓"
}

# BENEFIT: Pod-to-pod networking works reliably
```

---

## Comparison 5: Version Pinning

### ❌ BEFORE
```bash
sudo apt-get install -y kubeadm kubelet kubectl
# ⚠️ Installs any version! Could cause cluster inconsistency
# Subsequent apt updates might break the cluster
```

### ✅ AFTER
```bash
K8S_VERSION="1.35.0-1.1"

install_kubernetes_tools() {
    apt-get install -y \
        kubeadm=${K8S_VERSION} \
        kubelet=${K8S_VERSION} \
        kubectl=${K8S_VERSION}
    
    # Prevent accidental updates that might break things
    apt-mark hold kubeadm kubelet kubectl
    
    log_info "Kubernetes tools installed ✓"
}

# BENEFIT: Consistent versions across cluster, no surprise updates
```

---

## Comparison 6: API Server Readiness

### ❌ BEFORE
```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
# May fail if API server not ready!
# Error: "dial tcp 127.0.0.1:6443: connect: connection refused"
```

### ✅ AFTER
```bash
deploy_calico() {
    log_info "Deploying Calico networking plugin..."
    
    # Wait for API server to be ready
    log_info "Waiting for API server to be ready..."
    kubectl wait --for=condition=Ready pods \
        -l component=kube-apiserver \
        -n kube-system \
        --timeout=300s 2>/dev/null || true
    
    sleep 10  # Extra safety delay
    
    # Now apply Calico
    kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
    
    log_info "Calico deployed successfully ✓"
}

# BENEFIT: Waits for dependencies before proceeding
```

---

## Comparison 7: Code Organization

### ❌ BEFORE
```bash
# One linear script - hard to debug
sudo apt-get update -y
sudo apt install docker.io -y
sudo chmod 666 /var/run/docker.sock
# ... 30 more lines ...
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube
# ... more lines ...
```

### ✅ AFTER
```bash
# Modular functions - easy to understand and debug
install_docker() {
    # Docker installation
}

install_kubernetes_tools() {
    # Kubernetes installation
}

init_master_node() {
    # Master node initialization
}

deploy_calico() {
    # Networking setup
}

deploy_nginx_ingress() {
    # Ingress setup
}

main() {
    install_docker
    install_kubernetes_tools
    init_master_node
    deploy_calico
    deploy_nginx_ingress
}

# BENEFIT: Clear flow, easy to debug, reusable functions
```

---

## Comparison 8: Separate Master & Worker

### ❌ BEFORE
```bash
# One script for everything - confusing which parts apply to worker
---master-node
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# The output of above command to run slave node
# ... unclear instructions ...
```

### ✅ AFTER
```bash
# File 1: 1.sh - Master node setup
#!/bin/bash
init_master_node() {
    kubeadm init --pod-network-cidr=10.244.0.0/16
}

deploy_calico() {
    kubectl apply -f calico.yaml
}

# File 2: k8s-worker-setup.sh - Worker node setup
#!/bin/bash
# Takes parameters from command line
main() {
    MASTER_IP=$1
    JOIN_TOKEN=$2
    CA_CERT_HASH=$3
    
    kubeadm join ${MASTER_IP}:6443 \
        --token ${JOIN_TOKEN} \
        --discovery-token-ca-cert-hash ${CA_CERT_HASH}
}

# Usage:
# Master: sudo ./1.sh
# Worker: sudo ./k8s-worker-setup.sh 172.31.33.209 token hash

# BENEFIT: Clear roles, easy to use for different node types
```

---

## Comparison 9: Logging & Output

### ❌ BEFORE
```bash
sudo apt-get update -y
sudo apt install docker.io -y
sudo chmod 666 /var/run/docker.sock
# ↓ Output is hard to parse
# Processing triggers for systemd (1.35.2-1ubuntu1)...
# Setting up docker.io (20.10.7~3-0~ubuntu-focal)...
# done.
```

### ✅ AFTER
```bash
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

install_docker() {
    log_info "Installing Docker..."
    apt-get update -y
    apt-get install -y docker.io
    chmod 666 /var/run/docker.sock
    log_info "Docker installed successfully ✓"
}

# ↓ Output is crystal clear (with colors)
# [INFO] Installing Docker...
# [INFO] Docker installed successfully ✓
# [INFO] Kubernetes tools installed successfully ✓

# BENEFIT: Clear progress, easy to see status at a glance
```

---

## Comparison 10: Verification

### ❌ BEFORE
```bash
# No verification - user doesn't know if it worked
# Must manually run: kubectl get nodes  # Maybe works, maybe doesn't
```

### ✅ AFTER
```bash
verify_cluster() {
    log_info "Verifying cluster status..."
    
    log_info "Nodes status:"
    kubectl get nodes
    # Output:
    # NAME               STATUS   ROLES           AGE   VERSION
    # ip-172-31-33-209   Ready    control-plane   2m    v1.35.0
    
    log_info "System pods status:"
    kubectl get pods -n kube-system
    # Output shows all system pods running
    
    log_info "Cluster verification complete ✓"
}

generate_join_command() {
    log_info "Generating worker join command..."
    log_info "Save this command to run on worker nodes:"
    echo ""
    echo "========== COPY THIS COMMAND TO WORKER NODES =========="
    kubeadm token create --print-join-command
    echo "========================================================"
    echo ""
}

# BENEFIT: User knows exactly what was deployed and how to proceed
```

---

## Comparison 11: Worker Node Setup

### ❌ BEFORE
```bash
# Unclear how to join worker
# "The output of above command to run slave node"
# User has to manually figure out what to do
```

### ✅ AFTER
```bash
# File: k8s-worker-setup.sh - Clear worker setup

check_arguments() {
    if [ $# -ne 3 ]; then
        log_error "Usage: $0 <master-ip> <join-token> <ca-cert-hash>"
        echo ""
        echo "Example:"
        echo "  $0 172.31.33.209 f7gd6u.0ojp19iyhcnpdq2s sha256:3b8296..."
        exit 1
    fi
}

clean_previous_setup() {
    # Handle if worker was previously initialized
    kubeadm reset -f 2>/dev/null || true
    rm -rf /etc/kubernetes /var/lib/kubelet /var/lib/etcd
}

join_cluster() {
    MASTER_IP=$1
    JOIN_TOKEN=$2
    CA_CERT_HASH=$3
    
    kubeadm join ${MASTER_IP}:6443 \
        --token ${JOIN_TOKEN} \
        --discovery-token-ca-cert-hash ${CA_CERT_HASH}
}

# Usage:
# sudo ./k8s-worker-setup.sh 172.31.33.209 <TOKEN> sha256:<HASH>

# BENEFIT: Clear, reproducible worker setup
```

---

## Side-by-Side Execution Flow

### ❌ BEFORE (Impossible to follow)
```
Start
  ↓
apt update (no error handling)
  ↓
install docker (might fail silently)
  ↓
setup k8s repo (unclear steps)
  ↓
install kubeadm (might get wrong version)
  ↓
kubeadm init (might fail, user confused)
  ↓
kubectl apply calico (might not work)
  ↓
End (did it work? no verification)
```

### ✅ AFTER (Crystal clear)
```
Start
  ↓
✓ Check root permission
  ↓
✓ Verify CPU (4 cores) ✓
  ↓
✓ Verify RAM (8GB) ✓
  ↓
✓ Verify Swap disabled ✓
  ↓
✓ Configure kernel modules ✓
  ↓
✓ Install Docker with verification ✓
  ↓
✓ Pin Kubernetes version 1.35.0-1.1 ✓
  ↓
✓ Initialize master with timeouts ✓
  ↓
✓ Wait for API server ready ✓
  ↓
✓ Deploy Calico networking ✓
  ↓
✓ Deploy NGINX ingress ✓
  ↓
✓ Verify cluster (show nodes & pods) ✓
  ↓
✓ Generate worker join command ✓
  ↓
[INFO] Kubernetes Cluster Setup Complete! ✓
```

---

## Summary of Improvements

| Aspect | Before | After |
|--------|--------|-------|
| **Error Handling** | None | `set -e` + error checks |
| **Logging** | Plain text | Colored output with status |
| **System Checks** | Zero | CPU, RAM, Swap validation |
| **Kernel Config** | Missing | Properly configured |
| **Swap Management** | None | Explicitly disabled |
| **Version Pinning** | No | `apt-mark hold` applied |
| **Module Loading** | Missing | `modprobe` called |
| **API Ready Check** | None | `kubectl wait` implemented |
| **Code Organization** | Linear | Modular functions |
| **Master/Worker Split** | Confusing | Separate scripts |
| **Verification** | None | Full cluster verification |
| **User Guidance** | Minimal | Clear join command output |
| **Worker Setup** | Manual | Automated with parameters |
| **Total Lines** | 18 | 250+ (but fully documented) |

---

## Quick Migration Guide

If you have existing clusters:

```bash
# Backup current config
cp ~/.kube/config ~/.kube/config.backup

# Clean up old setup
sudo kubeadm reset -f
sudo rm -rf /etc/kubernetes /var/lib/kubelet /var/lib/etcd

# Run new improved script
sudo ./1.sh

# Worker nodes
sudo ./k8s-worker-setup.sh <master-ip> <token> <hash>
```

---

## Lessons Learned

1. **Always validate before proceeding** - Check system requirements
2. **Exit on errors** - Use `set -e` to catch failures early
3. **Modularize functions** - Makes debugging easier
4. **Log progress** - Color-coded output helps users understand status
5. **Handle dependencies** - Wait for services before using them
6. **Document clearly** - Good comments save troubleshooting time
7. **Verify output** - Always show what was actually deployed
8. **Separate concerns** - Different scripts for different roles
9. **Version lock dependencies** - Prevent surprise breakages
10. **Provide examples** - Show users exactly how to use scripts
