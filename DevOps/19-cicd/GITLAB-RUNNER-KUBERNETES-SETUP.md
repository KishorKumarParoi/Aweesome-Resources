# GitLab Runner on Kubernetes - Complete Setup Guide

## Overview
This guide helps you deploy GitLab Runner on your Kubernetes cluster to enable CI/CD pipelines that run as pods within your cluster.

## Prerequisites
- ✅ Working Kubernetes cluster (from your `1.sh` setup)
- ✅ Calico network plugin installed
- ✅ kubectl configured and working
- ✅ Helm 3.x installed
- ✅ GitLab account and project
- ✅ Admin access to your Kubernetes cluster

## Step 1: Prepare Your Kubernetes Cluster

Your cluster is already set up from the `1.sh` script with:
- Master node with kubeadm initialized
- Calico CNI plugin (v3.28.0)
- Worker nodes joined to cluster
- Proper networking (10.244.0.0/16 CIDR)

Verify your cluster is ready:
```bash
kubectl get nodes
# Output should show master and worker nodes in Ready state

kubectl get pods -n kube-system
# Should show Calico, CoreDNS, and other system pods running
```

## Step 2: Create GitLab Runner Token

1. Go to your GitLab project (or group for shared runner)
2. **Settings** → **CI/CD** → **Runners**
3. Click "**Create runner**" or "**New instance runner**"
4. Select **Linux** as the platform
5. Select **Docker** as the executor
6. Copy the **registration token** (you'll need this in Step 4)

Alternatively, if using an existing registration token:
- Navigate to **Admin Area** → **Runners** for instance runners
- Or **Settings** → **CI/CD** → **Runners** for project-specific runners

## Step 3: Install Helm (if not already installed)

```bash
# Check if Helm is installed
helm version

# If not installed, install it
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installation
helm version
```

## Step 4: Deploy GitLab Runner

### Option A: Using the Setup Script (Recommended)

```bash
# Make the script executable
chmod +x gitlab-runner-k8s-setup.sh

# Set your GitLab configuration
export GITLAB_URL="https://gitlab.com"  # Change if using self-hosted
export GITLAB_RUNNER_TOKEN="glrt_xxxxxxxxxxxxxxxxxx"  # Your token from Step 2

# Run the setup script
./gitlab-runner-k8s-setup.sh
```

### Option B: Manual Helm Deployment

```bash
# Add GitLab Helm repository
helm repo add gitlab https://charts.gitlab.io
helm repo update

# Create namespace
kubectl create namespace gitlab-runner

# Create service account
kubectl create serviceaccount gitlab-runner-sa -n gitlab-runner
kubectl create clusterrolebinding gitlab-runner-crb \
  --clusterrole=cluster-admin \
  --serviceaccount=gitlab-runner:gitlab-runner-sa

# Deploy GitLab Runner
helm install gitlab-runner gitlab/gitlab-runner \
  --namespace gitlab-runner \
  --set gitlabUrl=https://gitlab.com \
  --set gitlabToken=glrt_xxxxxxxxxxxxxxxxxx \
  --set runners.image=ubuntu:22.04 \
  --set runners.tags="kubernetes,docker,linux" \
  --set runners.privileged=true
```

## Step 5: Verify Deployment

### Check Runner Pods
```bash
kubectl get pods -n gitlab-runner
# Should show running runner pods

# View logs
kubectl logs -n gitlab-runner -l app=gitlab-runner -f
```

### Verify in GitLab
1. Go to **Settings** → **CI/CD** → **Runners**
2. Your runner should appear in the list with a **green dot** (connected)
3. Tags should show: `kubernetes`, `docker`, `linux`

## Step 6: Create Deployment Manifests for Your Application

### Create `deployment-service.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: boardgame-deployment
  namespace: web-apps
  labels:
    app: boardgame
spec:
  replicas: 2
  selector:
    matchLabels:
      app: boardgame
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: boardgame
    spec:
      containers:
      - name: boardgame
        image: kishorkumarparoi/boardgame:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
          name: http
        resources:
          requests:
            cpu: 250m
            memory: 512Mi
          limits:
            cpu: 500m
            memory: 1Gi
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: boardgame-service
  namespace: web-apps
  labels:
    app: boardgame
spec:
  selector:
    app: boardgame
  type: LoadBalancer
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
    name: http
---
apiVersion: v1
kind: Namespace
metadata:
  name: web-apps
```

## Step 7: Use the Updated `.gitlab-ci.yaml`

Replace your existing `.gitlab-ci.yaml` with the provided `gitlab-ci-kubernetes.yaml`:

```bash
cp gitlab-ci-kubernetes.yaml .gitlab-ci.yaml
```

### Update Required Variables in GitLab

Go to **Settings** → **CI/CD** → **Variables** and add:

```
DOCKER_USERNAME       = your-docker-username
DOCKER_PASSWORD       = your-docker-password
SONAR_HOST_URL        = https://sonarqube-instance.com (if using SonarQube)
SONAR_TOKEN          = your-sonar-token
SONAR_PROJECT_KEY    = your-project-key
```

## Step 8: Pipeline Execution Flow

When you push code to the `main` branch, the pipeline will:

1. **install_tools** → Verify Maven, Trivy, kubectl, Docker
2. **unit_testing** → Run `mvn clean test`
3. **security** → Run Trivy FS scan and SonarQube analysis
4. **build** → Build with `mvn clean package`
5. **docker** → Build and push Docker image
6. **security** → Scan Docker image with Trivy
7. **deploy** → Deploy to Kubernetes using kubectl

All jobs run as **pods inside your Kubernetes cluster**.

## Monitoring & Troubleshooting

### View Runner Status
```bash
# Check pod logs
kubectl logs -n gitlab-runner <pod-name> -f

# Check pod status
kubectl describe pod -n gitlab-runner <pod-name>

# Check resource usage
kubectl top pods -n gitlab-runner

# Check events
kubectl get events -n gitlab-runner --sort-by='.lastTimestamp'
```

### Common Issues

**Issue: Runner not connecting to GitLab**
```bash
# Check if runner can reach GitLab URL
kubectl exec -it -n gitlab-runner <pod-name> -- curl https://gitlab.com

# Verify token is correct
kubectl get secret -n gitlab-runner -o yaml
```

**Issue: Pods failing to pull Docker image**
```bash
# Check image pull errors
kubectl describe pod -n web-apps <pod-name>

# Verify Docker credentials are in GitLab CI/CD Variables
```

**Issue: kubectl commands failing in pipeline**
```bash
# Ensure KUBECONFIG is properly set (it's automatic with runner on K8s)
# Check runner logs for authentication issues
```

## Scaling GitLab Runner

### Increase Runner Replicas
```bash
helm upgrade gitlab-runner gitlab/gitlab-runner \
  --namespace gitlab-runner \
  --set replicas=3
```

### Configure Resource Limits
Edit the values file or:
```bash
helm upgrade gitlab-runner gitlab/gitlab-runner \
  --namespace gitlab-runner \
  --set runners.resources.limits.cpu=2 \
  --set runners.resources.limits.memory=4Gi
```

## Network Policy (Optional Security Enhancement)

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: gitlab-runner-policy
  namespace: gitlab-runner
spec:
  podSelector:
    matchLabels:
      app: gitlab-runner
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector: {}
  egress:
  - to:
    - namespaceSelector: {}
  - to:
    - podSelector: {}
  - ports:
    - protocol: TCP
      port: 53  # DNS
    - protocol: UDP
      port: 53
```

## useful Kubectl Commands

```bash
# View all runners
kubectl get all -n gitlab-runner

# Get runner pod names
kubectl get pods -n gitlab-runner -o jsonpath='{.items[*].metadata.name}'

# View runner configuration
kubectl get configmap -n gitlab-runner -o yaml

# Delete a specific runner pod (will recreate)
kubectl delete pod -n gitlab-runner <pod-name>

# Check namespace resources in deployment
kubectl get all -n web-apps

# View deployment logs
kubectl logs -n web-apps deployment/boardgame-deployment --tail=100 -f

# Get service endpoint
kubectl get svc -n web-apps boardgame-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

## Cleanup (if needed)

```bash
# Uninstall GitLab Runner
helm uninstall gitlab-runner -n gitlab-runner

# Delete namespace
kubectl delete namespace gitlab-runner

# Delete applications
kubectl delete namespace web-apps
```

## Next Steps

1. ✅ Deploy GitLab Runner using the setup script
2. ✅ Verify runner connectivity in GitLab UI
3. ✅ Commit `.gitlab-ci.yaml` to your repository
4. ✅ Push a commit to trigger the pipeline
5. ✅ Monitor pipeline execution in GitLab UI
6. ✅ Verify deployment in Kubernetes: `kubectl get all -n web-apps`

## References

- [GitLab Runner on Kubernetes](https://docs.gitlab.com/runner/install/kubernetes.html)
- [GitLab Runner Helm Chart](https://gitlab.com/gitlab-org/charts/gitlab-runner)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Your Cluster Setup](./1.sh)
