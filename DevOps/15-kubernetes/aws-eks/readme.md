# Make sure you install kubectl, eksctl, aws configured aready 

# Install EKS

Please follow the prerequisites doc before this.

## Install using Fargate

```bash
eksctl create cluster --name demo-cluster --region us-east-1 --fargate
```

## Delete the cluster

```bash
eksctl delete cluster --name demo-cluster --region us-east-1
```

```bash
aws eks update-kubeconfig --name demo-cluster --region us-east-1
```

# AWS EKS Resource Types - Comprehensive Guide

This document covers all Kubernetes resource types used in AWS EKS clusters, organized by category.

---

## **1. WORKLOADS**

Resources that manage and run containerized applications.

### **Pods**
```yaml
# Most basic unit in Kubernetes
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: app
    image: nginx:latest
    ports:
    - containerPort: 80
```

**Purpose:**
- Smallest deployable unit
- Runs one or more containers
- Containers share network namespace (same IP)
- Typically ephemeral (created/destroyed frequently)

**Use Case:** Debugging, one-off tasks (usually wrapped in higher-level resources)

---

### **ReplicaSets**
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-rs
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
```

**Purpose:**
- Ensures specified number of pod replicas running
- Replaces failed pods automatically
- Manages pod lifecycle

**Key Feature:** Desired state = 3 replicas → Always maintains 3 running pods

**Note:** Don't use directly; use Deployments instead

---

### **Deployments**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
```

**Purpose:**
- Most common way to deploy applications
- Manages ReplicaSets under the hood
- Enables rolling updates, rollbacks, version history
- Declarative updates

**Features:**
- **Rolling Updates** - Gradually replace old pods with new ones
- **Rollbacks** - Revert to previous versions
- **Pause/Resume** - Control deployment process
- **Scaling** - Adjust replicas dynamically

**Use Case:** Stateless applications (web servers, APIs, microservices)

---

### **StatefulSets**
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql-statefulset
spec:
  serviceName: mysql
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "gp3"
      resources:
        requests:
          storage: 10Gi
```

**Purpose:**
- Manages stateful applications
- Maintains sticky identity for each pod
- Guarantees ordering and uniqueness

**Key Differences from Deployments:**
| Aspect | Deployment | StatefulSet |
|--------|-----------|------------|
| Pod Names | Random hash | Ordinal (mysql-0, mysql-1, mysql-2) |
| Storage | Shared | Persistent per pod |
| Network | Ephemeral | Stable hostname |
| Use Case | Stateless | Stateful (databases, caches) |

**Use Case:** Databases (MySQL, PostgreSQL), message queues (RabbitMQ), search engines (Elasticsearch)

---

### **DaemonSets**
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
  namespace: logging
spec:
  selector:
    matchLabels:
      name: fluentd
  template:
    metadata:
      labels:
        name: fluentd
    spec:
      containers:
      - name: fluentd
        image: fluent/fluentd:latest
        volumeMounts:
        - name: log
          mountPath: /var/log
      volumes:
      - name: log
        hostPath:
          path: /var/log
```

**Purpose:**
- Runs pod on every node (or selected nodes)
- One instance per node automatically
- Updates/removes pods as nodes scale

**Use Cases:**
- Log collection (Fluentd, Filebeat)
- Monitoring agents (Prometheus node-exporter)
- Network plugins (Flannel, Calico)
- Security scanning

**Example:** 10 nodes → 10 fluentd pods automatically

---

### **Jobs**
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: backup-job
spec:
  completions: 1
  parallelism: 1
  backoffLimit: 3
  template:
    spec:
      containers:
      - name: backup
        image: backup-tool:latest
        command: ["./backup.sh"]
      restartPolicy: Never
```

**Purpose:**
- Run one-off tasks to completion
- Ensure job completes successfully
- Retry on failure

**Key Parameters:**
- `completions` - Number of successful completions needed
- `parallelism` - Run tasks in parallel
- `backoffLimit` - Max retry attempts
- `restartPolicy` - Never/OnFailure

**Use Case:** Database migrations, backups, batch processing, data imports

---

### **CronJobs**
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: daily-backup
spec:
  schedule: "0 2 * * *"  # 2 AM daily
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: backup-tool:latest
            command: ["./backup.sh"]
          restartPolicy: OnFailure
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
```

**Purpose:**
- Schedule jobs to run at specific times
- Like cron jobs on Linux
- Creates Job resources on schedule

**Schedule Format:** `minute hour day month weekday`

**Use Case:** Scheduled backups, cleanup tasks, report generation, maintenance

---

### **HorizontalPodAutoscalers (HPA)**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 15
```

**Purpose:**
- Automatically scale pods based on metrics
- Monitor CPU, memory, custom metrics
- Scale up/down dynamically

**How it works:**
```
High CPU (>70%)
    ↓
HPA detects
    ↓
Increases replicas (2 → 5)
    ↓
Distributes load
    ↓
CPU normalizes
```

**Use Case:** Handle traffic spikes, cost optimization, auto-scaling web applications

---

### **PriorityClasses**
```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000
globalDefault: false
description: "High priority for critical applications"
```

**Purpose:**
- Define pod priority for scheduling
- Evict lower priority pods when resources limited
- Ensure critical workloads run

**Usage in Pod:**
```yaml
spec:
  priorityClassName: high-priority
```

---

## **2. CLUSTER RESOURCES**

Cluster-level configuration and management.

### **Nodes**
```yaml
apiVersion: v1
kind: Node
metadata:
  name: worker-node-1
  labels:
    node-type: worker
    disk: ssd
spec:
  podCIDR: 10.244.0.0/24
```

**Purpose:**
- Represents worker machine
- Kubelet runs on each node
- Scheduling unit for pods

**Node Status:**
```bash
# Check node status
kubectl get nodes
kubectl describe node worker-node-1

# Typical fields:
Name: worker-node-1
Status: Ready
Capacity:
  cpu: 4
  memory: 8Gi
  pods: 110
```

---

### **Namespaces**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    environment: prod
```

**Purpose:**
- Logical cluster division
- Resource quotas per namespace
- Network policies isolation
- RBAC scope

**Common Namespaces:**
- `default` - Default namespace
- `kube-system` - Kubernetes system components
- `kube-public` - Publicly accessible
- `production` - Production workloads
- `staging` - Staging workloads
- `logging` - Log aggregation

**Usage:**
```bash
# Deploy in specific namespace
kubectl apply -f deployment.yaml -n production

# Get resources in namespace
kubectl get pods -n production
```

---

### **RuntimeClasses**
```yaml
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: gvisor
handler: gvisor
scheduling:
  nodeSelector:
    runtime: gvisor
```

**Purpose:**
- Define container runtimes
- Use different runtimes for different workloads
- Security isolation (gVisor, Kata)

**Use Case:** Run untrusted code in sandboxed environment

---

## **3. SERVICE & NETWORKING**

Network communication and service discovery.

### **Services**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
    nodePort: 30080
```

**Types:**

**1. ClusterIP** (Default)
```yaml
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 8080
```
- Internal only
- Stable IP within cluster
- Use Case: Internal microservices communication

**2. NodePort**
```yaml
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30080
```
- Exposes on node port (30000-32767)
- Accessible from outside: `<NodeIP>:30080`
- Use Case: External access without load balancer

**3. LoadBalancer**
```yaml
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
```
- Creates cloud load balancer (ELB/ALB/NLB)
- External IP assigned
- Use Case: Public-facing applications

**4. ExternalName**
```yaml
spec:
  type: ExternalName
  externalName: external-api.example.com
```
- Routes to external service
- Use Case: Integrate external APIs

---

### **Ingress**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api
            port:
              number: 3000
  - host: admin.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: admin-panel
            port:
              number: 8080
```

**Purpose:**
- Layer 7 (application) routing
- Host/path-based routing
- TLS/SSL termination

**Ingress Controllers (AWS EKS):**
- ALB Ingress Controller
- NGINX Ingress
- Traefik

**Use Case:** Route multiple services through single entry point

---

### **NetworkPolicies**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          namespace: production
    ports:
    - protocol: TCP
      port: 3306
  egress:
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 443
```

**Purpose:**
- Control traffic between pods
- Firewall rules for pods
- Network segmentation

**Example Rules:**
- Deny all ingress, allow only from specific namespace
- Allow egress only to specific ports
- Deny cross-namespace communication

---

## **4. CONFIG & SECRETS**

Application configuration management.

### **ConfigMaps**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_ENV: production
  LOG_LEVEL: info
  database.conf: |
    host=localhost
    port=5432
    pool_size=10
```

**Usage in Deployment:**
```yaml
spec:
  containers:
  - name: app
    image: myapp:latest
    env:
    - name: APP_ENV
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: APP_ENV
    volumeMounts:
    - name: config
      mountPath: /etc/config
  volumes:
  - name: config
    configMap:
      name: app-config
      items:
      - key: database.conf
        path: database.conf
```

**Purpose:**
- Store non-sensitive configuration
- Decouple config from code
- Easy updates without rebuilds

**Use Case:** Environment variables, config files

---

### **Secrets**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  username: dXNlcm5hbWU=  # base64 encoded
  password: cGFzc3dvcmQ=  # base64 encoded
```

**Types:**
- `Opaque` - Arbitrary user data
- `kubernetes.io/service-account-token` - Service account token
- `kubernetes.io/dockercfg` - Docker config
- `kubernetes.io/dockerconfigjson` - Docker config JSON
- `kubernetes.io/basic-auth` - Basic auth
- `kubernetes.io/ssh-auth` - SSH key
- `kubernetes.io/tls` - TLS certificate
- `bootstrap.kubernetes.io/token` - Bootstrap token

**Usage:**
```yaml
spec:
  containers:
  - name: app
    image: myapp:latest
    env:
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: password
    volumeMounts:
    - name: secrets
      mountPath: /etc/secrets
  volumes:
  - name: secrets
    secret:
      secretName: db-secret
