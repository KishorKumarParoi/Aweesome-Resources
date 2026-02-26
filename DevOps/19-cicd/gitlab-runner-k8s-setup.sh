#!/bin/bash

# GitLab Runner Kubernetes Deployment Setup Script
# This script deploys GitLab Runner on your Kubernetes cluster
# Prerequisites: kubectl configured, Helm installed, GitLab account setup

set -e

echo "=========================================="
echo "GitLab Runner Kubernetes Deployment Setup"
echo "=========================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration variables - MODIFY THESE
GITLAB_URL="${GITLAB_URL:-https://gitlab.com}"
GITLAB_RUNNER_TOKEN="${GITLAB_RUNNER_TOKEN:-your-runner-token-here}"
RUNNER_NAMESPACE="gitlab-runner"
RUNNER_RELEASE_NAME="gitlab-runner"
RUNNER_NAME="k8s-runner-$(hostname)"

echo -e "${YELLOW}Configuration:${NC}"
echo "GitLab URL: $GITLAB_URL"
echo "Runner Namespace: $RUNNER_NAMESPACE"
echo "Runner Release Name: $RUNNER_RELEASE_NAME"
echo "Runner Name: $RUNNER_NAME"
echo ""

# Step 1: Check prerequisites
echo -e "${YELLOW}Step 1: Checking prerequisites...${NC}"
command -v kubectl &> /dev/null || { echo -e "${RED}kubectl not found${NC}"; exit 1; }
command -v helm &> /dev/null || { echo -e "${RED}Helm not found${NC}"; exit 1; }
echo -e "${GREEN}✓ kubectl and helm found${NC}"

# Step 2: Verify Kubernetes cluster connectivity
echo -e "${YELLOW}Step 2: Verifying Kubernetes cluster...${NC}"
kubectl cluster-info
kubectl get nodes
echo -e "${GREEN}✓ Kubernetes cluster is accessible${NC}"

# Step 3: Create namespace for GitLab Runner
echo -e "${YELLOW}Step 3: Creating namespace...${NC}"
kubectl create namespace $RUNNER_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
echo -e "${GREEN}✓ Namespace '$RUNNER_NAMESPACE' created/verified${NC}"

# Step 4: Create service account for GitLab Runner
echo -e "${YELLOW}Step 4: Creating service account...${NC}"
kubectl create serviceaccount gitlab-runner-sa -n $RUNNER_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
kubectl create clusterrolebinding gitlab-runner-crb \
  --clusterrole=cluster-admin \
  --serviceaccount=$RUNNER_NAMESPACE:gitlab-runner-sa \
  --dry-run=client -o yaml | kubectl apply -f -
echo -e "${GREEN}✓ Service account and cluster role binding created${NC}"

# Step 5: Add GitLab Helm Repository
echo -e "${YELLOW}Step 5: Adding GitLab Helm repository...${NC}"
helm repo add gitlab https://charts.gitlab.io
helm repo update
echo -e "${GREEN}✓ GitLab Helm repository added${NC}"

# Step 6: Create values file for Helm
echo -e "${YELLOW}Step 6: Creating Helm values configuration...${NC}"
cat > /tmp/gitlab-runner-values.yaml <<EOF
gitlabUrl: $GITLAB_URL
gitlabToken: $GITLAB_RUNNER_TOKEN

runners:
  image: ubuntu:22.04
  tags: "kubernetes,docker,linux"
  runUntaggedJobs: true
  
  # Resource limits and requests for runner pods
  resources:
    limits:
      cpu: 2
      memory: 4Gi
    requests:
      cpu: 1
      memory: 2Gi

  # Privileged mode for Docker-in-Docker
  privileged: true

  # Service account to use
  serviceAccountName: gitlab-runner-sa

# Cache configuration
gitlabRunner:
  cache:
    type: s3
    s3ServerAddress: https://s3.amazonaws.com
    s3BucketName: my-gitlab-runner-cache
    s3BucketLocation: us-east-1
    shared: true

# Replica count
replicas: 2

# Pod security context
podSecurityContext:
  runAsUser: 100
  runAsGroup: 100
  fsGroup: 100

# Resource management
resources:
  limits:
    cpu: 1
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi

# Node affinity (optional - to run on specific nodes)
affinity: {}
# nodeSelector:
#   node-role.kubernetes.io/worker: ""

# Tolerations (optional - for node taints)
tolerations: []
EOF

echo -e "${GREEN}✓ Helm values configuration created${NC}"

# Step 7: Deploy GitLab Runner using Helm
echo -e "${YELLOW}Step 7: Installing GitLab Runner with Helm...${NC}"
helm install $RUNNER_RELEASE_NAME gitlab/gitlab-runner \
  --namespace $RUNNER_NAMESPACE \
  -f /tmp/gitlab-runner-values.yaml \
  --set gitlabUrl=$GITLAB_URL \
  --set gitlabToken=$GITLAB_RUNNER_TOKEN

echo -e "${GREEN}✓ GitLab Runner deployed${NC}"

# Step 8: Verify deployment
echo -e "${YELLOW}Step 8: Verifying deployment...${NC}"
sleep 10  # Wait for pod startup
kubectl get pods -n $RUNNER_NAMESPACE
kubectl get svc -n $RUNNER_NAMESPACE
echo -e "${GREEN}✓ Deployment verification complete${NC}"

# Step 9: Display useful commands
echo ""
echo -e "${YELLOW}=========================================="
echo "Setup Complete!"
echo "==========================================${NC}"
echo ""
echo -e "${GREEN}Useful kubectl commands:${NC}"
echo "  View runner pods:"
echo "    kubectl get pods -n $RUNNER_NAMESPACE"
echo ""
echo "  View runner logs:"
echo "    kubectl logs -n $RUNNER_NAMESPACE -l app=gitlab-runner -f"
echo ""
echo "  Describe runner deployment:"
echo "    kubectl describe deployment gitlab-runner -n $RUNNER_NAMESPACE"
echo ""
echo "  Check runner status in GitLab:"
echo "    1. Go to your GitLab project"
echo "    2. Settings > CI/CD > Runners"
echo "    3. You should see your runner listed and connected"
echo ""
echo -e "${YELLOW}To update the deployment:${NC}"
echo "  helm upgrade $RUNNER_RELEASE_NAME gitlab/gitlab-runner \\"
echo "    --namespace $RUNNER_NAMESPACE \\"
echo "    -f /tmp/gitlab-runner-values.yaml"
echo ""
echo -e "${YELLOW}To uninstall:${NC}"
echo "  helm uninstall $RUNNER_RELEASE_NAME -n $RUNNER_NAMESPACE"
echo ""
