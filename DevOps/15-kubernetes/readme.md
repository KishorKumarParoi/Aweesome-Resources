# Kubernetes Orchestration 🚀

Container orchestration and management with Kubernetes.

---

## What is Kubernetes?

Kubernetes (K8s) is an open-source platform for:
- Container orchestration
- Service management
- Auto-scaling
- Self-healing
- Declarative configuration

---

## Minikube Setup

Local Kubernetes cluster for development.

```bash
# Start minikube cluster
minikube start

# Check status
minikube status

# Open web dashboard
minikube dashboard

# Stop cluster
minikube stop

# Delete cluster
minikube delete
```

---

## Core Concepts

### Pods
Smallest deployable unit (usually one container per pod).

### Deployments
Manage replicas of pods with desired state.

### Services
Network abstraction to expose pods.

### ConfigMaps & Secrets
Configuration and sensitive data storage.

### Persistent Volumes (PV)
Storage that outlives pods.

### Namespaces
Virtual clusters for isolation.

---

## Deployments

### Create Deployment

```bash
# Create deployment
kubectl create deployment my-nginx --image=nginx:latest

# View deployments
kubectl get deployments

# View pods
kubectl get pods

# Describe pod (detailed info)
kubectl describe pod <pod_name>

# View deployment status
kubectl get deployment my-nginx -o wide

# Delete deployment
kubectl delete deployment my-web-app
```

---

## Scaling

### Scale Replicas

```bash
# Scale up to 3 replicas
kubectl scale deployment my-nginx --replicas=3

# Scale down to 1 replica
kubectl scale deployment my-nginx --replicas=1

# View current replicas
kubectl get deployment my-nginx
```

### Auto-scaling

```bash
# Enable auto-scaling
kubectl autoscale deployment my-nginx --min=2 --max=10 --cpu-percent=80

# View HPA (Horizontal Pod Autoscaler)
kubectl get hpa
```

---

## Services (Expose)

### Create Service

```bash
# Expose deployment
kubectl expose deployment my-nginx --port=80 --type=LoadBalancer

# Expose with specific port
kubectl expose deployment my-webapp --type=LoadBalancer --port=3002

# View services
kubectl get svc
```

### Access Service

```bash
# Get service access URL (minikube)
minikube service my-nginx

# Port forward to pod
kubectl port-forward pod/<pod_name> 3000:3000

# Port forward to service
kubectl port-forward svc/my-nginx 8080:80
```

---

## Pod Management

### Inspect Pods

```bash
# Get pod details
kubectl describe pod <pod_name>

# View pod logs
kubectl logs <pod_name>

# Follow logs (tail -f)
kubectl logs -f <pod_name>

# Previous pod logs (if crashed)
kubectl logs <pod_name> --previous

# Execute command in pod
kubectl exec <pod_name> -- ls -la
```

### Delete Pods

```bash
# Delete pod (replacement starts automatically)
kubectl delete pod <pod_name>

# Delete all pods in namespace
kubectl delete pods --all
```

---

## Updates & Rollouts

### Update Deployment

```bash
# Update image
kubectl set image deployment my-webapp web-app=<new-image>:04

# Check rollout status
kubectl rollout status deployment my-webapp

# View rollout history
kubectl rollout history deployment my-webapp

# Rollback to previous version
kubectl rollout undo deployment my-webapp

# Rollback to specific revision
kubectl rollout undo deployment my-webapp --to-revision=2
```

---

## Configuration Files

### Create Deployment from YAML

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: app
        image: my-app:v1.0
        ports:
        - containerPort: 8000
        env:
        - name: DATABASE_URL
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: db_url
```

### Apply Configuration

```bash
# Apply/create from file
kubectl apply -f deploy.yml

# Apply all YAML files
kubectl apply -f ./manifests/

# Delete from configuration
kubectl delete -f deploy.yml

# Get object as YAML
kubectl get deployment my-app -o yaml
```

---

## Networking

### Create Service YAML

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
  type: LoadBalancer
  selector:
    app: my-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8000
```

### Network Types

```bash
# ClusterIP (default, internal only)
kubectl expose deployment my-app --type=ClusterIP

# NodePort (expose on node)
kubectl expose deployment my-app --type=NodePort

# LoadBalancer (external load balancer)
kubectl expose deployment my-app --type=LoadBalancer
```

---

## Storage

### Persistent Volume & Claim

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/data"

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

---

## Namespaces

### Manage Namespaces

```bash
# View namespaces
kubectl get namespaces

# Create namespace
kubectl create namespace my-app

# Set default namespace
kubectl config set-context --current --namespace=my-app

# View resources in namespace
kubectl get all -n my-app

# Delete namespace (deletes all resources)
kubectl delete namespace my-app
```

---

## ConfigMaps & Secrets

### ConfigMaps

```bash
# Create from literal
kubectl create configmap app-config --from-literal=DB_HOST=localhost

# Create from file
kubectl create configmap app-config --from-file=config.yaml

# View ConfigMap
kubectl get configmap app-config -o yaml
```

### Secrets

```bash
# Create secret
kubectl create secret generic app-secret --from-literal=password=secret123

# Create from file
kubectl create secret generic db-credentials --from-file=./credentials

# View secrets (base64 encoded)
kubectl get secret app-secret -o yaml
```

---

## Useful Commands

| Command | Purpose |
|---------|---------|
| `kubectl get pods` | List pods |
| `kubectl describe pod <name>` | Detailed pod info |
| `kubectl logs <pod>` | View logs |
| `kubectl exec <pod> -- <cmd>` | Run command in pod |
| `kubectl scale deployment <name> --replicas=3` | Scale |
| `kubectl expose deployment <name>` | Create service |
| `kubectl apply -f <file>` | Apply configuration |
| `kubectl delete <resource>` | Delete resource |
| `kubectl port-forward <pod> 8080:8000` | Port forward |

---

**Last Updated:** December 22, 2025