```

**Best Practices:**
- Use AWS Secrets Manager / Parameter Store instead
- Enable encryption at rest
- RBAC to limit access
- Rotate regularly

---

## **5. STORAGE**

Persistent data management.

### **PersistentVolumes (PV)**
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-ebs
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: gp3
  awsElasticBlockStore:
    volumeID: vol-12345678
    fsType: ext4
```

**Purpose:**
- Cluster-level storage resource
- Decoupled from pods
- Lifecycle independent of pods

---

### **PersistentVolumeClaims (PVC)**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: gp3
  resources:
    requests:
      storage: 50Gi
```

**Purpose:**
- Pod requests storage via PVC
- Automatically binds to PV
- User-level storage request

**Usage:**
```yaml
spec:
  containers:
  - name: app
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: my-pvc
```

---

### **StorageClasses**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp3-fast
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
  encrypted: "true"
reclaimPolicy: Delete
allowVolumeExpansion: true
```

**Purpose:**
- Define storage types
- Dynamic provisioning
- Parameter configuration

**AWS Storage Classes:**
```yaml
# Standard
provisioner: ebs.csi.aws.com
type: gp3

# High IOPS
type: io1
iops: 10000

# Throughput optimized
type: st1
throughput: 500
```

---

### **CSIDrivers / CSINodes**
```yaml
apiVersion: storage.k8s.io/v1
kind: CSIDriver
metadata:
  name: ebs.csi.aws.com
spec:
  attachRequired: true
  podInfoOnMount: false
```

**Purpose:**
- Define Container Storage Interface drivers
- Enable dynamic provisioning
- AWS EBS CSI Driver, EFS CSI Driver, etc.

---

## **6. AUTHENTICATION & AUTHORIZATION**

Access control and permissions.

### **ServiceAccounts**
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
  namespace: production
automountServiceAccountToken: true
```

**Purpose:**
- Identity for pods
- RBAC scope
- API access tokens

**Usage:**
```yaml
spec:
  serviceAccountName: app-sa
```

**IRSA (IAM Roles for Service Accounts):**
```bash
# Bind Kubernetes ServiceAccount to IAM role
kubectl annotate serviceaccount app-sa \
  eks.amazonaws.com/role-arn=arn:aws:iam::ACCOUNT:role/app-role
```

---

### **ClusterRoles**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get"]
```

**Purpose:**
- Define cluster-level permissions
- Reusable across namespaces
- Bind via ClusterRoleBinding

---

### **ClusterRoleBindings**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: pod-reader-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: pod-reader
subjects:
- kind: ServiceAccount
  name: app-sa
  namespace: production
```

**Purpose:**
- Grant ClusterRole to subjects
- Subject = User, Group, ServiceAccount

---

### **Roles & RoleBindings**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployment-manager
  namespace: production
rules:
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: deployment-manager-binding
  namespace: production
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: deployment-manager
subjects:
- kind: ServiceAccount
  name: app-sa
  namespace: production
```

**Difference:** Roles are namespace-scoped

---

## **7. POLICY**

Resource limits and constraints.

### **ResourceQuotas**
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: production-quota
  namespace: production
spec:
  hard:
    requests.cpu: "100"
    requests.memory: "200Gi"
    limits.cpu: "200"
    limits.memory: "400Gi"
    pods: "1000"
    services.loadbalancers: "2
    services.nodeports: "5"
```

**Purpose:**
- Limit total resources per namespace
- Prevent resource hogging
- Cost control

---

### **LimitRanges**
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: pod-limits
  namespace: production
spec:
  limits:
  - max:
      cpu: "4"
      memory: "8Gi"
    min:
      cpu: "100m"
      memory: "128Mi"
    default:
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:
      cpu: "250m"
      memory: "256Mi"
    type: Container
```

**Purpose:**
- Set min/max resource limits per container
- Define defaults
- Prevent small/large resource requests

---

### **PodDisruptionBudgets (PDB)**
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: app-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: my-app
```

**Purpose:**
- Maintain availability during voluntary disruptions
- Prevent simultaneous pod evictions
- Node maintenance without downtime

**Scenarios:**
- Cluster autoscaling
- Node maintenance
- Kubernetes upgrades

---

## **8. EXTENSIONS**

Custom resources and webhooks.

### **CustomResourceDefinitions (CRD)**
```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: databases.example.com
spec:
  group: example.com
  names:
    kind: Database
    plural: databases
  scope: Namespaced
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              engine:
                type: string
              size:
                type: integer
```

**Usage:**
```yaml
apiVersion: example.com/v1
kind: Database
metadata:
  name: my-db
spec:
  engine: postgres
  size: 100
```

**Purpose:**
- Extend Kubernetes API
- Define custom resources
- Build custom operators

---

### **Validating & Mutating Webhooks**
```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: image-policy-webhook
webhooks:
- name: validate-image.example.com
  clientConfig:
    service:
      name: webhook-service
      namespace: default
      path: "/validate"
    caBundle: LS0tLS1...
  rules:
  - operations: ["CREATE", "UPDATE"]
    apiGroups: [""]
    apiVersions: ["v1"]
    resources: ["pods"]
  admissionReviewVersions: ["v1"]
  sideEffects: None
```

**Purpose:**
- Validate objects before creation
- Mutate objects before storage
- Enforce policies
- Security scanning

**Use Cases:**
- Enforce image registry restrictions
- Require resource limits
- Inject sidecars (Istio)
- Policy enforcement

---

## **Summary Table**

| Category | Resource | Purpose |
|----------|----------|---------|
| **Workload** | Pod | Basic unit |
| | Deployment | Stateless apps |
| | StatefulSet | Stateful apps |
| | DaemonSet | Per-node apps |
| | Job | One-off tasks |
| | CronJob | Scheduled tasks |
| **Service** | Service | Network access |
| | Ingress | Layer 7 routing |
| | NetworkPolicy | Network firewall |
| **Storage** | PersistentVolume | Storage resource |
| | PersistentVolumeClaim | Storage request |
| | StorageClass | Storage template |
| **Config** | ConfigMap | Non-secret config |
| | Secret | Secret config |
| **Auth** | ServiceAccount | Pod identity |
| | Role/ClusterRole | Permissions |
| | RoleBinding | Grant permissions |
| **Policy** | ResourceQuota | Namespace limits |
| | LimitRange | Pod limits |
| | PDB | Disruption safety |

This comprehensive guide covers all major Kubernetes resources used in AWS EKS! 🚀

```bash
aws eks update-kubeconfig --name demo-cluster --region us-east-1
```
The command `aws eks update-kubeconfig --name demo-cluster --region us-east-1` is used to **configure your local `kubectl` to communicate with your AWS EKS cluster**.

Here's what it does:

1. **Retrieves cluster credentials** from AWS EKS
2. **Updates your kubeconfig file** (typically `~/.kube/config` on Mac)
3. **Adds/updates the cluster context** so `kubectl` knows how to connect to your EKS cluster

**Why you need it:**

- After creating an EKS cluster, your local machine doesn't automatically know how to access it
- This command establishes the connection between your `kubectl` CLI and the remote EKS cluster
- Without it, `kubectl` commands will fail because it won't have the cluster details (API endpoint, certificates, tokens)

**After running this command:**


```bash
# These commands will now work
kubectl get pods
kubectl get nodes
kubectl apply -f deployment.yaml
# etc.
```


**Parameters explained:**
- `--name demo-cluster` - The name of your EKS cluster
- `--region us-east-1` - The AWS region where your cluster is deployed

**On your Mac, you can verify it worked:**


```bash
# View your kubeconfig
cat ~/.kube/config

# List available contexts
kubectl config get-contexts

# Switch to the EKS cluster context
kubectl config use-context <context-name>
```


This is a one-time setup step after creating your EKS cluster.

# 2048 App

## Create Fargate profile

```
eksctl create fargateprofile \
    --cluster demo-cluster \
    --region us-east-1 \
    --name alb-sample-app \
    --namespace game-2048
```

## Deploy the deployment, service and Ingress

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/examples/2048/2048_full.yaml

ingress controller -> ingress-2048 -> Load Balancer -> target group, pods, port
```
# AWS Compute & Container Services - Detailed Comparison

---

## **1. FARGATE (AWS EKS/ECS)**

**Serverless container compute for Kubernetes & ECS**

### **What is Fargate?**
AWS-managed serverless compute engine that runs containers without managing EC2 instances.

### **Architecture**
```
Your Container Image
        ↓
Fargate Profile (EKS) / Task Definition (ECS)
        ↓
AWS Manages Infrastructure (CPU, Memory, Networking)
        ↓
Container Runs
```

### **How it Works**

```yaml
# EKS Fargate Profile
eksctl create fargateprofile \
    --cluster demo-cluster \
    --region us-east-1 \
    --name alb-sample-app \
    --namespace game-2048
```

When you deploy a pod to `game-2048` namespace:
1. Pod spec submitted to Kubernetes
2. Scheduler sees Fargate profile matches namespace
3. AWS provisions compute automatically
4. Pod runs on Fargate infrastructure
5. Pod completes → resources deallocated

### **Pricing**

```
Cost = vCPU per hour + Memory per hour

Example (1 vCPU, 2GB RAM):
- vCPU: $0.04 per hour
- Memory: $0.004 per GB per hour
- Total: ~$35/month for continuous run
```

### **Key Features**

| Feature | Details |
|---------|---------|
| **Management** | AWS manages everything |
| **Scaling** | Automatic per pod |
| **Networking** | VPC native (own ENI) |
| **Storage** | EBS volumes, EFS |
| **Pricing** | Pay per pod second |
| **Cold Start** | ~1-2 minutes first pod |

