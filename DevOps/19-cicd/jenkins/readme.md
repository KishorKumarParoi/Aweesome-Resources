# Jenkins: Complete Guide from Beginner to Advanced

## Table of Contents
1. [Jenkins Fundamentals](#jenkins-fundamentals)
2. [Installation & Setup](#installation--setup)
3. [Beginner Concepts](#beginner-concepts)
4. [Intermediate Topics](#intermediate-topics)
5. [Advanced Topics](#advanced-topics)
6. [Best Practices](#best-practices)
7. [Real-World Examples](#real-world-examples)
****
---

# Jenkins Fundamentals

## What is Jenkins?

Jenkins is an open-source automation server that enables developers and DevOps teams to automate parts of software development such as building, testing, and deployment.

### Why Jenkins?

**Question: Why do we need Jenkins?**

- **Continuous Integration (CI):** Automatically build and test code changes as developers commit to the repository
- **Continuous Deployment (CD):** Automatically deploy tested code to production
- **Reduce Human Error:** Eliminates manual, repetitive tasks prone to mistakes
- **Faster Feedback:** Developers get immediate feedback on code quality issues
- **Cost Savings:** Reduces manual work and speeds up release cycles
- **Scalability:** Can handle large projects with distributed builds across multiple machines
- **Community:** Extensive plugin ecosystem (over 1800+ plugins available)

### Key Features

- **Pipeline as Code:** Define CI/CD workflows in code (Declarative & Scripted pipelines)
- **Distributed Builds:** Run tests and builds on multiple machines/agents
- **Extensibility:** Plugin architecture for integrations (Git, Docker, Kubernetes, AWS, etc.)
- **Easy Installation:** Simple setup on any OS (Linux, Windows, macOS)
- **Web UI:** User-friendly interface for job creation and monitoring
- **REST API:** Programmatically interact with Jenkins

---

# Installation & Setup

## Jenkins Installation on Ubuntu

### Step 1: Install Java

Jenkins requires Java 8 or later:

```bash
sudo apt-get update
sudo apt-get install -y default-jdk
java -version
```

### Step 2: Add Jenkins Repository

```bash
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
```

### Step 3: Install Jenkins

```bash
sudo apt-get update
sudo apt-get install -y jenkins
```

### Step 4: Start Jenkins Service

```bash
sudo systemctl start jenkins
sudo systemctl enable jenkins    # Enable auto-start on boot
sudo systemctl status jenkins
```

### Step 5: Access Jenkins Web UI

Jenkins runs on port 8080 by default. Access it at:

```
http://localhost:8080
```

### Step 6: Initial Setup

1. Get the initial admin password:
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

2. Install suggested plugins (recommended for beginners)
3. Create admin user account
4. Configure Jenkins URL

---

## Change Jenkins Port (Optional)

**Why change the port?** Port 8080 might already be in use or you might want to use a standard port like 80 or 443.

Edit the Jenkins configuration:

```bash
sudo nano /etc/default/jenkins
```

Find the line:
```
HTTP_PORT=8080
```

Change it to:
```
HTTP_PORT=5000
```

Restart Jenkins:
```bash
sudo systemctl restart jenkins
```

---

# Beginner Concepts

## 1. What is a Job/Project?

A **Job** (or **Project**) is a unit of work that Jenkins executes. It contains:
- Source code repository configuration
- Build steps (commands to run)
- Post-build actions (notifications, deployments, etc.)
- Triggers (when to run)

### Why Jobs?

- **Reproducibility:** Same job always produces consistent results
- **Automation:** Run the same process without manual intervention
- **Tracking:** History of all executions with logs and artifacts

### Types of Jobs

1. **Freestyle Job:** Basic job type with UI configuration
2. **Pipeline Job:** Complex workflows defined in code
3. **Multi-branch Pipeline:** Auto-create jobs for each branch
4. **Scripted Pipeline:** Groovy-based pipeline
5. **Declarative Pipeline:** YAML-like syntax (easier for beginners)

---

## 2. Build Triggers

**What are build triggers?**

Build triggers are events that automatically start a job execution.

### Why Build Triggers?

**Question: Why do we need triggers instead of manually running jobs?**

- **Continuous Integration:** Automatically test code when developers push changes
- **Schedule Builds:** Run jobs at specific times (nightly builds, weekly tests)
- **Event-Driven:** React to external events (GitHub push, webhook, etc.)
- **Dependency Management:** Trigger downstream jobs when upstream completes

### Common Triggers

#### 1. **Poll SCM (Source Control Management)**

**Why use Poll SCM?**
- Checks repository periodically for changes
- Doesn't require webhook configuration

```
H H * * *    # Run daily at midnight
H/15 * * * * # Run every 15 minutes
```

#### 2. **Webhook Trigger (GitHub, GitLab)**

**Why use Webhooks?**
- **Instant Feedback:** Triggered immediately when code is pushed
- **Efficient:** No polling overhead
- **Exact Triggers:** Only runs when actual changes occur

Configuration:
- Set webhook in GitHub: `http://jenkins-url:8080/github-webhook/`
- Ensure "Trigger events for push" is selected

#### 3. **Scheduled Build (Cron)**

**Why schedule builds?**
- Run tests during off-peak hours
- Generate periodic reports
- Maintenance tasks

```bash
# Syntax: Minute Hour Day Month Day-of-Week
0 2 * * *    # Run at 2:00 AM daily
0 0 * * 0    # Run at midnight every Sunday
15 3 * * 1-5 # Run at 3:15 AM Monday-Friday
```

#### 4. **Upstream Job Trigger**

**Why trigger from upstream jobs?**
- **Build Pipelines:** Job A completes → triggers Job B → triggers Job C
- **Dependency Chain:** Ensures correct execution order

---

## 3. Build Steps

**What are build steps?**

Build steps are individual commands/scripts executed in sequence during a build.

### Why Build Steps?

- **Modularity:** Break complex processes into smaller steps
- **Clarity:** Easy to identify which step failed
- **Reusability:** Same steps in multiple jobs

### Common Build Steps

#### Shell Script (Linux/Mac)

```bash
#!/bin/bash
echo "Starting build..."
cd /path/to/project
npm install
npm test
npm run build
```

#### Batch Script (Windows)

```batch
@echo off
echo Starting build...
cd C:\path\to\project
npm install
npm test
```

#### Execute Maven

Why use specialized steps?
- Pre-configured environment
- Better error handling
- Integration-specific optimizations

```
Goal: clean package
POM file: pom.xml
```

---

## 4. Post-Build Actions

**What are post-build actions?**

Actions executed after the build completes (success or failure).

### Why Post-Build Actions?

- **Notifications:** Alert team of build results
- **Artifact Storage:** Save build outputs
- **Deployment:** Deploy to staging/production
- **Metrics:** Track build performance

### Common Post-Build Actions

1. **Email Notifications**
   - Notify on failure or always
   - Attach build logs or artifacts

2. **External Tools**
   - Trigger webhooks
   - Call REST APIs
   - Deploy to servers

3. **Archive Artifacts**
   - Save compiled files
   - Store test reports
   - Keep Docker images

---

## 5. The Build Lifecycle

```
Trigger → Source Code Checkout → Build Steps → Test → Archive Artifacts → Post-Build Actions → Complete
```

### Why This Order?

1. **Fetch Latest Code:** Ensure building latest version
2. **Build:** Compile and package
3. **Test:** Validate functionality
4. **Archive:** Store outputs for reuse
5. **Post-Actions:** Notify and deploy

---

# Intermediate Topics

## 1. Pipelines vs Freestyle Jobs

### Freestyle Jobs

**Structure:**
- UI-based configuration
- Simple for small projects
- Limited reusability

**Example:**
```
Job: Build Java App
├── Trigger: Poll SCM every 5 minutes
├── Build Step: Execute Maven
├── Post-Build: Archive artifacts
└── Post-Build: Email notification
```

### Jenkinsfile (Pipeline)

**Why use Pipelines?**

**Question: Why move from Freestyle to Pipeline?**

- **Version Control:** Store pipeline definition in Git with code
- **Complex Workflows:** Support for loops, conditions, parallel execution
- **Reusability:** Define shared pipeline libraries
- **Better Error Handling:** Fine-grained error recovery
- **Stages:** Clear visualization of workflow stages
- **Best Practice:** Industry standard for CI/CD

### Declarative Pipeline Example

```groovy
pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                sh 'npm install'
                sh 'npm run build'
            }
        }
        
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'  // Only deploy from main branch
            }
            steps {
                sh 'npm run deploy'
            }
        }
    }
    
    post {
        always {
            junit 'test-results.xml'  // Archive test results
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
```

### Scripted Pipeline Example

```groovy
node {
    try {
        stage('Checkout') {
            checkout scm
        }
        
        stage('Build') {
            sh 'npm install'
            sh 'npm run build'
        }
        
        stage('Test') {
            sh 'npm test'
        }
        
        stage('Deploy') {
            if (env.BRANCH_NAME == 'main') {
                sh 'npm run deploy'
            }
        }
    } catch (Exception e) {
        echo "Pipeline failed: ${e.message}"
        throw e
    }
}
```

### Key Differences

| Aspect | Freestyle | Declarative Pipeline | Scripted Pipeline |
|--------|-----------|----------------------|-------------------|
| **Configuration** | UI | Code (Groovy-like) | Code (Groovy) |
| **Version Control** | Manual backup | In Git | In Git |
| **Complexity** | Simple | Medium | Advanced |
| **Error Handling** | Limited | Good | Excellent |
| **Learning Curve** | Easy | Medium | Steep |
| **Best For** | Simple builds | Most projects | Complex workflows |

---

## 2. Agents and Executors

### Concept: Master and Agents

**Why use Agents?**

**Question: Why not run everything on Jenkins master?**

- **Isolation:** Keep master stable; run tests on separate machines
- **Scalability:** Distribute work across multiple machines
- **Resource Dedicated:** Different agents for different tasks (Java, Node, Python, etc.)
- **Resilience:** Failure on one agent doesn't affect master
- **Performance:** Parallel execution on multiple agents

### Architecture

```
Jenkins Master (Orchestrator)
│
├── Executor 1 (Java Build)
├── Executor 2 (Node Build)
│
├── Agent A (Linux Server 1)
│   ├── Executor 1
│   └── Executor 2
│
└── Agent B (Linux Server 2)
    ├── Executor 1
    └── Executor 2
```

### Configuration Example

**Create a new Agent:**

1. Jenkins Dashboard → Manage Jenkins → Manage Nodes
2. New Node → Permanent Agent
3. Configure connection method (SSH, JNLP, etc.)

**Use Agent in Jenkinsfile:**

```groovy
pipeline {
    agent {
        label 'linux'  // Run on agent labeled 'linux'
    }
    
    stages {
        stage('Build') {
            steps {
                sh 'npm install && npm run build'
            }
        }
    }
}
```

---

## 3. Jenkins Plugins

**What are plugins?**

Plugins extend Jenkins functionality by adding integrations with external tools and services.

### Why Plugins?

- **Integration:** Connect with Git, Docker, Kubernetes, AWS, Slack, etc.
- **Customization:** Tailor Jenkins to specific needs
- **Community:** Leverage 1800+ community-contributed plugins
- **Reduced Coding:** Use pre-built functionality

### Essential Plugins

```
1. Pipeline (Declarative & Scripted)
2. Git Plugin (GitHub integration)
3. Docker Plugin (Container support)
4. Kubernetes Plugin (K8s orchestration)
5. Blue Ocean (Better UI for pipelines)
6. Email Extension (Advanced email notifications)
7. Credentials Binding (Secure credential management)
8. Performance Plugin (Performance tracking)
```

### Install Plugins

1. Jenkins Dashboard → Manage Jenkins → Manage Plugins
2. Search for plugin → Install → Restart Jenkins

### Example: Using Docker Plugin

```groovy
pipeline {
    agent {
        docker {
            image 'node:16'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    
    stages {
        stage('Build') {
            steps {
                sh 'npm install && npm run build'
            }
        }
    }
}
```

---

## 4. Credentials Management

**Why secure credential management?**

**Question: Why not hardcode credentials in Jenkinsfiles?**

- **Security:** Credentials never exposed in logs or code
- **Audit Trail:** Track who accessed what credentials
- **Rotation:** Update credentials without changing pipelines
- **Separation of Concerns:** Different credentials for different environments

### Types of Credentials

1. **Username & Password**
2. **SSH Keys**
3. **API Tokens**
4. **Secret Text**
5. **Certificate Files**

### Store Credentials

1. Jenkins Dashboard → Manage Jenkins → Manage Credentials
2. Click "Global" domain → Add Credentials
3. Select credential type and fill details

### Use Credentials in Jenkinsfile

```groovy
pipeline {
    environment {
        DOCKER_CREDS = credentials('docker-hub-credentials')
        AWS_CREDS = credentials('aws-credentials')
    }
    
    stages {
        stage('Push Docker Image') {
            steps {
                sh '''
                    echo $DOCKER_CREDS_PSW | docker login -u $DOCKER_CREDS_USR --password-stdin
                    docker push myimage:latest
                '''
            }
        }
    }
}
```

---

## 5. Parallel Execution

**Why run jobs in parallel?**

**Question: Why wait for sequential execution when we can run in parallel?**

- **Faster Builds:** Reduce overall build time
- **Resource Utilization:** Use multiple agents simultaneously
- **Real-World Optimization:** Test frontend and backend simultaneously

### Parallel Pipeline Example

```groovy
pipeline {
    agent any
    
    stages {
        stage('Parallel Tests') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'npm run test:unit'
                    }
                }
                
                stage('Integration Tests') {
                    steps {
                        sh 'npm run test:integration'
                    }
                }
                
                stage('Lint') {
                    steps {
                        sh 'npm run lint'
                    }
                }
            }
        }
        
        stage('Build') {
            steps {
                sh 'npm run build'
            }
        }
    }
}
```

---

## 6. Conditional Execution

**Why conditional execution?**

- **Environment-Specific:** Different steps for development vs production
- **Branch-Specific:** Deploy only from main branch
- **Status-Based:** Run additional tests on failure

### Examples

```groovy
pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                sh 'npm run build'
            }
        }
        
        stage('Deploy to Staging') {
            when {
                branch 'develop'  // Only on develop branch
            }
            steps {
                sh 'npm run deploy:staging'
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'    // Only on main branch
                tag pattern: "v\\d+\\.\\d+\\.\\d+", comparator: "REGEXP"  // Tag matching
            }
            steps {
                sh 'npm run deploy:prod'
            }
        }
        
        stage('Notify Slack') {
            when {
                expression {
                    currentBuild.result == 'FAILURE'
                }
            }
            steps {
                sh 'curl -X POST -H "Content-type: application/json" ...'
            }
        }
    }
}
```

---

# Advanced Topics

## 1. Shared Libraries

**What are shared libraries?**

Groovy code shared across multiple pipelines to avoid duplication.

### Why Shared Libraries?

**Question: Why use shared libraries?**

- **DRY Principle:** Don't Repeat Yourself
- **Consistency:** Same functionality across projects
- **Maintenance:** Update once, affects all pipelines
- **Reusability:** Create utility functions for common tasks

### Project Structure

```
shared-library/
├── src/
│   └── com/myorg/
│       ├── Build.groovy
│       ├── Deploy.groovy
│       └── Notify.groovy
├── vars/
│   ├── buildApp.groovy
│   ├── deployApp.groovy
│   └── notifySlack.groovy
└── resources/
    └── config.xml
```

### Example: Global Functions

**File: `vars/buildApp.groovy`**

```groovy
def call(String language, String command) {
    echo "Building ${language} project..."
    sh command
    echo "Build completed!"
}
```

**File: `vars/deployApp.groovy`**

```groovy
def call(String environment, String service) {
    echo "Deploying to ${environment}..."
    sh "ansible-playbook deploy-${environment}.yml -e service=${service}"
}
```

### Use in Jenkinsfile

```groovy
@Library('shared-library@main') _

pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                buildApp('nodejs', 'npm install && npm run build')
            }
        }
        
        stage('Deploy') {
            steps {
                deployApp('staging', 'api')
            }
        }
    }
}
```

---

## 2. Jenkins Kubernetes Plugin

**Why Kubernetes + Jenkins?**

**Question: Why use Kubernetes with Jenkins?**

- **Dynamic Agents:** Spin up agents on-demand
- **Cost Efficient:** Scale down when not needed
- **Isolation:** Each build runs in separate container
- **Modern Infrastructure:** Cloud-native approach

### Configuration

**Jenkinsfile Example:**

```groovy
pipeline {
    agent {
        kubernetes {
            yaml '''
                apiVersion: v1
                kind: Pod
                spec:
                  serviceAccountName: jenkins
                  containers:
                  - name: docker
                    image: docker:20.10
                    command: ['cat']
                    tty: true
                    volumeMounts:
                    - name: docker-socket
                      mountPath: /var/run/docker.sock
                  volumes:
                  - name: docker-socket
                    hostPath:
                      path: /var/run/docker.sock
            '''
        }
    }
    
    stages {
        stage('Build Docker Image') {
            steps {
                container('docker') {
                    sh 'docker build -t myapp:latest .'
                    sh 'docker push myregistry/myapp:latest'
                }
            }
        }
    }
}
```

---

## 3. Blue Ocean

**What is Blue Ocean?**

A modern UI for visualizing Jenkins pipelines with better user experience.

### Why Blue Ocean?

- **Visual Pipeline:** See workflow as a graph
- **Better UX:** Cleaner interface than classic Jenkins UI
- **Easier Debugging:** Quick access to logs at each stage
- **Real-time Feedback:** Live updates during pipeline execution

### Access Blue Ocean

```
http://jenkins-url:8080/blue
```

### Key Features

- **Pipeline View:** Visual representation of all stages
- **Branch View:** See pipelines for all branches
- **Credentials Management:** Manage credentials from UI
- **Editor:** Create/edit pipelines graphically

---

## 4. Jenkins Distributed Builds

### Architecture

```
Master Node (Jenkins Controller)
│
├── Agent 1: Label 'docker-build'
├── Agent 2: Label 'test-linux'
└── Agent 3: Label 'test-windows'
```

### Why Distributed Builds?

- **Parallel Execution:** Multiple builds simultaneously
- **Platform-Specific:** Windows tests on Windows agent, Linux on Linux
- **Load Distribution:** Spread load across machines
- **Reliability:** Master remains stable

### Setup

**Agent Communication Methods:**

1. **SSH:** Secure Shell connection
2. **JNLP:** Java Network Launch Protocol
3. **WebSocket:** Browser-based communication

**Example: Setup SSH Agent**

```bash
# On Agent Machine
ssh-keygen -t rsa -N "" -f /home/jenkins/.ssh/id_rsa

# Jenkins UI
# Manage Jenkins → Manage Nodes
# New Node → Configure with SSH connection
# Host: agent-ip
# Credentials: Use SSH key
```

---

## 5. Jenkins with Git Workflow

### Multi-Branch Pipelines

**Why multi-branch pipelines?**

**Question: Why use multi-branch pipelines?**

- **Automatic Job Creation:** Each branch automatically gets a job
- **Pull Request Testing:** Auto-test PRs before merge
- **Branch-Specific Logic:** Different pipelines for different branches

### Configuration

```groovy
// Jenkinsfile in repository root

pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                sh 'npm install && npm run build'
            }
        }
        
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh 'npm run deploy:prod'
            }
        }
    }
}
```

**Setup Multi-branch Pipeline:**

1. Jenkins Dashboard → New Item
2. Select "Multibranch Pipeline"
3. Configure repository branch source
4. Save

### GitHub Pull Request Builder

**Why PR Builder?**

- **Pre-merge Testing:** Test code before merging to main
- **Feedback:** Developers see test results before commit
- **Quality Gate:** Prevent broken code from merging

---

## 6. Advanced Pipeline Patterns

### Pattern 1: Blue-Green Deployment

```groovy
pipeline {
    agent any
    
    environment {
        BLUE_ENV = 'production-blue'
        GREEN_ENV = 'production-green'
    }
    
    stages {
        stage('Build') {
            steps {
                sh 'npm run build'
            }
        }
        
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
        
        stage('Deploy to Green') {
            steps {
                sh "ansible-playbook deploy.yml -e environment=${GREEN_ENV}"
            }
        }
        
        stage('Verify Green') {
            steps {
                sh "curl -f http://${GREEN_ENV}:3000/health || exit 1"
            }
        }
        
        stage('Switch Traffic') {
            input 'Approve switch to Green environment?'
            steps {
                sh 'ansible-playbook switch-traffic.yml'
            }
        }
    }
}
```

### Pattern 2: Rolling Deployment

```groovy
pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                sh 'npm run build'
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    sh '''
                        for server in server1 server2 server3; do
                            echo "Deploying to $server..."
                            ssh admin@$server 'cd /app && git pull && npm install && npm run build'
                            sh 'curl -f http://$server:3000/health || (echo "Health check failed" && exit 1)'
                        done
                    '''
                }
            }
        }
    }
}
```

### Pattern 3: Canary Deployment

```groovy
pipeline {
    agent any
    
    stages {
        stage('Build & Test') {
            steps {
                sh 'npm run build && npm test'
            }
        }
        
        stage('Deploy Canary') {
            steps {
                sh 'kubectl set image deployment/myapp-canary myapp=myregistry/myapp:${BUILD_NUMBER}'
            }
        }
        
        stage('Monitor Canary') {
            steps {
                sh '''
                    for i in {1..60}; do
                        ERROR_RATE=$(curl http://canary-myapp:3000/metrics | grep error_rate)
                        if [ "$ERROR_RATE" -gt 5 ]; then
                            echo "Error rate too high, rolling back"
                            kubectl rollout undo deployment/myapp-canary
                            exit 1
                        fi
                        sleep 10
                    done
                '''
            }
        }
        
        stage('Deploy Full') {
            steps {
                sh 'kubectl set image deployment/myapp myapp=myregistry/myapp:${BUILD_NUMBER}'
            }
        }
    }
}
```

---

## 7. Jenkins Security

### Why Security Matters?

**Question: Why is Jenkins security critical?**

- **Access Control:** Prevent unauthorized builds
- **Credential Protection:** Secrets never exposed
- **Audit Trail:** Track who did what
- **Production Protection:** Restrict production deployments

### Security Best Practices

#### 1. **Enable Authentication**

```bash
Manage Jenkins → Configure Global Security
- Enable email-based signup: OFF (for production)
- Authorization: Matrix-based security
```

#### 2. **Role-Based Access Control**

```groovy
// Matrix-based security example
Users:
├── dev-team: Execute freestyle jobs, view logs
├── ops-team: Manage Jenkins, create jobs
└── devops-lead: All permissions
```

#### 3. **Credential Masking**

```groovy
pipeline {
    environment {
        // Automatically masked in logs
        API_KEY = credentials('api-key-secret')
    }
    
    stages {
        stage('Deploy') {
            steps {
                // $API_KEY won't appear in logs
                sh 'curl -H "Authorization: Bearer $API_KEY" https://api.example.com/deploy'
            }
        }
    }
}
```

#### 4. **LDAP/AD Integration**

```bash
Manage Jenkins → Configure Global Security
- Security Realm: LDAP
- Configure LDAP server details
```

---

## 8. Jenkins Monitoring & Performance

### Why Monitor Jenkins?

- **Health Checks:** Ensure Jenkins is responsive
- **Performance:** Identify slow builds
- **Capacity Planning:** Know when to add agents
- **Troubleshooting:** Diagnose issues

### Metrics to Track

```
1. Build Duration
2. Build Success Rate
3. Queue Wait Time
4. Disk Space
5. Memory Usage
6. Agent Availability
```

### Plugins for Monitoring

1. **Metrics Plugin:** Expose Prometheus metrics
2. **Performance Plugin:** Track build performance
3. **Health File Plugin:** Monitor disk/memory

### Example: Prometheus Integration

```groovy
pipeline {
    agent any
    
    post {
        always {
            perfPublisher sourceFile: 'build-performance.xml'
        }
    }
    
    stages {
        stage('Test') {
            steps {
                sh 'npm test --reporter json > test-results.json'
            }
        }
    }
}
```

---

# Best Practices

## 1. Pipeline Best Practices

```groovy
// ✅ GOOD: Clear, readable, reusable

@Library('shared-library@main') _

pipeline {
    agent any
    
    options {
        timestamps()           // Show timestamps in logs
        timeout(time: 1, unit: 'HOURS')  // Timeout protection
        buildDiscarder(logRotator(numToKeepStr: '20'))  // Keep last 20 builds
    }
    
    environment {
        APP_NAME = 'myapp'
        BUILD_ENV = 'staging'
    }
    
    parameters {
        string(name: 'VERSION', defaultValue: '1.0.0', description: 'Release version')
        booleanParam(name: 'DEPLOY_TO_PROD', defaultValue: false, description: 'Deploy to production?')
    }
    
    stages {
        stage('Build') {
            steps {
                script {
                    echo "Building ${APP_NAME} version ${VERSION}"
                    buildApp('nodejs', 'npm install && npm run build')
                }
            }
        }
        
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
        
        stage('Deploy') {
            when {
                expression { params.DEPLOY_TO_PROD }
            }
            steps {
                deployApp('production', 'myapp')
            }
        }
    }
    
    post {
        always {
            junit 'test-results.xml'
            cleanWs()  // Clean workspace
        }
        success {
            notifySlack('success')
        }
        failure {
            notifySlack('failure')
        }
    }
}
```

## 2. Jenkinsfile Locations

**Where to store Jenkinsfile?**

```
// Option 1: In repository (RECOMMENDED)
project-root/
├── Jenkinsfile
├── src/
└── package.json

// Option 2: Jenkins configuration
// Manage Jenkins → Jenkins Location → Jenkinsfile
```

**Why store in repository?**

- **Version Control:** Track pipeline changes with code
- **Code Review:** Pull request can include pipeline changes
- **Transparency:** Everyone sees the pipeline
- **Disaster Recovery:** Restore pipeline from Git

## 3. Error Handling

```groovy
pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                script {
                    try {
                        sh 'npm run build'
                    } catch (Exception e) {
                        echo "Build failed: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        error("Build stage failed")
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Cleanup
            sh 'docker system prune -f'
        }
        failure {
            // Send alert
            emailext(
                subject: "Build ${BUILD_NUMBER} failed",
                to: 'team@example.com',
                body: """
                    Build failed: ${BUILD_URL}
                    ${BUILD_LOG}
                """,
                attachLog: true
            )
        }
    }
}
```

## 4. Resource Management

```groovy
// Prevent resource exhaustion

pipeline {
    agent any
    
    options {
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
        buildDiscarder(logRotator(
            daysToKeepStr: '30',
            numToKeepStr: '50',
            artifactDaysToKeepStr: '7',
            artifactNumToKeepStr: '10'
        ))
    }
    
    stages {
        stage('Build') {
            steps {
                sh 'npm install && npm run build'
            }
        }
    }
    
    post {
        always {
            // Clean up artifacts and workspace
            deleteDir()
        }
    }
}
```

## 5. Documentation

```groovy
pipeline {
    agent any
    
    description = 'Build, test, and deploy Node.js application'
    
    parameters {
        string(
            name: 'ENVIRONMENT',
            defaultValue: 'staging',
            description: 'Target environment (staging|production)'
        )
    }
    
    stages {
        stage('Setup') {
            steps {
                echo '''
                    ====================================
                    Starting Pipeline Execution
                    ====================================
                    Environment: ${ENVIRONMENT}
                    Build Number: ${BUILD_NUMBER}
                    Build URL: ${BUILD_URL}
                    ====================================
                '''
            }
        }
    }
}
```

---

# Real-World Examples

## Example 1: Node.js Application Pipeline

```groovy
@Library('shared-library@main') _

pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE = "${DOCKER_REGISTRY}/myorg/nodejs-app"
        NODE_VERSION = '16'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Install Dependencies') {
            steps {
                sh 'npm ci'
            }
        }
        
        stage('Lint') {
            steps {
                sh 'npm run lint || true'
            }
        }
        
        stage('Unit Tests') {
            steps {
                sh 'npm run test:unit'
            }
        }
        
        stage('Build') {
            steps {
                sh 'npm run build'
            }
        }
        
        stage('Build Docker Image') {
            when {
                branch 'main'
            }
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${BUILD_NUMBER}")
                    docker.build("${DOCKER_IMAGE}:latest")
                }
            }
        }
        
        stage('Push to Registry') {
            when {
                branch 'main'
            }
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh '''
                            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                            docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                            docker push ${DOCKER_IMAGE}:latest
                        '''
                    }
                }
            }
        }
        
        stage('Deploy to Staging') {
            when {
                branch 'develop'
            }
            steps {
                sh '''
                    kubectl set image deployment/nodejs-app \
                    nodejs-app=${DOCKER_IMAGE}:${BUILD_NUMBER} \
                    -n staging
                '''
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            input {
                message "Deploy to production?"
                ok "Deploy"
            }
            steps {
                sh '''
                    kubectl set image deployment/nodejs-app \
                    nodejs-app=${DOCKER_IMAGE}:${BUILD_NUMBER} \
                    -n production
                '''
            }
        }
    }
    
    post {
        always {
            junit 'test-results.xml'
            publishHTML([
                reportDir: 'coverage',
                reportFiles: 'index.html',
                reportName: 'Code Coverage'
            ])
            cleanWs()
        }
        
        failure {
            emailext(
                subject: "Build Failed: ${JOB_NAME} ${BUILD_NUMBER}",
                to: 'team@example.com',
                body: """
                    Build ${BUILD_NUMBER} failed.
                    
                    Check console output at ${BUILD_URL}
                """
            )
        }
        
        success {
            sh '''
                curl -X POST -H 'Content-type: application/json' \
                --data '{"text":"Build ${BUILD_NUMBER} succeeded"}' \
                ${SLACK_WEBHOOK_URL}
            '''
        }
    }
}
```

## Example 2: Multi-Stage Pipeline with Testing

```groovy
pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build & Unit Test') {
            parallel {
                stage('Backend Build') {
                    steps {
                        dir('backend') {
                            sh '''
                                mvn clean install
                                mvn test
                            '''
                        }
                    }
                }
                
                stage('Frontend Build') {
                    steps {
                        dir('frontend') {
                            sh '''
                                npm ci
                                npm run build
                                npm run test
                            '''
                        }
                    }
                }
            }
        }
        
        stage('Integration Tests') {
            steps {
                sh '''
                    docker-compose -f tests/docker-compose.yml up -d
                    npm run test:integration
                    docker-compose -f tests/docker-compose.yml down
                '''
            }
        }
        
        stage('Security Scan') {
            steps {
                sh '''
                    npm audit
                    # or use SonarQube
                    # sonar-scanner -Dsonar.projectKey=myapp
                '''
            }
        }
        
        stage('Performance Test') {
            steps {
                sh '''
                    # Run performance tests
                    jmeter -n -t tests/performance.jmx -l results.csv
                '''
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh 'bash scripts/deploy.sh'
            }
        }
    }
    
    post {
        always {
            // Publish all test results
            junit '**/test-results.xml'
            publishHTML([
                reportDir: 'coverage',
                reportFiles: 'index.html',
                reportName: 'Coverage Report'
            ])
        }
    }
}
```

---

## Table: Jenkins vs Alternatives

| Feature | Jenkins | GitLab CI | GitHub Actions | CircleCI |
|---------|---------|-----------|----------------|----------|
| **Cost** | Free (Open-source) | Free tier available | Free tier | Paid |
| **Setup** | Self-hosted/Cloud | Hosted/Self-hosted | Hosted only | Hosted only |
| **Learning Curve** | Steep | Medium | Easy | Easy |
| **Flexibility** | Very High | High | Medium | Medium |
| **Community** | Large | Growing | Large | Medium |
| **Integration** | Excellent (plugins) | Good | Very Good | Good |
| **Best For** | Enterprise | DevOps teams | GitHub projects | Startups |

---

## Quick Reference Commands

```bash
# View Jenkins version
curl http://localhost:8080/jnlpJars/jenkins.core.jar -I | grep X-Jenkins-Version

# Backup Jenkins configuration
tar -czf jenkins-backup.tar.gz /var/lib/jenkins/

# Restart Jenkins
sudo systemctl restart jenkins

# View Jenkins logs
sudo journalctl -u jenkins -f

# Access Jenkins CLI
java -jar jenkins-cli.jar -s http://localhost:8080 help

# Trigger build via REST API
curl -X POST http://localhost:8080/job/myapp/build \
  -u admin:token

# Get build status
curl http://localhost:8080/job/myapp/lastBuild/api/json
```

---

## Common Interview Questions

**Q: What's the difference between Jenkins and GitLab CI?**
A: Jenkins is self-hosted and highly flexible with 1800+ plugins, while GitLab CI is integrated with GitLab and easier to set up but less flexible.

**Q: How do you handle secrets in Jenkins?**
A: Use Jenkins Credentials Store. Store sensitive data there and reference them in pipelines using `credentials()` function. They're automatically masked in logs.

**Q: What's the purpose of agents in Jenkins?**
A: Agents distribute build workloads across multiple machines, allowing parallel execution, resource isolation, and platform-specific builds.

**Q: How do you implement CD (Continuous Deployment)?**
A: Use pipeline stages with conditional execution and deployment scripts. Automate deployments from specific branches with approval gates.

**Q: What's Blue Ocean?**
A: A modern UI for Jenkins that provides better visualization, real-time feedback, and improved UX for managing pipelines.

---

## Additional Resources

- [Official Jenkins Documentation](https://www.jenkins.io/doc/)
- [Jenkins Best Practices](https://www.jenkins.io/doc/book/pipeline-as-code/)
- [Pipeline Syntax Reference](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Plugin Directory](https://plugins.jenkins.io/)
- [Jenkins Community](https://www.jenkins.io/community/)

---

**Last Updated:** February 22, 2026
