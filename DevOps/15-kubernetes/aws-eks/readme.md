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