### **Limitations**

```
❌ Cannot use DaemonSets (need host access)
❌ Cannot use privileged containers
❌ Cannot use host networking
❌ Limited to specific instance types (0.25-4 vCPU)
❌ No GPU support (yet)
```

### **Best Use Cases**

✅ Stateless web applications
✅ Microservices
✅ Batch jobs
✅ CI/CD workloads
✅ Temporary/bursty workloads
✅ Development/testing environments

### **Example: Deploying 2048 Game on Fargate**

```bash
# Step 1: Create Fargate profile
eksctl create fargateprofile \
    --cluster demo-cluster \
    --region us-east-1 \
    --name alb-sample-app \
    --namespace game-2048

# Step 2: Deploy app to Fargate namespace
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/examples/2048/2048_full.yaml

# Step 3: Check running pods (on Fargate!)
kubectl get pods -n game-2048
kubectl describe pod <pod-name> -n game-2048
```

**Output shows:**
```
Pod runs on Fargate (no EC2 instance visible)
Assigned to Fargate infrastructure
Gets own ENI and IP
```

---

## **2. LAMBDA**

**Event-driven serverless computing**

### **What is Lambda?**
Serverless function execution service - run code without managing servers.

### **Architecture**
```
Event Trigger
    ↓
Lambda Function Invoked
    ↓
Code Executes (0-15 minutes)
    ↓
Returns Result
    ↓
Auto Scales (Concurrent Executions)
```

### **How it Works**

```python
# Lambda Handler Function
def lambda_handler(event, context):
    """
    event: Input data from trigger
    context: Runtime information
    """
    name = event['name']
    return {
        'statusCode': 200,
        'body': f'Hello {name}'
    }
```

### **Pricing**

```
Cost = (Requests) + (Duration × Memory)

Example (1M requests, 512MB, 1 second each):
- Requests: $0.0000002 × 1,000,000 = $0.20
- Duration: $0.0000166667 × 1M = $16.67
- Total: ~$16.87/month
(Free tier: 1M requests/month + 400,000 GB-seconds)
```

### **Event Triggers**

```yaml
# API Gateway (REST API)
GET /user/{id}
  ↓
Lambda Executes
  ↓
Returns JSON

# S3 (File Upload)
File Uploaded
  ↓
Lambda Processes Image
  ↓
Saves to Database

# SNS (Notifications)
SNS Message Published
  ↓
Lambda Sends Email
  ↓
Completes

# DynamoDB Streams (Data Changes)
Item Updated
  ↓
Lambda Triggers
  ↓
Updates Cache

# EventBridge (Scheduled)
Every 5 minutes
  ↓
Lambda Checks Status
  ↓
Alerts if Issue
```

### **Key Features**

| Feature | Details |
|---------|---------|
| **Languages** | Python, Node.js, Java, Go, C#, Ruby |
| **Memory** | 128MB - 10,240MB (1GB increments) |
| **Timeout** | 1 second - 15 minutes |
| **Concurrency** | Auto-scales instantly |
| **Cold Start** | ~100-500ms (depends on runtime) |
| **Storage** | /tmp: 512MB temporary |

### **Example: REST API with Lambda**

```python
# index.py
import json

def lambda_handler(event, context):
    """
    event = {
        'body': '{"name": "John"}',
        'httpMethod': 'POST',
        'path': '/users'
    }
    """
    
    body = json.loads(event['body'])
    name = body['name']
    
    # Process request
    result = save_user(name)
    
    return {
        'statusCode': 201,
        'body': json.dumps({'id': result['id'], 'name': name})
    }

def save_user(name):
    # Call DynamoDB, RDS, etc.
    return {'id': 123}
```

### **Best Use Cases**

✅ REST APIs (with API Gateway)
✅ Image processing (S3 trigger)
✅ Real-time data processing
✅ Scheduled tasks (cron jobs)
✅ Webhooks & notifications
✅ Lightweight microservices
✅ IoT data processing

### **Limitations**

```
❌ Maximum 15-minute execution time
❌ No persistent storage (/tmp only)
❌ Limited to 10GB package size
❌ Cold starts can cause latency
❌ Not suitable for long-running processes
❌ Memory ↔ CPU coupling (no independent scaling)
```

---

## **3. EC2**

**Traditional compute instances (you manage everything)**

### **What is EC2?**
Virtual machines you manage - full control over OS, software, patches.

### **Architecture**
```
EC2 Instance (Virtual Machine)
├─ OS (Amazon Linux, Ubuntu, Windows)
├─ Your Application
├─ Databases
├─ Web Servers
├─ Security Groups (Firewalls)
└─ You manage all updates, patches, security
```

### **Instance Types**

```
t3.micro     - Burstable (free tier)
t3.small     - 2 vCPU, 2GB RAM
t3.medium    - 2 vCPU, 4GB RAM
m5.large     - 2 vCPU, 8GB RAM (General purpose)
m5.xlarge    - 4 vCPU, 16GB RAM
c5.large     - 2 vCPU, 4GB RAM (Compute optimized)
c5.2xlarge   - 8 vCPU, 16GB RAM
r5.large     - 2 vCPU, 16GB RAM (Memory optimized)
r5.2xlarge   - 8 vCPU, 64GB RAM
```

### **Pricing**

```
On-Demand:  Pay per hour
            t3.micro: $0.0116/hour (~$8.50/month)
            m5.large: $0.096/hour (~$70/month)

Reserved:   Commit 1-3 years (40-72% discount)
            t3.micro: $0.0047/hour (~$3.40/month) [1yr]

Spot:       Spare capacity (70-90% discount)
            t3.micro: $0.0035/hour (~$2.50/month)
            (Can be interrupted)
```

### **Key Features**

| Feature | Details |
|---------|---------|
| **OS Options** | Linux, Windows, macOS |
| **Customization** | Full control |
| **Scaling** | Manual or Auto Scaling Groups |
| **Storage** | EBS, EFS, S3 |
| **Networking** | Security Groups, Network ACLs |
| **Monitoring** | CloudWatch |
| **Time to Ready** | 1-2 minutes |

### **Example: Launch EC2 Instance**

```bash
# Using AWS CLI
aws ec2 run-instances \
    --image-id ami-0c55b159cbfafe1f0 \
    --instance-type t3.micro \
    --key-name my-key \
    --security-group-ids sg-12345678 \
    --subnet-id subnet-12345678

# Output:
InstanceId: i-1234567890abcdef0
PublicIpAddress: 54.123.45.67
PrivateIpAddress: 10.0.1.5
```

### **Manual Setup Required**

```bash
# SSH into instance
ssh -i my-key.pem ec2-user@54.123.45.67

# Install software
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker

# Deploy application
docker run -p 80:3000 myapp:latest

# Setup monitoring, logging, backups
# Manage security patches
# Handle failovers manually
```

### **Best Use Cases**

✅ Databases (MySQL, PostgreSQL, MongoDB)
✅ Long-running applications
✅ Full OS control needed
✅ Legacy applications
✅ High-performance computing
✅ Stateful applications
✅ On-premises migrations

### **Disadvantages**

```
❌ You manage everything
❌ Patching & updates manual
❌ Pay even when idle
❌ Scaling slower (takes minutes)
❌ More operational overhead
```

---

## **4. ECR (Elastic Container Registry)**

**Private Docker image repository**

### **What is ECR?**
AWS-managed Docker image registry (like Docker Hub but private).

### **Architecture**
```
Your Code
    ↓
Build Docker Image
    ↓
Push to ECR
    ↓
Pull in ECS/EKS/EC2/Lambda
    ↓
Run Container
```

### **How it Works**

```bash
# Step 1: Create ECR repository
aws ecr create-repository --repository-name my-app

# Output:
repositoryUri: 123456789.dkr.ecr.us-east-1.amazonaws.com/my-app

# Step 2: Build Docker image
docker build -t my-app:latest .

# Step 3: Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  123456789.dkr.ecr.us-east-1.amazonaws.com

# Step 4: Tag image
docker tag my-app:latest \
  123456789.dkr.ecr.us-east-1.amazonaws.com/my-app:latest

# Step 5: Push to ECR
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/my-app:latest

# Step 6: Use in Kubernetes
kubectl set image deployment/my-app \
  app=123456789.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
```

### **Features**

| Feature | Details |
|---------|---------|
| **Access Control** | IAM-based, not username/password |
| **Image Scanning** | Automated vulnerability scanning |
| **Lifecycle Policies** | Auto-delete old images |
| **Replication** | Copy images across regions |
| **Pricing** | Per GB stored + per GB transferred |

### **Example: ECR with EKS**

```yaml
# Deployment uses ECR image
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
      # Kubernetes automatically pulls from ECR
      # (if node has correct IAM role)
      containers:
      - name: app
        image: 123456789.dkr.ecr.us-east-1.amazonaws.com/my-app:v1.0
        imagePullPolicy: Always
        ports:
        - containerPort: 3000
      # Optional: explicit image pull secret
      imagePullSecrets:
      - name: ecr-secret
```

### **Pricing**

```
Storage:  $0.10 per GB per month
Transfer: $0.02 per GB (out of AWS region)

Example (10 images, 500MB each):
Storage: 5GB × $0.10 = $0.50/month
Transfer: Minimal
Total: ~$0.50/month
```

### **Best Use Cases**

✅ Private image repository
✅ Secure image storage
✅ Integration with ECS/EKS/Lambda
✅ Vulnerability scanning
✅ Image versioning
✅ Multi-region replication

---

## **5. ECS (Elastic Container Service)**

**Managed container orchestration (alternative to Kubernetes)**

### **What is ECS?**
AWS-native container orchestration (simpler than Kubernetes).

