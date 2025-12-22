# AWS Services Comprehensive Guide ☁️

Overview of critical AWS services for cloud infrastructure.

---

## Compute Services

### EC2 (Elastic Compute Cloud)
**Purpose:** Virtual machines (compute instances)

- Instance types & sizing
- Auto Scaling groups
- Elastic IP for persistent addresses
- Security groups for network control

**Use Cases:** Web servers, application servers, batch processing

---

### Lambda
**Purpose:** Serverless compute (short, event-triggered tasks)

- Functions as a service
- Automatic scaling
- Event-driven execution
- Pay per invocation

**Use Cases:** API backends, data processing, scheduled tasks

---

### ECS (Elastic Container Service)
**Purpose:** Container orchestration (AWS proprietary)

- Docker container management
- Task definitions
- Service scheduling

**Use Cases:** Containerized applications, microservices

---

### EKS (Elastic Kubernetes Service)
**Purpose:** Managed Kubernetes service

- Full Kubernetes support
- AWS-managed control plane
- Auto-scaling

**Use Cases:** Complex containerized workloads, Kubernetes expertise

---

### Fargate
**Purpose:** Serverless container compute

- Run containers without managing servers
- Automatic scaling
- Pay per container usage

**Use Cases:** Containerized applications without infrastructure management

---

## Storage Services

### S3 (Simple Storage Service)
**Purpose:** Object storage (files, data)

- **Encrypted by default** (SSE-S3)
- Versioning & lifecycle policies
- CloudFront integration
- Bucket policies & ACLs

**Use Cases:** File storage, backups, data lake, static website hosting

---

### EBS (Elastic Block Store)
**Purpose:** Block storage for EC2 instances

- Persistent volumes
- Snapshots for backups
- Multiple volume types (gp3, io1, st1)

**Use Cases:** Database storage, application data, OS volumes

---

## Database Services

### RDS (Relational Database Service)
**Purpose:** Managed relational databases

- **Engines:** MySQL, PostgreSQL, Oracle, SQL Server, MariaDB
- Multi-AZ for high availability
- Read replicas for scaling reads
- Automated backups
- Encryption support

**Use Cases:** Web applications, OLTP systems, traditional databases

---

### DynamoDB
**Purpose:** NoSQL database (key-value & document)

- **Serverless** - no capacity planning
- Auto-scaling
- Global tables for replication
- Real-time data

**Use Cases:** Mobile apps, real-time analytics, IoT applications

---

## Networking Services

### VPC (Virtual Private Cloud)
**Purpose:** Private, secure network

- **Private subnets** for internal resources
- **Public subnets** for internet-facing resources
- **Security groups** for inbound/outbound rules
- **NACLs** (Network ACLs) for subnet-level control
- Route tables for traffic routing

**Use Cases:** Network isolation, security segmentation

---

### CloudFront
**Purpose:** Content Delivery Network (CDN)

- Global edge locations
- Cache & serve content faster
- Reduce latency
- DDoS protection

**Use Cases:** Static content delivery, website acceleration

---

## Security & Access

### IAM (Identity & Access Management)
**Purpose:** Security/permissions management

- Users & groups
- Roles & policies
- Permissions fine-tuning
- MFA support

**Use Cases:** Access control, least-privilege principle

---

### KMS (Key Management Service)
**Purpose:** Encryption key management

- Create & manage encryption keys
- Encryption at rest
- Encryption in transit

**Use Cases:** Sensitive data encryption, compliance

---

## Monitoring & Management

### CloudWatch
**Purpose:** Monitoring, logging, alerts

- Metrics collection
- Log aggregation
- Alarms & notifications
- Dashboard creation

**Use Cases:** Application monitoring, infrastructure health

---

### CloudTrail
**Purpose:** API audit logging

- Record all API calls
- Compliance & forensics
- User activity tracking

**Use Cases:** Security auditing, compliance reporting

---

### Config
**Purpose:** Configuration management

- Resource tracking
- Change history
- Compliance checking
- Configuration snapshots

**Use Cases:** Compliance, change management

---

## CI/CD Services

### CodeBuild
**Purpose:** Build service for CI/CD

- Compile code
- Run tests
- Package applications

**Use Cases:** Automated builds, testing

---

### CodePipeline
**Purpose:** Orchestrate CI/CD workflows

- Coordinate build, test, deploy stages
- Integration with other services
- Approval gates

**Use Cases:** Automated deployment pipelines

---

### CodeDeploy
**Purpose:** Automated deployment service

- Deploy to EC2 instances
- On-premises servers
- Lambda functions

**Use Cases:** Application deployment automation

---

## Service Summary Table

| Service | Type | Purpose |
|---------|------|---------|
| **EC2** | Compute | Virtual machines |
| **Lambda** | Compute | Serverless functions |
| **ECS** | Container | Docker orchestration |
| **EKS** | Container | Kubernetes service |
| **S3** | Storage | Object storage |
| **EBS** | Storage | Block storage |
| **RDS** | Database | Relational databases |
| **DynamoDB** | Database | NoSQL database |
| **VPC** | Networking | Virtual network |
| **CloudFront** | Networking | Content delivery |
| **IAM** | Security | Access control |
| **KMS** | Security | Key management |
| **CloudWatch** | Monitoring | Observability |
| **CloudTrail** | Monitoring | Audit logging |
| **CodeBuild** | CI/CD | Build service |
| **CodePipeline** | CI/CD | Pipeline orchestration |
| **CodeDeploy** | CI/CD | Deployment |

---

## Architecture Best Practices

✅ **High Availability**
- Multi-AZ deployments (RDS, ALB)
- Auto Scaling groups
- Read replicas

✅ **Security**
- IAM policies (least privilege)
- Encryption (KMS, SSE)
- Security groups & NACLs
- VPC isolation

✅ **Performance**
- CloudFront CDN
- RDS read replicas
- Auto Scaling
- Caching strategies

✅ **Cost Optimization**
- Reserved Instances
- Spot Instances
- Auto Scaling
- Lifecycle policies

---

**Last Updated:** December 22, 2025
