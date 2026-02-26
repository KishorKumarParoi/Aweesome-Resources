# Quick Start Summary: GitLab Runner on Your Kubernetes Cluster

## What You Now Have

Your existing Kubernetes cluster setup (from `1.sh`) with **Calico networking** is perfect for running GitLab Runner CI/CD pipelines. All jobs will run as **pods inside your cluster**.

## Files Created

| File | Purpose |
|------|---------|
| `gitlab-ci-kubernetes.yaml` | ✅ Main CI/CD pipeline (replaces your .gitlab-ci.yml) |
| `gitlab-runner-k8s-setup.sh` | 🚀 Automated deployment script |
| `GITLAB-RUNNER-KUBERNETES-SETUP.md` | 📖 Complete setup guide |
| `gitlab-ci-advanced-patterns.yaml` | 🎯 Advanced deployment patterns (reference) |

## Quick Start (5 Minutes)

### 1. Get Your GitLab Runner Token
```bash
# Go to GitLab UI:
# Project → Settings → CI/CD → Runners → Create Runner
# Copy the glrt_... token
```

### 2. Deploy GitLab Runner to Your Cluster
```bash
# Set your configuration
export GITLAB_URL="https://gitlab.com"
export GITLAB_RUNNER_TOKEN="glrt_your_token_here"

# Run the setup script
chmod +x gitlab-runner-k8s-setup.sh
./gitlab-runner-k8s-setup.sh
```

### 3. Verify Runner is Connected
```bash
# Check pods are running
kubectl get pods -n gitlab-runner

# Check GitLab UI - you should see a green dot
# Settings → CI/CD → Runners
```

### 4. Use the New Pipeline
```bash
# Replace your .gitlab-ci.yaml with the new version
cp gitlab-ci-kubernetes.yaml /path/to/your/repo/.gitlab-ci.yaml

# Go to GitLab and add these variables:
# Settings → CI/CD → Variables → Add variables:
#   DOCKER_USERNAME = your-docker-username
#   DOCKER_PASSWORD = your-docker-password
#   SONAR_TOKEN = (if using SonarQube)
#   SONAR_HOST_URL = (if using SonarQube)
```

### 5. Trigger a Pipeline
```bash
# Push code to main branch
git add .gitlab-ci.yaml
git commit -m "Add Kubernetes CI/CD pipeline"
git push origin main

# Watch it run in GitLab UI → CI/CD → Pipelines
```

## Pipeline Stages (What Happens)

```
✅ install_tools      → Maven, Trivy, kubectl, Docker verification
✅ test              → Unit tests with Maven
✅ security          → Trivy filesystem scan + SonarQube analysis
✅ build             → Maven build (creates JAR/WAR)
✅ docker            → Build & push Docker image
✅ security          → Trivy Docker image scan
✅ deploy            → Deploy to Kubernetes with kubectl
✅ verify_deployment → Confirm everything is running
```

## Monitoring Your Deployments

```bash
# View runner logs
kubectl logs -n gitlab-runner -l app=gitlab-runner -f

# View your deployed application
kubectl get all -n web-apps
kubectl logs -n web-apps deployment/boardgame-deployment

# Get public IP (if available)
kubectl get svc -n web-apps
```

## Useful Commands

```bash
# Check runner status
kubectl get pods -n gitlab-runner
kubectl describe deployment gitlab-runner -n gitlab-runner

# Check pipeline logs
kubectl logs -n gitlab-runner -l app=gitlab-runner --tail=100 -f

# View application deployment
kubectl get pods -n web-apps
kubectl describe pod -n web-apps <pod-name>

# Troubleshoot pipeline job
kubectl logs <job-pod-name> -n gitlab-runner
```

## Environment Variables You Need to Set in GitLab

Settings → CI/CD → Variables

| Variable | Value |
|----------|-------|
| `DOCKER_USERNAME` | Your Docker Hub username |
| `DOCKER_PASSWORD` | Your Docker Hub password |
| `SONAR_TOKEN` | Token from SonarQube (optional) |
| `SONAR_HOST_URL` | SonarQube URL (optional) |

## Deployment Manifests

Your application deploys to the `web-apps` namespace using `deployment-service.yaml`. This file should contain:

```yaml
# Must have: Deployment for boardgame-deployment
# Must have: Service (LoadBalancer or ClusterIP)
# You can use the template in the setup guide
```

## Architecture Diagram

```
Your GitLab Repository
         ↓
    .gitlab-ci.yaml  (push to main)
         ↓
  GitLab CI/CD System
         ↓
GitLab Runner (on Kubernetes)
         ↓
  Kubernetes Cluster
    ├── install_tools pod
    ├── test pod
    ├── security pods
    ├── build pod
    ├── docker pod
    └── deploy pod → deploys → web-apps namespace → boardgame pods
```

## Important Notes

1. ✅ Your Kubernetes cluster is using **Calico CNI** (already installed)
2. ✅ All jobs run as **pods inside your cluster**
3. ✅ Jobs can build Docker images using **Docker-in-Docker**
4. ✅ Jobs have full `kubectl` access to deploy applications
5. ⚠️  Set resource limits to avoid filling up your cluster
6. ⚠️  Use RBAC carefully - current setup uses cluster-admin (not for production)

## Next Steps (Production Ready)

1. **Implement RBAC** - Reduce permissions from cluster-admin
2. **Add Network Policies** - Restrict pod communication
3. **Setup Monitoring** - Add Prometheus/Grafana
4. **Enable Logging** - Send logs to ELK/Loki
5. **Setup Ingress** - Use NGINX Ingress instead of LoadBalancer
6. **Add TLS** - Setup HTTPS with cert-manager
7. **Implement GitOps** - Use ArgoCD for deployments

## Troubleshooting

**Problem: Runner not appearing in GitLab**
```bash
# Check if runner pod is running
kubectl get pods -n gitlab-runner

# Check logs
kubectl logs -n gitlab-runner -l app=gitlab-runner
```

**Problem: Pipeline fails with "image pull error"**
```bash
# Verify Docker credentials in CI/CD Variables
# Make sure DOCKER_USERNAME and DOCKER_PASSWORD are set correctly
```

**Problem: kubectl commands fail in pipeline**
```bash
# Runner already has kubeconfig - you shouldn't need to set it manually
# Check if service account has proper permissions
kubectl auth can-i get pods --as=system:serviceaccount:gitlab-runner:gitlab-runner-sa
```

**Problem: Not enough resources**
```bash
# Check cluster resources
kubectl top nodes
kubectl top pods -n gitlab-runner

# Reduce replicas or remove resource-intensive stages
```

## References

- Your Kubernetes Setup: `./1.sh`
- Full Guide: `./GITLAB-RUNNER-KUBERNETES-SETUP.md`
- Advanced Patterns: `./gitlab-ci-advanced-patterns.yaml`
- GitLab Runner Docs: https://docs.gitlab.com/runner/install/kubernetes.html
- Kubernetes Docs: https://kubernetes.io/docs/

## Support

If something goes wrong:

1. Check runner logs: `kubectl logs -n gitlab-runner -l app=gitlab-runner -f`
2. Check pipeline job logs in GitLab UI
3. Check Kubernetes pod status: `kubectl describe pod -n gitlab-runner <pod>`
4. Review the full guide: `GITLAB-RUNNER-KUBERNETES-SETUP.md`

---

**You're ready to go! Run the setup script and start deploying with GitLab CI/CD on Kubernetes.** 🚀