### **Architecture**
```
ECS Cluster
├─ EC2 Instances (or Fargate)
├─ Task Definition (like Deployment spec)
├─ Service (manages tasks)
└─ Load Balancer (for scaling)
```

### **Key Concepts**

**Task Definition** (like Kubernetes Deployment spec)
```json
{
  "family": "my-app",
  "containerDefinitions": [
    {
      "name": "app",
      "image": "123456789.dkr.ecr.us-east-1.amazonaws.com/my-app:latest",
      "cpu": 256,
      "memory": 512,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000,
          "protocol": "tcp"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/my-app",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ],
  "requiresCompatibilities": ["EC2"],
  "cpu": "256",
  "memory": "512",
  "networkMode": "bridge"
}
```

**Service** (runs task definition)
```json
{
  "serviceName": "my-app-service",
  "taskDefinition": "my-app:1",
  "desiredCount": 3,
  "launchType": "EC2",
  "loadBalancers": [
    {
      "targetGroupArn": "arn:aws:elasticloadbalancing:...",
      "containerName": "app",
      "containerPort": 3000
    }
  ]
}
```

### **Pricing**

```
With EC2:
- Pay for EC2 instances
- ECS orchestration: Free

With Fargate:
- Pay per task second
- Task 1GB, 0.25 vCPU: ~$0.000011574 per second
```

### **ECS vs EKS vs Kubernetes**

| Aspect | ECS | EKS | Self-managed K8s |
|--------|-----|-----|------------------|
| **Complexity** | Simple | Medium | High |
| **Learning Curve** | Easy | Steep | Very Steep |
| **AWS Integration** | Native | Good | Manual |
| **Cost** | Lower | Higher | Depends |
| **Flexibility** | Limited | High | Maximum |
| **Multi-cloud** | No | Yes | Yes |

### **Example: ECS with Fargate**

```bash
# Step 1: Register task definition
aws ecs register-task-definition --cli-input-json file://task-definition.json

# Step 2: Create service
aws ecs create-service \
    --cluster my-cluster \
    --service-name my-app \
    --task-definition my-app:1 \
    --desired-count 3 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[subnet-123],securityGroups=[sg-123]}" \
    --load-balancers "targetGroupArn=arn:...,containerName=app,containerPort=3000"

# Step 3: Check service
aws ecs describe-services \
    --cluster my-cluster \
    --services my-app
```

### **Best Use Cases**

✅ Simple container orchestration
✅ AWS-only deployments
✅ Microservices on AWS
✅ Less operational overhead than K8s
✅ Faster deployment than EKS

---

## **Comparison Table: All Services**

| Service | Type | Abstraction | Cost | Complexity | Best For |
|---------|------|-------------|------|-----------|----------|
| **Fargate** | Serverless Containers | High | Pay per pod | Low | Microservices, bursty |
| **Lambda** | Serverless Functions | Highest | Pay per invocation | Lowest | APIs, event-driven |
| **EC2** | Virtual Machines | Lowest | Pay per hour | High | Databases, legacy |
| **ECS** | Container Orchestration | Medium | Low-Medium | Medium | Simple containers |
| **EKS** | Container Orchestration | Medium | Medium | High | Complex K8s workloads |
| **ECR** | Image Repository | N/A | Low | N/A | Image storage |

---

## **Decision Tree**

```
Need to run code?
│
├─ Short, event-driven
│  └─→ Lambda ✅
│
├─ Containers (stateless)
│  ├─ Simple AWS-only
│  │  └─→ ECS + Fargate ✅
│  └─ Complex, multi-cloud
│     └─→ EKS ✅
│
├─ Containers (stateful/persistent)
│  ├─ Small scale
│  │  └─→ EC2 + Docker ✅
│  └─ Large scale
│     └─→ EKS ✅
│
└─ Long-running, full OS control
   └─→ EC2 ✅
```

---

## **Real-World Example: 2048 Game on Fargate**

```bash
# 1. Create EKS cluster with Fargate support
eksctl create cluster --name demo-cluster --region us-east-1 --fargate

# 2. Create Fargate profile for game namespace
eksctl create fargateprofile \
    --cluster demo-cluster \
    --region us-east-1 \
    --name alb-sample-app \
    --namespace game-2048

# 3. Update kubeconfig
aws eks update-kubeconfig --name demo-cluster --region us-east-1

# 4. Deploy 2048 game (runs on Fargate automatically)
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/examples/2048/2048_full.yaml

# 5. Check pods on Fargate

kubectl describe pod <pod-name> -n game-2048

# 6. Get ALB endpoint
kubectl get ingress -n game-2048
# Visit: http://<ALB-DNS>/

kubectl get svc -n game-2048 -w

# 7. Delete when done
eksctl delete cluster --name demo-cluster --region us-east-1
```

This covers all AWS compute & container services! 🚀


# Commands to configure IAM OIDC provider 

```bash
export cluster_name=demo-cluster
```

```bash
oidc_id=$(aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5) 
```

## Check if there is an IAM OIDC provider configured already

- aws iam list-open-id-connect-providers | grep $oidc_id | cut -d "/" -f4\n 

If not, run the below command

```bash
eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve
```

# How to setup alb add on

Download IAM policy

```bash
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json
```

Create IAM Policy

```bash
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
```

Create IAM Role

```bash
eksctl create iamserviceaccount \
  --cluster=<your-cluster-name> \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::<your-aws-account-id>:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
```

## Deploy ALB controller

Add helm repo

```
helm repo add eks https://aws.github.io/eks-charts
```

Update the repo

```bash
helm repo update eks
```

Install

```bash
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \            
  -n kube-system \
  --set clusterName=<your-cluster-name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=<region> \
  --set vpcId=<your-vpc-id>
```

Verify that the deployments are running.

```bash
kubectl get deployment -n kube-system aws-load-balancer-controller
kubectl edit deploy/aws-load-balancer-controller -n kube-system
```



# AWS EKS Production Deployment: A-Z Guide

## **PHASE 1: FOUNDATIONAL CONCEPTS**

### **WHAT is AWS EKS?**
Elastic Kubernetes Service - AWS's managed Kubernetes control plane. AWS manages the API server, etcd, and scheduler while you manage worker nodes.

### **WHY use EKS?**
- **High availability**: Multi-AZ control plane by default
- **Security**: IAM integration, VPC isolation, encryption
- **Integration**: Native AWS services (RDS, ElastiCache, S3, CloudWatch)
- **Compliance**: Meets enterprise standards (SOC 2, HIPAA, PCI-DSS)
- **No control plane management**: Focus on applications, not infrastructure

### **HOW does it work?**
```
┌─────────────────────────────────────┐
│   AWS Managed Control Plane         │
│ (API Server, etcd, Scheduler)       │
└─────────────────────────────────────┘
           ↓
┌─────────────────────────────────────┐
│   Your VPC + Worker Nodes (EC2)     │
│ (You manage scaling & patching)     │
└─────────────────────────────────────┘
```

---

## **PHASE 2: PLANNING (BEFORE YOU DEPLOY)**

### **Design Decisions**

#### **1. Cluster Architecture**
```yaml
# What to decide:
- Single vs Multi-cluster setup?
- Number of availability zones (2 or 3)?
- Node types: On-demand, Spot, or mixed?
- Pod capacity planning?
```

#### **2. Network Design**
```
WHY: Isolate resources, control traffic
HOW: 
  - VPC with public/private subnets
  - One public subnet per AZ (NAT gateway)
  - Worker nodes in private subnets
  - Security groups for pod-to-pod communication
```

#### **3. Cost Planning**
```
WHAT costs:
- Cluster: $0.10/hour (fixed)
- Worker nodes: EC2 pricing
- Data transfer
- Storage (EBS volumes)
- Load balancers

WHY: Spot instances save 60-90%
HOW: Mix on-demand (stateful) + Spot (stateless)
```

---

## **PHASE 3: PREREQUISITES & SETUP**

### **Step 1: Install Required Tools**
```bash
# On Mac
brew install aws-cli kubectl eksctl helm

# Verify installations
aws --version
kubectl version --client
eksctl version
```

### **Step 2: AWS Credentials**
```bash
# Configure AWS CLI
aws configure
# Enter: Access Key ID, Secret Access Key, Region, Output format

# Verify access
aws sts get-caller-identity
```

### **Step 3: Create VPC (Optional - eksctl can auto-create)**
```bash
# WHY: Dedicated VPC isolates your cluster from other workloads
# WHAT: Need VPC, subnets, route tables, NAT gateways
# HOW: Use CloudFormation or AWS Console
```

---

## **PHASE 4: CREATE EKS CLUSTER**

### **Option A: Using eksctl (RECOMMENDED FOR BEGINNERS)**

```bash
eksctl create cluster \
  --name prod-cluster \
  --region us-east-1 \
  --version 1.29 \
  --nodegroup-name prod-nodegroup \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 2 \
  --nodes-max 10 \
  --managed \
  --spot \
  --zones us-east-1a,us-east-1b,us-east-1c
```

**What each flag does:**
- `--managed`: Use managed node groups (AWS handles patching)
- `--spot`: Use Spot instances (saves 70% cost)
- `--zones`: Multi-AZ for high availability

**Time to create: ~15 minutes**

### **Option B: Using CloudFormation (ADVANCED)**
More control, version control friendly, Infrastructure as Code approach.

### **Verify Cluster Creation**
```bash
# Get cluster info
aws eks describe-cluster --name prod-cluster --region us-east-1

# Get kubeconfig (enables kubectl access)
aws eks update-kubeconfig --name prod-cluster --region us-east-1

# Test connection
kubectl get nodes
```

---

## **PHASE 5: PRODUCTION-GRADE SETUP**

### **Step 1: Configure RBAC (Role-Based Access Control)**

**WHY**: Limit who can do what in your cluster

```bash
# Create namespace for applications
kubectl create namespace production

# Create service account for CI/CD
kubectl create serviceaccount ci-cd -n production

# Create role with limited permissions
kubectl create role deployment-manager \
  --verb=get,create,update \
  --resource=deployments \
  -n production

# Bind role to service account
kubectl create rolebinding ci-cd-role \
  --role=deployment-manager \
  --serviceaccount=production:ci-cd \
  -n production
```

### **Step 2: Set Up IAM Roles for Service Accounts (IRSA)**

**WHY**: Pods need AWS permissions (RDS, S3, Secrets Manager)

```bash
# Enable IRSA on cluster
eksctl utils associate-iam-oidc-provider \
  --cluster=prod-cluster \
  --region=us-east-1 \
  --approve

# Create IAM role for application
eksctl create iamserviceaccount \
  --name app-service-account \
  --namespace production \
  --cluster prod-cluster \
  --region us-east-1 \
  --attach-policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess \
  --approve
```

**In your pod:**
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-service-account
  namespace: production
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: production
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
      serviceAccountName: app-service-account  # Uses IAM role
      containers:
      - name: app
        image: my-app:latest
        env:
        - name: AWS_ROLE_ARN
          value: arn:aws:iam::ACCOUNT_ID:role/...
        - name: AWS_WEB_IDENTITY_TOKEN_FILE
          value: /var/run/secrets/eks.amazonaws.com/serviceaccount/token
```

### **Step 3: Install Container Network Interface (CNI)**

**WHY**: Enables pod-to-pod communication

```bash
# AWS VPC CNI (default, recommended)
# Usually pre-installed, but update it
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install vpc-cni eks/aws-vpc-cni \
  --namespace kube-system \
  --set env.WARM_IP_TARGET=5
```

### **Step 4: Configure Auto-Scaling**

**WHY**: Automatically add nodes when pods can't fit

```bash
# Install Cluster Autoscaler
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm repo update

helm install cluster-autoscaler autoscaler/cluster-autoscaler \
  --namespace kube-system \
  --set autoDiscovery.clusterName=prod-cluster \
  --set awsRegion=us-east-1
```

### **Step 5: Set Up Monitoring & Logging**

```bash
# Install CloudWatch Container Insights
eksctl utils enable-logging \
  --cluster=prod-cluster \
  --logTypes=api,audit,authenticator,controllerManager,scheduler \
  --region=us-east-1
```

**Install Prometheus + Grafana** (Advanced):
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

---

## **PHASE 6: DEPLOY APPLICATIONS**

### **Step 1: Create Deployment**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: production
  labels:
    app: my-app
spec:
  replicas: 3  # High availability
  strategy:
    type: RollingUpdate  # Zero-downtime updates
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      # Pod disruption budget (for cluster updates)
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - my-app
              topologyKey: kubernetes.io/hostname
      
      containers:
      - name: app
        image: my-registry/my-app:1.0.0
        imagePullPolicy: IfNotPresent
        
        # Health checks
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
          
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        
        # Resource limits
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        
        # Environment variables
        env:
        - name: ENVIRONMENT
          value: "production"
        - name: LOG_LEVEL
          value: "info"
        
        ports:
        - containerPort: 8080
          name: http
---
apiVersion: v1
kind: Service
metadata:
  name: my-app
  namespace: production
spec:
  type: LoadBalancer  # Creates AWS Network Load Balancer
  selector:
    app: my-app
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
```

**Deploy it:**
```bash
kubectl apply -f my-app-deployment.yaml

# Verify
kubectl get pods -n production
kubectl get svc -n production
```

### **Step 2: Set Up Ingress (Advanced)**

**WHY**: Route external traffic to services, enable HTTPS

```bash
# Install AWS Load Balancer Controller
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=prod-cluster
```

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  namespace: production
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:...
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
spec:
  rules:
  - host: myapp.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app
            port:
              number: 80
```

---

## **PHASE 7: SECURITY HARDENING**

### **Network Policies**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-nginx
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: my-app
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: nginx-ingress
    ports:
    - protocol: TCP
      port: 8080
```

### **Pod Security Standards**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsReadOnlyRootFilesystem: true
      containers:
      - name: app
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
```

### **Secrets Management**
```bash
# Use AWS Secrets Manager instead of kubectl secrets
eksctl create iamserviceaccount \
  --name secrets-access \
  --cluster prod-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/SecretsManagerReadWrite \
  --approve
```

---

## **PHASE 8: BACKUP & DISASTER RECOVERY**

```bash
# Install Velero for backups
helm repo add velero https://vmware-tanzu.github.io/helm-charts
helm install velero velero/velero \
  --namespace velero \
  --create-namespace \
  --set configuration.backupStorageLocation.bucket=my-backup-bucket \
  --set configuration.backupStorageLocation.provider=aws

# Create daily backup schedule
velero schedule create daily-backup --schedule="0 2 * * *"
```

---

## **PHASE 9: MONITORING & OBSERVABILITY**

### **CloudWatch Monitoring**
```bash
# View cluster logs
kubectl logs deployment/my-app -n production

# View events
kubectl get events -n production --sort-by='.lastTimestamp'

# CloudWatch Insights query
aws logs start-query \
  --log-group-name /aws/eks/prod-cluster/cluster \
  --start-time $(date -d '1 hour ago' +%s) \
  --end-time $(date +%s) \
  --query-string 'fields @timestamp, @message | filter @message like /ERROR/'
```

### **Application Performance Monitoring**
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: app-alerts
spec:
  groups:
  - name: app.rules
    rules:
    - alert: HighErrorRate
      expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "High error rate detected"
```

---

## **PHASE 10: COST OPTIMIZATION**

```bash
# 1. Use Spot Instances
eksctl create nodegroup \
  --cluster prod-cluster \
  --name spot-nodegroup \
  --spot \
  --instance-types t3.medium,t3a.medium,m5.large

# 2. Right-size instances
kubectl top nodes
kubectl top pods -A

# 3. Use Reserved Instances for baseline capacity
# 4. Enable cluster autoscaler (already done above)

# 5. Monitor costs
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --filter file://filter.json \
  --metrics "UnblendedCost"
```

---

## **PHASE 11: ADVANCED PRODUCTION PATTERNS**

### **Multi-Region Setup**
```bash
# Create cluster in second region
eksctl create cluster \
  --name prod-cluster-eu \
  --region eu-west-1 \
  ...

# Use Route53 for failover
aws route53 create-health-check \
  --health-check-config \
  IPAddress=ALB_IP,Port=80,Type=HTTP
```

### **GitOps with ArgoCD**
```bash
# Install ArgoCD
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd --create-namespace

# All deployments via Git
# WHY: Declarative, auditable, easy rollbacks
```

### **Service Mesh (Istio)**
```bash
# Advanced traffic management
istioctl install --set profile=production -y

# Canary deployments
# Traffic mirroring
# Circuit breaking
```

---

## **TROUBLESHOOTING CHECKLIST**

| Issue | Solution |
|-------|----------|
| **Pods pending** | Check node capacity: `kubectl top nodes` |
| **ImagePull errors** | Verify ECR permissions via IRSA |
| **Network issues** | Check security groups, NACL, CNI |
| **High costs** | Review node count, instance types, data transfer |
| **Cluster scaling fails** | Check ASG limits, IAM permissions |

---

## **QUICK COMMANDS REFERENCE**

```bash
# Cluster management
eksctl get cluster
eksctl scale nodegroup --cluster=prod-cluster --name=prod-nodegroup --nodes=5

# Application debugging
kubectl describe pod POD_NAME -n production
kubectl logs POD_NAME -n production --tail=100
kubectl exec -it POD_NAME -n production -- /bin/bash

# Updates
eksctl upgrade cluster --name=prod-cluster
eksctl upgrade nodegroup --cluster=prod-cluster --name=prod-nodegroup
```

---

This covers **Beginner → Advanced** production EKS deployment! Start with Phase 1-4, then add phases 5-11 as your needs grow. 🚀

# Designing for AWS EKS Cluster: Complete Guide

---

## **PHASE 1: ARCHITECTURE DECISIONS**

### **WHAT is EKS Cluster Design?**
Planning the structure, scaling, networking, and resource allocation **before** deploying a production cluster.

### **WHY Design First?**
```
✓ Avoid costly redesigns later
✓ Plan for growth (scaling)
✓ Ensure high availability
✓ Optimize costs
✓ Meet security/compliance requirements
✓ Plan disaster recovery
```

### **HOW: Design Process**

```
Requirement Analysis
         ↓
Architecture Design
         ↓
Capacity Planning
         ↓
Cost Estimation
         ↓
Implementation
         ↓
Monitoring & Optimization
```

---

## **PHASE 2: CLUSTER ARCHITECTURE DESIGN**

### **Question 1: Single Cluster vs Multiple Clusters?**

#### **Single Cluster:**
```yaml
Pros:
  - Simpler management
  - Shared resources (cost-effective)
  - Easier pod communication
  - Centralized monitoring

Cons:
  - Single point of failure
  - Blast radius (one issue affects all apps)
  - Resource contention
  - Harder to scale beyond limits
  - Regional outage = downtime

Use Case:
  - Small to medium projects
  - Single region
  - Non-critical applications
```

#### **Multiple Clusters (Recommended for Production):**
```yaml
Architecture:
  Cluster-1 (us-east-1a) - Production Apps
  Cluster-2 (us-east-1b) - Data Processing
  Cluster-3 (eu-west-1) - EU Users

Pros:
  - High availability (region-level)
  - Isolated workloads
  - Better fault isolation
  - Can scale each independently
  - Disaster recovery

Cons:
  - Complex management
  - Higher costs
  - Cross-cluster communication needed
  - More operational overhead

Use Case:
  - Production systems
  - Multi-region deployments
  - Different SLAs per app
  - Compliance requirements (data residency)
```

#### **Design Decision Matrix:**

```
┌─────────────────────┬──────────────┬─────────────────┐
│ Scenario            │ Single       │ Multi           │
├─────────────────────┼──────────────┼─────────────────┤
│ Startup/MVP         │ ✅ YES       │ ❌ NO           │
│ 100K users          │ ✅ YES       │ ✅ YES (better) │
│ 1M+ users           │ ❌ NO        │ ✅ YES          │
│ Global audience     │ ❌ NO        │ ✅ YES          │
│ PCI-DSS compliance  │ ❌ NO        │ ✅ YES          │
│ Team size <5        │ ✅ YES       │ ❌ NO           │
│ 24/7 uptime (99.99%)│ ❌ NO        │ ✅ YES          │
└─────────────────────┴──────────────┴─────────────────┘
```

---

### **Question 2: Cluster Topology (Availability Zones)**

#### **Single AZ (NOT RECOMMENDED for Production)**
```
┌──────────────────────────┐
│ us-east-1a               │
│ ┌────────────────────┐   │
│ │  EKS Cluster       │   │
│ │  ┌──────────────┐  │   │
│ │  │ Control Plane│  │   │
│ │  └──────────────┘  │   │
│ │  ┌──────────────┐  │   │
│ │  │ Worker Nodes │  │   │
│ │  │ 3-5 nodes    │  │   │
│ │  └──────────────┘  │   │
│ └────────────────────┘   │
└──────────────────────────┘

Availability: 99.5% (downtime: 3.6 hours/year)
RTO/RPO: Minutes to hours
Disaster Recovery: Manual
Cost: Lower

Use Case:
- Dev/Test environments
- Non-critical apps
- Cost-conscious startups
```

#### **Multi-AZ (RECOMMENDED for Production)**
```
┌────────────────┬────────────────┬────────────────┐
│ us-east-1a     │ us-east-1b     │ us-east-1c     │
├────────────────┼────────────────┼────────────────┤
│ ┌────────────┐ │ ┌────────────┐ │ ┌────────────┐ │
│ │EKS Control │ │ │EKS Control │ │ │EKS Control │ │
│ │Plane Replica│ │ │Plane Replica│ │ │Plane Replica│ │
│ └────────────┘ │ └────────────┘ │ └────────────┘ │
│ ┌────────────┐ │ ┌────────────┐ │ ┌────────────┐ │
│ │Worker Nodes│ │ │Worker Nodes│ │ │Worker Nodes│ │
│ │ (2-3)      │ │ │ (2-3)      │ │ │ (2-3)      │ │
│ └────────────┘ │ └────────────┘ │ └────────────┘ │
└────────────────┴────────────────┴────────────────┘

Control Plane: AWS managed (3-replica across AZs)
Availability: 99.95% (downtime: 21 minutes/year)
RTO/RPO: Seconds to minutes
Disaster Recovery: Automatic
Cost: Higher (more nodes needed)

Use Case:
- Production systems
- SLA >99.9%
- Critical business applications
```

**Recommended Design:**
```yaml
Production Cluster:
  - Minimum 3 AZs (us-east-1a, us-east-1b, us-east-1c)
  - Minimum 2 nodes per AZ (6 total for HA)
  - Control Plane: AWS managed (automatic multi-AZ)
  - Pod Distribution: Anti-affinity rules
  
Availability Target: 99.95%
```

---

### **Question 3: Node Group Strategy**

#### **Node Types & Distribution:**

```yaml
Design Pattern: Heterogeneous Node Groups

NodeGroup-1: On-Demand (Stateful Services)
  - Instance type: t3.large
  - Capacity: 30% of total (3 nodes)
  - Cost: $0.1036/hour each
  - Guarantees: Always available
  - Workloads: Database, stateful pods

NodeGroup-2: Spot Instances (Batch/Processing)
  - Instance type: m5.large, m5a.large, m6i.large
  - Capacity: 60% of total (6 nodes)
  - Cost: $0.0336/hour each (68% cheaper)
  - Guarantees: 2-minute termination notice
  - Workloads: Batch jobs, data processing

NodeGroup-3: Reserved (Cost Optimization)
  - Instance type: t3.xlarge
  - Capacity: 10% of total (1 node)
  - Cost: ~$0.05/hour (with 3-year commitment)
  - Guarantees: Permanent reservation
  - Workloads: Baseline/minimum capacity

Total Nodes: 10 (3 On-Demand + 6 Spot + 1 Reserved)
Monthly Cost: ~$700-800
vs Single On-Demand: ~$1,200
Savings: 30-35%
```

**Capacity Distribution Table:**

```
┌──────────────┬────────┬──────────┬──────────┬────────┐
│ Workload     │ Type   │ %        │ Nodes    │ Cost   │
├──────────────┼────────┼──────────┼──────────┼────────┤
│ Databases    │On-Dem  │ 20-30%   │ 2-3      │ High   │
│ Web servers  │On-Dem  │ 20-30%   │ 2-3      │ High   │
│ Batch jobs   │ Spot   │ 40-50%   │ 4-6      │ Low    │
│ Cache layer  │Spot    │ 10-20%   │ 1-2      │ Low    │
└──────────────┴────────┴──────────┴──────────┴────────┘
```

#### **Implementation Example:**

```bash
# NodeGroup 1: On-Demand (Stateful)
eksctl create nodegroup \
  --cluster prod-cluster \
  --name on-demand-nodes \
  --node-type t3.large \
  --nodes 3 \
  --managed \
  --tags Environment=production

# NodeGroup 2: Spot (Stateless)
eksctl create nodegroup \
  --cluster prod-cluster \
  --name spot-nodes \
  --node-type m5.large \
  --nodes 6 \
  --spot \
  --managed \
  --tags Environment=production

# NodeGroup 3: Reserved (Baseline)
eksctl create nodegroup \
  --cluster prod-cluster \
  --name reserved-nodes \
  --node-type t3.xlarge \
  --nodes 1 \
  --managed \
  --tags Environment=production
```

---

## **PHASE 3: NETWORK DESIGN**

### **VPC & Subnet Architecture**

```
┌─────────────────────────────────────────────────────────────┐
│ VPC (10.0.0.0/16)                                           │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ Public Subnets (Internet-facing)                        ││
│ │                                                         ││
│ │ us-east-1a (10.0.1.0/24)    us-east-1b (10.0.2.0/24) ││
│ │ ┌──────────────────────┐   ┌──────────────────────┐   ││
│ │ │ NAT Gateway 1        │   │ NAT Gateway 2        │   ││
│ │ │ ALB/NLB              │   │ ALB/NLB              │   ││
│ │ └──────────────────────┘   └──────────────────────┘   ││
│ └─────────────────────────────────────────────────────────┘│
│          ↓ Route via NAT Gateway                           │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ Private Subnets (Worker Nodes)                          ││
│ │                                                         ││
│ │ us-east-1a (10.0.11.0/24)  us-east-1b (10.0.12.0/24)││
│ │ ┌──────────────────────┐   ┌──────────────────────┐   ││
│ │ │ EKS Worker Nodes     │   │ EKS Worker Nodes     │   ││
│ │ │ RDS, ElastiCache     │   │ RDS, ElastiCache     │   ││
│ │ │ (No inbound from IGW)│   │ (No inbound from IGW)│   ││
│ │ └──────────────────────┘   └──────────────────────┘   ││
│ └─────────────────────────────────────────────────────────┘│
│          ↓ Route via NAT Gateway                           │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ Database Subnets (Private, isolated)                    ││
│ │                                                         ││
│ │ us-east-1a (10.0.21.0/24)  us-east-1b (10.0.22.0/24)││
│ │ ┌──────────────────────┐   ┌──────────────────────┐   ││
│ │ │ RDS Primary          │   │ RDS Replica          │   ││
│ │ │ (No internet access) │   │ (No internet access) │   ││
│ │ └──────────────────────┘   └──────────────────────┘   ││
│ └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

### **Network Design Principles:**

```yaml
Design Rules:

1. Public Subnets:
   - NAT Gateways (1 per AZ for HA)
   - Load Balancers (ALB/NLB)
   - Bastion hosts (optional)
   - Route to IGW

2. Private Subnets (EKS Nodes):
   - Worker nodes
   - Pod network (10.1.0.0/16 typically)
   - Route to NAT Gateway
   - No inbound from internet

3. Database Subnets:
   - RDS, ElastiCache
   - No route to IGW
   - Only accessible from private subnets
   - Network ACL restrictions

4. Pod Networking (CNI):
   - AWS VPC CNI (default)
   - Secondary IP addresses per node
   - Pod CIDR: 10.1.0.0/16 (non-overlapping with VPC)
   
IP Allocation Example:
  VPC: 10.0.0.0/16 (65,536 IPs)
  └─ Public: 10.0.0.0/18 (16,384 IPs)
  └─ Private: 10.0.64.0/18 (16,384 IPs)
  └─ Database: 10.0.128.0/18 (16,384 IPs)
  
  Pods: 10.1.0.0/16 (65,536 IPs) ← Separate from VPC
```

### **Security Group Design:**

```yaml
SG-1: Load Balancer (ALB/NLB)
  Inbound:
    - Port 80 (HTTP): 0.0.0.0/0
    - Port 443 (HTTPS): 0.0.0.0/0
  Outbound:
    - All traffic to EKS nodes SG

---
SG-2: EKS Nodes
  Inbound:
    - Port 10250 (kubelet): From control plane
    - Port 443 (API): From ALB SG
    - Ephemeral ports (1025-65535): From nodes in same SG
  Outbound:
    - All traffic (to internet, RDS, S3, etc)

---
SG-3: RDS Database
  Inbound:
    - Port 3306 (MySQL): From EKS nodes SG only
    - Port 5432 (PostgreSQL): From EKS nodes SG only
  Outbound:
    - None (data is stateless for DB)

---
SG-4: ElastiCache
  Inbound:
    - Port 6379 (Redis): From EKS nodes SG
  Outbound:
    - None
```

---

## **PHASE 4: CAPACITY PLANNING**

### **Calculate Required Resources:**

```yaml
Step 1: Estimate Application Requirements

Application Profile:
  - Current users: 10,000
  - Expected growth: 50% YoY
  - Peak users: 20,000 (2x average)
  - Requests per user: 100/hour
  - Request processing time: 100ms

Total Requests:
  Average: 10,000 users × 100 req/hr = 1M req/day
  Peak: 20,000 × (100 × 2) = 4M req/day (burst)

---

Step 2: Calculate CPU/Memory per Request

Per Request Requirements:
  CPU: 50m (50 millicores)
  Memory: 64Mi (64 MiB)

Example Pod:
  Requests:
    CPU: 500m (0.5 core) → Handles 10 concurrent requests
    Memory: 512Mi
  Limits:
    CPU: 1000m (1 core)
    Memory: 1Gi

---

Step 3: Calculate Replicas Needed

For peak load (4M req/day):
  Requests per pod per day: 10 concurrent × 86400 sec = 864,000 req/day
  Pods needed: 4,000,000 / 864,000 = 4.63 ≈ 5 pods

For HA (3 replicas minimum):
  Recommended: 5 replicas
  
---

Step 4: Calculate Node Capacity

Node Specification: t3.large
  vCPU: 2 cores (2000m)
  Memory: 8Gi

Pods per node:
  CPU: 2000m / 500m = 4 pods per node
  Memory: 8Gi / 512Mi = 16 pods per node
  Limit: MIN(4, 16) = 4 pods

Nodes needed for 5 pods:
  5 pods / 4 pods per node = 1.25 ≈ 2 nodes (with buffer)

---

Step 5: Add Buffer & HA

Total nodes: 2 × 3 AZs = 6 nodes (2 per AZ)
  This provides:
  ✓ 50% spare capacity
  ✓ Node failure tolerance
  ✓ Rolling updates without disruption
  ✓ Cluster autoscaling headroom
```

### **Capacity Planning Table:**

```
┌─────────────────┬──────┬──────┬───────┬──────────┐
│ User Count      │ Pods │ Node │ Type  │ Cost/mo  │
│                 │      │      │       │          │
├─────────────────┼──────┼──────┼───────┼──────────┤
│ 1,000-5,000     │ 2-3  │ 1-2  │ t3.md │ $100-150 │
│ 5,000-50,000    │ 5-10 │ 2-4  │ t3.lg │ $200-400 │
│ 50K-100K        │ 10-2 │ 4-8  │m5.lg  │ $400-800 │
│ 100K-1M         │ 20+ │ 8-16│m5.xlg│$800-2000│
│ 1M+             │ 50+ │ 16+ │ c5.2x │$2000+   │
└─────────────────┴──────┴──────┴───────┴──────────┘

Assumptions:
- Multi-AZ deployment (×3 AZs)
- 50% capacity buffer
- Mixed On-Demand + Spot nodes
```

---

## **PHASE 5: STORAGE DESIGN**

### **Storage Type Selection:**

```yaml
Use Case 1: Application Logs & Temporary Data
  Solution: EmptyDir or Ephemeral Storage
  Characteristics:
    - Lifecycle: Pod lifetime
    - Persistence: None
    - Performance: High
    - Cost: Low (included in node)
  Example:
    - Temp files
    - Cache
    - Log buffers

---

Use Case 2: Database Data (MySQL, PostgreSQL)
  Solution: EBS (Elastic Block Store)
  Type: io1 or gp3 (performance optimized)
  Characteristics:
    - Lifecycle: Long-lived
    - Persistence: Persistent
    - Performance: High (IOPS provisioned)
    - Replication: Multi-AZ snapshots
    - Cost: Higher (~$0.10/GB/month + IOPS)
  Example:
    - StatefulSets for databases
    - MySQL pods with persistent volumes

---

Use Case 3: Shared File System (NFS)
  Solution: EFS (Elastic File System)
  Characteristics:
    - Lifecycle: Persistent
    - Persistence: Multi-AZ automatic
    - Performance: Medium
    - Sharing: Multiple pods/nodes
    - Cost: Lower (~$0.30/GB/month)
  Example:
    - Shared code repositories
    - Training datasets
    - Shared logs

---

Use Case 4: Object Storage (Images, Videos, Archives)
  Solution: S3 (Simple Storage Service)
  Characteristics:
    - Lifecycle: Long-lived
    - Persistence: 11x9 durability
    - Performance: Eventual consistency
    - Sharing: Multi-region, public access
    - Cost: Low (~$0.023/GB/month)
  Example:
    - Container images (ECR)
    - User uploads
    - Backups
    - Static assets

---

Use Case 5: Database Backups & Snapshots
  Solution: S3 + Backup service
  Characteristics:
    - Retention: Long-term
    - Recovery: Point-in-time
    - Cost: Very low (archive tier)
  Example:
    - Daily RDS snapshots
    - Kubernetes etcd backups
    - EBS snapshots
```

### **Storage Capacity Planning:**

```yaml
# Storage Size Estimation:

Database Volume (StatefulSet):
  Database size: 100GB
  Growth rate: 10GB/month
  Retention: 6 months → 100GB current + 60GB growth
  Required size: 200GB
  Provision: 250GB (EBS gp3) at $25/month

Logs (EFS):
  Pod logs: 10GB/day
  Retention: 30 days
  Required: 300GB
  Provision: 350GB (EFS) at $100/month

Backups (S3):
  Daily snapshots: 20GB
  Retention: 90 days
  Required: 1,800GB
  Cost: $40/month (archive tier)

Total Storage Cost: ~$165/month
```

---

## **PHASE 6: SECURITY ARCHITECTURE**

### **Security Design Layers:**

```
┌────────────────────────────────────┐
│ Layer 7: Application Security      │
│ - Input validation                 │
│ - Authorization checks             │
│ - Rate limiting                    │
└────────────────────────────────────┘
         ↓
┌────────────────────────────────────┐
│ Layer 6: Pod Security              │
│ - Pod Security Standards           │
│ - RBAC (Role-based access)         │
│ - Network Policies                 │
└────────────────────────────────────┘
         ↓
┌────────────────────────────────────┐
│ Layer 5: Container Security        │
│ - Image scanning                   │
│ - Read-only root filesystem        │
│ - Non-root user execution          │
└────────────────────────────────────┘
         ↓
┌────────────────────────────────────┐
│ Layer 4: Node Security             │
│ - Security groups                  │
│ - IAM roles (IRSA)                 │
│ - OS hardening                     │
└────────────────────────────────────┘
         ↓
┌────────────────────────────────────┐
│ Layer 3: Network Security          │
│ - VPC isolation                    │
│ - NACLs                            │
│ - Private subnets                  │
└────────────────────────────────────┘
         ↓
┌────────────────────────────────────┐
│ Layer 2: AWS Account Security      │
│ - IAM policies                     │
│ - KMS encryption                   │
│ - CloudTrail logging               │
└────────────────────────────────────┘
         ↓
┌────────────────────────────────────┐
│ Layer 1: Physical Security         │
│ - AWS data center security         │
│ - Access controls                  │
└────────────────────────────────────┘
```

### **Security Implementation Checklist:**

```yaml
✓ Network Security:
  - VPC with private subnets
  - Security groups per tier
  - NACLs for subnet-level filtering
  - VPC Flow Logs enabled
  - GuardDuty for threat detection

✓ Identity & Access:
  - IAM roles for service accounts (IRSA)
  - RBAC with least privilege
  - MFA on root account
  - Temporary credentials (no long-lived keys)

✓ Data Protection:
  - Encryption in transit (TLS)
  - Encryption at rest (KMS, EBS encryption)
  - Secrets Manager for credentials
  - RDS encryption
  - S3 bucket encryption

✓ Container Security:
  - Image scanning (ECR scan on push)
  - Pod Security Standards enforced
  - Read-only root filesystem
  - Drop Linux capabilities
  - Run as non-root user

✓ Compliance:
  - CloudTrail audit logging
  - CloudWatch monitoring
  - Config rules for compliance
  - Regular security assessments
  - Penetration testing
```

---

## **PHASE 7: HIGH AVAILABILITY & DISASTER RECOVERY**

### **RTO/RPO Targets:**

```yaml
RTO (Recovery Time Objective): How fast can we recover?
RPO (Recovery Point Objective): How much data can we lose?

Production Tier:
  RTO: < 5 minutes
  RPO: < 1 minute
  Solution: Multi-AZ cluster + managed backups

Development Tier:
  RTO: < 1 hour
  RPO: < 1 hour
  Solution: Single cluster + daily backups
```

### **HA Design Pattern:**

```yaml
Component: Application (Deployment)
  HA Strategy:
    - Replicas: 3+ (spread across AZs)
    - Pod Disruption Budget: minAvailable=2
    - Anti-affinity: Spread across nodes
  Recovery: Automatic by Kubernetes

Component: Database (RDS)
  HA Strategy:
    - Multi-AZ enabled
    - Automated backup (daily)
    - Read replicas in other regions
  Recovery: AWS automatic failover (<1min)

Component: Cache (ElastiCache Redis)
  HA Strategy:
    - Multi-AZ with automatic failover
    - Cluster mode enabled
    - Backup to S3
  Recovery: Automatic (<1min)

Component: Control Plane (EKS)
  HA Strategy:
    - AWS managed (3 replicas)
    - Multi-AZ by default
  Recovery: Automatic (<1min) - AWS handles

Component: Storage (EBS Volumes)
  HA Strategy:
    - Snapshots every hour
    - Cross-region snapshots weekly
  Recovery: Manual restore (<30min)

Component: Configuration (etcd)
  HA Strategy:
    - Velero backup daily
    - Store in S3
  Recovery: Manual restore (<1hour)
```

### **Backup Strategy:**

```bash
# 1. EKS Cluster Backup (Velero)
helm install velero velero/velero \
  --namespace velero \
  --create-namespace \
  --set configuration.backupStorageLocation.bucket=cluster-backups \
  --set schedule.create=true \
  --set schedule.name=daily-backup \
  --set schedule.schedule="0 2 * * *"

# 2. Database Backup (RDS)
aws rds create-db-cluster-snapshot \
  --db-cluster-identifier prod-db \
  --db-cluster-snapshot-identifier prod-db-$(date +%Y%m%d)

# 3. Configuration Backup (etcd)
kubectl get all --all-namespaces -o yaml > cluster-config-backup.yaml

# Backup retention:
# - Daily: 7 days
# - Weekly: 4 weeks
# - Monthly: 12 months
```

---

## **PHASE 8: MONITORING & OBSERVABILITY DESIGN**

### **Three Pillars of Observability:**

```
┌──────────────────────────────────────────────────┐
│ Metrics (What happened?)                         │
│ - CPU usage: 45%                                 │
│ - Memory: 2.5GB / 8GB                            │
│ - Request latency: 95ms                          │
│ - Error rate: 0.1%                               │
├──────────────────────────────────────────────────┤
│ Logs (Detailed events)                           │
│ - 2024-01-02 10:30:15 ERROR: Connection timeout │
│ - Stack trace: ...                               │
│ - User ID: 12345                                 │
├──────────────────────────────────────────────────┤
│ Traces (Request flow)                            │
│ - Request ID: req-abc123                         │
│ - API call → DB query → Cache lookup             │
│ - Total duration: 150ms                          │
└──────────────────────────────────────────────────┘
```

### **Monitoring Stack Design:**

```yaml
Metrics Collection:
  Tool: Prometheus
  Scrape interval: 15 seconds
  Data retention: 15 days (local)
  Storage: S3 for long-term archival

Visualization:
  Tool: Grafana
  Dashboards:
    - Cluster health (CPU, memory, network)
    - Application metrics (req/sec, latency, errors)
    - Business metrics (users, revenue)

Log Aggregation:
  Tool: CloudWatch or ELK Stack
  Log groups:
    - /aws/eks/cluster/api-server
    - /aws/eks/cluster/audit
    - /application/logs/prod

Alerting:
  Tool: AlertManager + PagerDuty
  Alert levels:
    - Critical: Page on-call
    - Warning: Slack notification
    - Info: Dashboard only

Tracing:
  Tool: Jaeger or X-Ray
  Sample rate: 10% (cost optimization)

Cost: ~$500-1000/month for full stack
```

---

## **PHASE 9: COST OPTIMIZATION DESIGN**

### **Cost Components:**

```
┌─────────────────────────────────────────┐
│ Monthly EKS Costs                       │
├─────────────────────────────────────────┤
│ EKS Control Plane:      $73              │
│ Worker Nodes:           $400-600         │
│ Data Transfer:          $50-100          │
│ Load Balancer:          $16-25/month     │
│ Storage (EBS/EFS):      $100-200         │
│ RDS Database:           $200-400         │
│ ElastiCache:            $50-100          │
│ CloudWatch/Logs:        $50-100          │
│ Backup (S3):            $20-50           │
├─────────────────────────────────────────┤
│ TOTAL:                  $960-1,545       │
└─────────────────────────────────────────┘
```

### **Cost Optimization Strategies:**

```yaml
1. Instance Right-sizing (15-20% savings)
   - Analyze actual usage
   - Downsize from t3.xlarge → t3.large
   - Use t3a (AMD) instead of t3 (Intel)

2. Spot Instances (60-90% savings)
   - Use for stateless workloads
   - Batch jobs, caching layers
   - Diversify instance types

3. Reserved Instances (30-50% savings)
   - For baseline capacity
   - 1-year commitment
   - Blend with on-demand

4. Auto-Scaling (20-30% savings)
   - Scale down during off-peak
   - Schedule-based (night: 50% capacity)
   - Metrics-based (CPU <20%: scale down)

5. Data Transfer Optimization (10-15% savings)
   - Use S3 Gateway endpoints (no NAT cost)
   - DynamoDB endpoints
   - CloudFront for static content

6. Storage Optimization (10-20% savings)
   - EBS gp3 instead of io1
   - S3 Intelligent-Tiering
   - Archive old snapshots

7. Resource Requests/Limits
   - Accurate requests (avoid overprovisioning)
   - Proper limits (prevent waste)
   - Pod density optimization

Example Savings:
  Baseline cost: $1,500/month
  After optimization: $900/month (40% reduction)
```

---

## **PHASE 10: OPERATIONAL DESIGN**

### **Deployment Strategy:**

```yaml
GitOps Approach (Recommended):
  Tool: ArgoCD or Flux
  
  Workflow:
    1. Developer commits code to Git
    2. CI pipeline builds Docker image
    3. CD pipeline updates manifests in Git
    4. ArgoCD detects Git changes
    5. ArgoCD applies to cluster
  
  Benefits:
    ✓ Audit trail (Git history)
    ✓ Easy rollback
    ✓ Declarative
    ✓ Infrastructure as Code

Deployment Strategies:

1. Blue-Green Deployment
   - Deploy new version (Green)
   - Test thoroughly
   - Switch traffic (Blue → Green)
   - Risk: Double resources during deploy
   
2. Canary Deployment
   - Deploy to 5% of pods
   - Monitor for errors
   - Gradually increase to 100%
   - Risk: Minimal (only 5% affected)
   
3. Rolling Update (Default)
   - Update 1 pod at a time
   - Zero downtime
   - Slowest deployment
```

### **Update Strategy:**

```yaml
# Cluster Updates:
  1. Monthly security patches
  2. Quarterly version upgrades
  3. Always update control plane first
  4. Then update node groups
  5. Test in staging first

Application Updates:
  - Automated testing (unit, integration, e2e)
  - Automated deployment to dev
  - Manual approval to production
  - Automated rollback on errors
```

---

## **COMPLETE DESIGN EXAMPLE**

### **Startup Scenario: Photo Sharing App**

```yaml
Scenario:
  - Starting with 5,000 users
  - Expected 50% growth/year
  - Budget: $1,500/month

Architecture Decision:

Clustering:
  ✓ Single cluster (cost-effective for startup)
  ✓ Multi-AZ (still affordable with spot instances)
  ✓ Location: us-east-1 (cheapest region)

Nodes:
  NodeGroup-1 (API servers): 2× t3.large On-Demand
  NodeGroup-2 (Processing): 4× m5.large Spot
  NodeGroup-3 (Cache): 1× t3.large On-Demand
  
  Total: 7 nodes ≈ $600/month

Networking:
  VPC: 10.0.0.0/16
  Public: 10.0.0.0/24, 10.0.1.0/24 (2 AZs)
  Private: 10.0.11.0/24, 10.0.12.0/24
  NAT: 1 per AZ
  Pods: 10.1.0.0/16

Storage:
  Application data: RDS (MySQL, Multi-AZ) $150/mo
  User uploads: S3 + CloudFront $50/mo
  Logs: EFS $20/mo
  Backups: S3 Glacier $10/mo

Monitoring:
  Prometheus + Grafana: Self-hosted in cluster (free)
  CloudWatch logs: $30/month
  Alerting: Slack integration (free)

Total Cost Breakdown:
  Cluster: $73
  Nodes: $600
  RDS: $150
  Storage: $80
  Monitoring: $30
  Misc: $50
  ──────────────
  TOTAL: ~$983/month
```

---

## **DESIGN CHECKLIST**

```
✓ Architecture
  □ Single or multi-cluster?
  □ Multi-AZ distribution
  □ Node group strategy (on-demand + spot)

✓ Networking
  □ VPC CIDR blocks
  □ Public/Private/Database subnets
  □ Security group rules
  □ Pod networking (CNI)

✓ Capacity
  □ Current user count
  □ Growth projections
  □ Peak load estimation
  □ Resource requests/limits

✓ Storage
  □ EBS for databases
  □ EFS for shared data
  □ S3 for objects
  □ Backup strategy

✓ Security
  □ Network isolation
  □ RBAC policies
  □ IRSA for pod permissions
  □ Encryption (transit & rest)

✓ HA/DR
  □ Multi-AZ setup
  □ RTO/RPO targets
  □ Backup frequency
  □ Failover plan

✓ Monitoring
  □ Metrics collection
  □ Log aggregation
  □ Alerting rules
  □ Dashboard design

✓ Operations
  □ GitOps deployment
  □ Update strategy
  □ Rollback procedures
  □ Runbooks

✓ Costs
  □ Cost estimation
  □ Optimization strategies
  □ Reserved instance commitments
  □ Monitoring budget
```

---

## **QUICK REFERENCE: Design Templates**

### **Template 1: Startup (< 10K users)**
```
Cluster: Single, Multi-AZ
Nodes: 3× t3.medium on-demand + 3× m5.large spot
Cost: ~$400-500/month
SLA: 99.5%
```

### **Template 2: Growth Stage (10K-100K users)**
```
Cluster: Single, Multi-AZ
Nodes: 6× t3.large mixed + 6× m5.xlarge spot
Cost: ~$800-1,000/month
SLA: 99.9%
```

### **Template 3: Scale (100K-1M+ users)**
```
Cluster: Multi (prod, staging, batch)
Nodes: 20+ mixed instance types
Cost: ~$3,000+/month
SLA: 99.95%+
```

---

**Key Takeaway:** Good design means you build for growth, scale efficiently, and avoid costly redesigns later! 🚀