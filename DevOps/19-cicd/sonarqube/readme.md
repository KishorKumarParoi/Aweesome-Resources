# SonarQube: Complete Guide from Beginner to Advanced

## Table of Contents
1. [Introduction](#introduction)
2. [Installation & Setup](#installation--setup)
3. [Beginner Usage](#beginner-usage)
4. [Intermediate Configuration](#intermediate-configuration)
5. [Advanced Setup](#advanced-setup)
6. [CI/CD Integration](#cicd-integration)
7. [Quality Gates & Rules](#quality-gates--rules)
8. [Best Practices](#best-practices)
9. [Troubleshooting](#troubleshooting)

---

## Introduction

### What is SonarQube?

SonarQube is an open-source platform for continuous inspection and measurement of code quality. It performs static code analysis to detect bugs, code smells, security vulnerabilities, and technical debt.

### Key Features
- **Code Analysis**: Detects bugs, vulnerabilities, and code smells
- **Quality Metrics**: Tracks code coverage, complexity, and technical debt
- **Security**: Identifies security hotspots and vulnerabilities
- **Scalability**: Handles large codebases
- **Multi-language Support**: Java, Python, JavaScript, C#, C/C++, Go, Kotlin, Ruby, SQL, etc.
- **CI/CD Integration**: Seamless integration with Jenkins, GitLab, GitHub, Azure DevOps
- **Quality Gates**: Automated pass/fail criteria for code

### Architecture
```
┌─────────────────────────────────────────┐
│   SonarQube Server                      │
│  ┌─────────────────────────────────────┤
│  │  Database (PostgreSQL/MySQL)        │
│  │  Search Engine (Elasticsearch)      │
│  │  Web UI & API                       │
│  └─────────────────────────────────────┤
└─────────────────────────────────────────┘
         ↑              ↑
    Pushes           Pushes
    Results         Results
         |              |
    ┌─────────┐    ┌──────────┐
    │SonarQube│    │SonarQube │
    │ Scanner │    │ Scanner  │
    │ (Local) │    │(CI/CD)   │
    └─────────┘    └──────────┘
```

---

## Installation & Setup

### Option 1: Docker Installation (Recommended for Beginners)

#### Prerequisites
- Docker installed
- 2GB RAM minimum
- Docker Compose (optional but recommended)

#### Quick Start with Docker
```bash
# Pull SonarQube Community Edition
docker pull sonarqube:latest

# Run SonarQube container
docker run -d \
  --name sonarqube \
  -p 9000:9000 \
  -e SONAR_JDBC_URL=jdbc:postgresql://db:5432/sonarqube \
  -e SONAR_JDBC_USERNAME=sonarqube \
  -e SONAR_JDBC_PASSWORD=sonarqube \
  sonarqube:latest
```

#### Docker Compose Setup (Complete Stack)
Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  db:
    image: postgres:13
    container_name: sonarqube-db
    environment:
      POSTGRES_USER: sonarqube
      POSTGRES_PASSWORD: sonarqube
      POSTGRES_DB: sonarqube
    volumes:
      - postgresql_data:/var/lib/postgresql/data
    networks:
      - sonarqube

  sonarqube:
    image: sonarqube:latest
    container_name: sonarqube
    depends_on:
      - db
    ports:
      - "9000:9000"
    environment:
      SONAR_JDBC_URL: jdbc:postgresql://db:5432/sonarqube
      SONAR_JDBC_USERNAME: sonarqube
      SONAR_JDBC_PASSWORD: sonarqube
      SONAR_FORCE_AUTHENTICATION: "false"
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_logs:/opt/sonarqube/logs
      - sonarqube_extensions:/opt/sonarqube/extensions
    networks:
      - sonarqube
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/api/system/health"]
      interval: 30s
      timeout: 10s
      retries: 5

volumes:
  postgresql_data:
  sonarqube_data:
  sonarqube_logs:
  sonarqube_extensions:

networks:
  sonarqube:
    driver: bridge
```

Deploy with:
```bash
docker-compose up -d
```

### Option 2: Standalone Installation on Linux

#### Prerequisites
- Java 11 or higher
- Port 9000 available
- Linux/macOS/Windows

#### Installation Steps
```bash
# Download SonarQube
cd /opt
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.1.69595.zip

# Extract
unzip sonarqube-9.9.1.69595.zip
cd sonarqube-9.9.1.69595

# Configure PostgreSQL connection (edit conf/sonar.properties)
# - Set: sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
# - Set: sonar.jdbc.username=sonarqube
# - Set: sonar.jdbc.password=sonarqube

# Start SonarQube
./bin/linux-x86-64/sonar.sh start

# Check status
./bin/linux-x86-64/sonar.sh status

# View logs
tail -f logs/sonar.log
```

#### PostgreSQL Setup for Standalone
```bash
# Create database
sudo -u postgres psql
CREATE USER sonarqube WITH PASSWORD 'sonarqube';
CREATE DATABASE sonarqube OWNER sonarqube;
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonarqube;
\q
```

### Option 3: Kubernetes Deployment

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: sonarqube

---
apiVersion: v1
kind: Service
metadata:
  name: sonarqube
  namespace: sonarqube
spec:
  selector:
    app: sonarqube
  ports:
    - port: 9000
      targetPort: 9000
  type: LoadBalancer

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sonarqube
  namespace: sonarqube
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sonarqube
  template:
    metadata:
      labels:
        app: sonarqube
    spec:
      containers:
      - name: sonarqube
        image: sonarqube:latest
        ports:
        - containerPort: 9000
        env:
        - name: SONAR_JDBC_URL
          value: "jdbc:postgresql://postgres:5432/sonarqube"
        - name: SONAR_JDBC_USERNAME
          value: "sonarqube"
        - name: SONAR_JDBC_PASSWORD
          valueFrom:
            secretKeyRef:
              name: sonarqube-secret
              key: password
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
```

---

## Beginner Usage

### Step 1: First Access

1. **Open SonarQube**: http://localhost:9000
2. **Default Credentials**: 
   - Username: `admin`
   - Password: `admin`
3. **Change Password**: Recommended on first login

### Step 2: Create Your First Project

```bash
# Manual approach in UI:
# 1. Click "Create project" button
# 2. Enter project name (e.g., "my-app")
# 3. Set project key (e.g., "com.example:my-app")
# 4. Click "Set Up"
# 5. Choose analysis method (Local or CI)
# 6. Generate token
```

### Step 3: Install SonarQube Scanner

#### For Local Machine
```bash
# Download scanner
cd ~/Downloads
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.10.0.2635-linux-x64.zip

# Extract and setup
unzip sonar-scanner-cli-4.10.0.2635-linux-x64.zip
sudo mv sonar-scanner-4.10.0.2635-linux-x64 /opt/sonar-scanner

# Add to PATH
export PATH=$PATH:/opt/sonar-scanner/bin

# Verify installation
sonar-scanner --version
```

#### For macOS
```bash
brew install sonar-scanner
```

### Step 4: Analyze a Project

#### Basic Analysis
```bash
cd /path/to/your/project

sonar-scanner \
  -Dsonar.projectKey=my-app \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=<your-token>
```

#### For Python Project
```bash
sonar-scanner \
  -Dsonar.projectKey=python-app \
  -Dsonar.projectName=My Python App \
  -Dsonar.sources=src \
  -Dsonar.pythonVersion=3.9 \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=<token>
```

#### For JavaScript Project
```bash
sonar-scanner \
  -Dsonar.projectKey=js-app \
  -Dsonar.sources=src \
  -Dsonar.exclusions=node_modules/**,dist/** \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=<token>
```

### Step 5: View Results

1. **Dashboard**: Displays overall code quality metrics
2. **Issues**: Lists all detected bugs, vulnerabilities, and code smells
3. **Code**: Browse source code with annotations
4. **Measures**: Detailed metrics and trends
5. **Activity**: History of analyses

---

## Intermediate Configuration

### Configuration File Method

Instead of command-line flags, use `sonar-project.properties`:

```properties
# Project info
sonar.projectKey=my-app
sonar.projectName=My Application
sonar.projectVersion=1.0.0

# Source code
sonar.sources=src
sonar.tests=tests
sonar.exclusions=node_modules/**,dist/**,build/**

# Coverage (if using coverage tools)
sonar.coverage.exclusions=tests/**,**/test/**
sonar.javascript.lcov.reportPaths=coverage/lcov.info

# Language-specific
sonar.python.version=3.9
sonar.java.binaries=target/classes

# Server connection
sonar.host.url=http://localhost:9000
sonar.login=<your-token>
```

Then run:
```bash
sonar-scanner -Dproject.settings=sonar-project.properties
```

### User Management & Permissions

#### Create Users
```bash
# Via UI:
# 1. Administration → Security → Users
# 2. Click "Create User"
# 3. Enter username, name, email, password
```

#### User Roles & Permissions
- **Sonar Users**: Can view projects and issues
- **Sonar Developers**: Can analyze projects
- **Project Administrators**: Can manage project settings
- **Global Administrators**: Full system access

#### Project Permissions
```bash
# Via UI:
# 1. Project Settings → Permissions
# 2. Add users/groups with specific permissions:
#    - Browse
#    - Code Viewer
#    - Issues Admin
#    - Scan
#    - Admin
```

### Quality Profiles & Rules

#### Understanding Quality Profiles
Quality Profiles are sets of rules applied during analysis.

```bash
# Navigate to: Administration → Quality Profiles
# Default profiles exist for each language
```

#### Create Custom Profile
```bash
# Via UI:
# 1. Administration → Quality Profiles
# 2. Click "Create"
# 3. Name: "Custom Python Rules"
# 4. Language: Python
# 5. Parent: Sonar way (inherits default rules)
# 6. Add/Remove/Configure rules
# 7. Assign to project
```

#### Rule Configuration Example
```yaml
# Rule: S3776 (Cognitive Complexity)
Severity: Major
Status: Active
Description: Methods should not be too complex

# Rule: S1186 (Empty Methods)
Severity: Minor
Status: Active
Description: Methods should not be empty
```

### Quality Gates (Beginner Level)

Quality Gates are criteria that projects must meet:

#### Create Quality Gate
```bash
# Via UI:
# 1. Quality Gates section
# 2. Click "Create"
# 3. Name: "Default Gate"
# 4. Add conditions:
#    - Coverage < 80%: FAIL
#    - Duplicated Lines > 3%: WARN
#    - Maintainability Rating > B: FAIL
```

#### Set Default Quality Gate
```bash
# Administration → Quality Gates
# Select gate and "Set as Default"
```

---

## Advanced Setup

### Multi-Branch Analysis

SonarQube can analyze multiple branches of your project:

```bash
# Analyze feature branch
sonar-scanner \
  -Dsonar.projectKey=my-app \
  -Dsonar.branch.name=feature/new-feature \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=<token>

# Analyze pull request
sonar-scanner \
  -Dsonar.projectKey=my-app \
  -Dsonar.pullrequest.key=123 \
  -Dsonar.pullrequest.branch=feature/new-feature \
  -Dsonar.pullrequest.base=main \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=<token>
```

### Code Coverage Integration

#### Python with pytest
```bash
# Install coverage tools
pip install pytest pytest-cov

# Generate coverage report
pytest --cov=src --cov-report=xml

# SonarQube analysis
sonar-scanner \
  -Dsonar.projectKey=python-app \
  -Dsonar.sources=src \
  -Dsonar.python.coverage.reportPath=coverage.xml \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=<token>
```

#### JavaScript with Jest
```bash
# Install and configure Jest
npm install --save-dev jest @jest/globals

# Generate coverage
npm test -- --coverage --coverageReporters=lcov

# SonarQube analysis
sonar-scanner \
  -Dsonar.projectKey=js-app \
  -Dsonar.sources=src \
  -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=<token>
```

#### Java with JaCoCo
```xml
<!-- pom.xml -->
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.8</version>
    <executions>
        <execution>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
        </execution>
        <execution>
            <id>report</id>
            <phase>test</phase>
            <goals>
                <goal>report</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

### Advanced Quality Gates

#### Condition Types
```yaml
# New Code Conditions
- New Lines of Code > 1000: FAIL
- New Bugs > 5: FAIL
- New Security Hotspots > 3: FAIL

# Overall Code Conditions
- Maintainability Rating > C: FAIL
- Security Rating > B: FAIL
- Reliability Rating > D: FAIL
- Coverage < 60%: WARN

# Technical Debt Ratio > 5%: WARN
```

#### Example Complex Quality Gate
```bash
# Via UI or API:
Quality Gate: "Production Ready"

Conditions:
1. Overall Coverage >= 80%
2. New Coverage on New Code >= 70%
3. Code Duplications <= 3%
4. Maintainability Rating = A
5. Security Rating = A
6. Reliability Rating = A
7. No Critical Issues
8. No Blocker Issues
```

### Custom Rules & Plugins

#### Using Custom Rules Plugin
```bash
# Create custom rule plugin (requires Java/Maven)
# 1. Fork sonarqube-custom-rules template
# 2. Define custom rules in Java
# 3. Build plugin JAR
# 4. Deploy to $SONARQUBE_HOME/extensions/plugins/
# 5. Restart SonarQube
```

#### Popular Plugins
- **SonarJava**: Enhanced Java analysis
- **SonarPython**: Python support
- **SonarJavaScript**: JavaScript/TypeScript support
- **SonarC++**: C/C++ support
- **SonarGo**: Go support

### High Availability & Scaling

#### Load Balancer Setup
```yaml
# nginx configuration for load balancing
upstream sonarqube {
    server sonarqube1:9000;
    server sonarqube2:9000;
    server sonarqube3:9000;
}

server {
    listen 80;
    server_name sonarqube.example.com;

    location / {
        proxy_pass http://sonarqube;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

#### Database Optimization
```bash
# PostgreSQL connection pooling
# In sonar.properties:
sonar.jdbc.maxActive=20
sonar.jdbc.maxIdle=5
sonar.jdbc.maxWaitMillis=30000

# Elasticsearch tuning
sonar.search.javaOpts=-Xmx2G -Xms2G
```

---

## CI/CD Integration

### Jenkins Integration

#### Install SonarQube Plugin
```bash
# In Jenkins UI:
# Manage Jenkins → Manage Plugins → Search "SonarQube"
# Install "SonarQube Scanner" plugin
```

#### Declarative Pipeline (Jenkinsfile)
```groovy
pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/your-org/your-repo.git'
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar'
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
    }
}
```

#### Scripted Pipeline
```groovy
node {
    stage('Checkout') {
        checkout scm
    }
    
    stage('Build') {
        sh 'npm install && npm run build'
    }
    
    stage('SonarQube Scan') {
        withSonarQubeEnv('SonarQube') {
            sh '''
                sonar-scanner \
                  -Dsonar.projectKey=my-app \
                  -Dsonar.sources=src \
                  -Dsonar.host.url=${SONARQUBE_HOST_URL} \
                  -Dsonar.login=${SONARQUBE_AUTH_TOKEN}
            '''
        }
    }
    
    stage('Quality Gate Check') {
        def qg = waitForQualityGate()
        if (qg.status != 'OK') {
            error "Pipeline failed due to Quality Gate failure: ${qg.status}"
        }
    }
}
```

### GitLab CI Integration

#### .gitlab-ci.yml
```yaml
stages:
  - build
  - sonarqube

build:
  stage: build
  script:
    - npm install
    - npm run build
  artifacts:
    paths:
      - dist/
      - coverage/

sonarqube:
  stage: sonarqube
  image: node:16
  script:
    - npm install -g sonar-scanner
    - sonar-scanner
      -Dsonar.projectKey=my-app
      -Dsonar.sources=src
      -Dsonar.exclusions=node_modules/**
      -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
      -Dsonar.host.url=${SONARQUBE_HOST}
      -Dsonar.login=${SONARQUBE_TOKEN}
  dependencies:
    - build
  only:
    - merge_requests
    - main
```

### GitHub Actions Integration

#### Workflow File (.github/workflows/sonarqube.yml)
```yaml
name: SonarQube Analysis

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  sonarqube:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '16'
      
      - name: Install dependencies
        run: npm install
      
      - name: Run tests with coverage
        run: npm test -- --coverage --coverageReporters=lcov
      
      - name: SonarQube Scan
        uses: SonarSource/sonarqube-scan-action@master
        env:
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
        with:
          args: >
            -Dsonar.projectKey=my-app
            -Dsonar.sources=src
            -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
      
      - name: SonarQube Quality Gate Check
        uses: SonarSource/sonarqube-quality-gate-action@master
        timeout-minutes: 5
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
```

### Azure DevOps Integration

#### azure-pipelines.yml
```yaml
trigger:
  - main
  - develop

pr:
  - main

pool:
  vmImage: 'ubuntu-latest'

variables:
  buildConfiguration: 'Release'

stages:
  - stage: Build
    jobs:
      - job: Build
        steps:
          - task: NodeTool@0
            inputs:
              versionSpec: '16.x'
          
          - script: npm install
            displayName: 'Install dependencies'
          
          - script: npm run build
            displayName: 'Build project'
          
          - script: npm test -- --coverage --coverageReporters=lcov
            displayName: 'Run tests with coverage'

  - stage: SonarQube
    jobs:
      - job: SonarQubeScan
        steps:
          - task: SonarQubePrepare@5
            inputs:
              SonarQube: 'SonarQube'
              scannerMode: 'CLI'
              configMode: 'manual'
              cliProjectKey: 'my-app'
              cliProjectName: 'My Application'
              cliSources: 'src'
              extraProperties: |
                sonar.javascript.lcov.reportPaths=coverage/lcov.info
          
          - task: SonarQubeAnalyze@5
          
          - task: SonarQubePublish@5
            inputs:
              pollingTimeoutSec: '300'
```

---

## Quality Gates & Rules

### Understanding Issue Types

#### Bugs
```
Impact: Code will fail at runtime
Example: Null pointer reference, type mismatch
Severity: Blocker, Critical, Major
```

#### Vulnerabilities
```
Impact: Security risk
Example: SQL injection, hardcoded credentials
Severity: Blocker, Critical, Major
```

#### Code Smells
```
Impact: Code maintainability issues
Example: Long methods, duplicate code, unused variables
Severity: Minor, Major, Critical
```

#### Technical Debt
```
Estimated time to fix all code smells
Formula: Time to fix blocker + critical issues
```

### Configuring Quality Profiles

#### Rule Activation/Deactivation
```bash
# Via API:
curl -X POST "http://localhost:9000/api/rules/update" \
  -u admin:admin \
  -d "key=python:S1234&params=param1=value1"

# Via UI:
# Quality Profiles → Select Language → Select Rule → Activate/Deactivate
```

#### Rule Severity Configuration
```yaml
# Different severity levels
Critical: 
  - Must fix immediately
  - Blocks deployment
  - Security/functionality issues

Major:
  - Should fix soon
  - Impacts code quality
  - Prevents hot fixes

Minor:
  - Nice to fix
  - Best practices
  - Coding standards
```

### Custom Quality Gates Example

```bash
# Production Gate
sonar.qualitygate.name=Production Ready

# Conditions
- New Code Smells: 0
- New Bugs: 0
- New Security Hotspots: 0
- Overall Coverage: >= 80%
- Maintainability Rating: A
- Security Rating: A
- Reliability Rating: A
```

---

## Best Practices

### 1. Code Review Workflow
```
1. Developer pushes code to feature branch
2. CI/CD triggers SonarQube analysis
3. Quality Gate pass/fail determines PR status
4. Required: Peer review + SonarQube pass
5. Merge only if all checks pass
```

### 2. Regular Cleanup
```bash
# Weekly: Review and fix critical issues
# Monthly: Update rules and plugins
# Quarterly: Review quality gates
# Annually: Audit and optimize configuration
```

### 3. Monitoring & Alerts

#### Trends to Monitor
- Code coverage percentage
- Bugs detected per release
- Number of security hotspots
- Technical debt ratio
- Performance metrics

#### Set Up Alerts
```bash
# Via API or UI:
# 1. Create custom dashboard
# 2. Add metric widgets
# 3. Set up notifications
# 4. Alert on degradation
```

### 4. Effective Use of Exclusions

```properties
# sonar-project.properties

# Exclude test files from coverage analysis
sonar.coverage.exclusions=**/*Test.java,**/*test*

# Exclude generated code
sonar.exclusions=target/**,node_modules/**,build/**,dist/**

# Exclude dependencies
sonar.exclusions=src/main/java/com/example/generated/**

# Keep them for analysis but not coverage
sonar.test.exclusions=src/test/**
```

### 5. Documentation

```bash
# Document your configuration
# Create mapping file:
# - What each quality gate checks
# - Why specific rules are active
# - Expected metric targets
# - Change history
```

### 6. Team Training

```
1. Developers: How to read SonarQube reports
2. QA: How to track metrics
3. Leads: How to set rules and gates
4. DevOps: Setup, maintenance, scaling
```

### 7. Integration Points

```
├── CI/CD (automatic scanning)
├── Code Review (pull request checks)
├── Dashboards (executive visibility)
├── Alerts (critical issues)
├── Documentation (code health)
└── Metrics (tracking trends)
```

---

## Troubleshooting

### Common Issues

#### 1. Scanner Not Finding Source Files
```bash
# Problem: "No files indexed"

# Solution:
# Check sonar.sources is correct
sonar-scanner \
  -Dsonar.projectKey=my-app \
  -Dsonar.sources=./src \  # Verify this path
  -Dsonar.verbose=true     # Enable verbose logging

# List files found:
find ./src -type f \( -name "*.java" -o -name "*.js" -o -name "*.py" \)
```

#### 2. Quality Gate Always Failing
```bash
# Problem: Quality gate always fails

# Check 1: Verify gate conditions
curl -s "http://localhost:9000/api/qualitygates/project_status?projectKey=my-app" \
  -u admin:admin | jq '.projectStatus'

# Check 2: Review recent analysis
# UI: Project → Activity

# Check 3: Adjust gate conditions if too strict
# UI: Quality Gates → Edit Conditions
```

#### 3. Coverage Data Not Showing
```bash
# Problem: 0% coverage reported

# Check 1: Ensure coverage report generated
ls -la coverage/lcov.info  # or similar

# Check 2: Verify report path in scanner
sonar-scanner \
  -Dsonar.javascript.lcov.reportPaths=./coverage/lcov.info \
  -Dsonar.verbose=true

# Check 3: Correct format for language
# JavaScript: lcov.info
# Python: coverage.xml
# Java: target/site/jacoco/jacoco.xml
```

#### 4. High Memory Usage
```bash
# Problem: SonarQube using too much memory

# Solution: Adjust JVM settings
# In sonar.properties or docker-compose.yml:
sonar.web.javaOpts=-Xmx1G -Xms512M
sonar.ce.javaOpts=-Xmx1G -Xms512M
sonar.search.javaOpts=-Xmx1G -Xms1G

# Or via environment variables:
export SONAR_WEB_JAVA_OPTS="-Xmx1G -Xms512M"
export SONAR_CE_JAVA_OPTS="-Xmx1G -Xms512M"
```

#### 5. Database Connection Errors
```bash
# Problem: Cannot connect to database

# Check 1: Verify PostgreSQL is running
pg_isready -h localhost -p 5432

# Check 2: Test connection string
psql -h localhost -U sonarqube -d sonarqube

# Check 3: Verify credentials in sonar.properties
grep -E "sonar.jdbc" /opt/sonarqube/conf/sonar.properties

# Check 4: View SonarQube logs
tail -f /opt/sonarqube/logs/sonar.log
```

#### 6. Slow Analysis
```bash
# Problem: Analysis takes too long

# Solutions:
# 1. Reduce scope with exclusions
sonar.exclusions=tests/**,docs/**,node_modules/**

# 2. Exclude large files
sonar.exclusions=**/*.min.js,**/*.bundle.js

# 3. Parallel scanning
sonar-scanner \
  -Dsonar.projectKey=my-app \
  -Dsonar.sourceEncoding=UTF-8

# 4. Optimize database
# Run VACUUM and ANALYZE on PostgreSQL
sudo -u postgres vacuumdb sonarqube
sudo -u postgres analyzedb sonarqube
```

### Performance Tuning

#### Server Configuration
```properties
# sonar.properties

# Maximum number of concurrent analyses
sonar.ce.maxParallelizedReports=1

# Web UI thread pool
sonar.web.systemPasscode=

# Compute engine
sonar.ce.taskType=ALL

# Search index
sonar.search.maxBucketSize=5000000
```

#### Database Optimization
```sql
-- PostgreSQL optimization
-- Create indexes
CREATE INDEX idx_issues_project ON issues(project_id);
CREATE INDEX idx_issues_resolution ON issues(resolution);

-- Analyze table statistics
ANALYZE issues;

-- Vacuum for cleanup
VACUUM ANALYZE;
```

---

## Advanced Monitoring

### API Examples

#### Get Project Status
```bash
curl -s "http://localhost:9000/api/qualitygates/project_status?projectKey=my-app" \
  -u admin:admin | jq '.'
```

#### List Recent Analyses
```bash
curl -s "http://localhost:9000/api/ce/activity?projectKey=my-app" \
  -u admin:admin | jq '.tasks[] | {id, type, status, executedAt}'
```

#### Create Custom Issue Search
```bash
curl -s "http://localhost:9000/api/issues/search?projects=my-app&types=BUG&severities=CRITICAL" \
  -u admin:admin | jq '.issues[] | {key, message, severity}'
```

### Metrics Export

#### Export to Prometheus
```bash
# SonarQube metrics endpoint
curl "http://localhost:9000/api/measures/component?component=my-app" \
  -u admin:admin > metrics.json
```

---

## Additional Resources

- **Official Documentation**: https://docs.sonarqube.org
- **Community Forum**: https://community.sonarsource.com
- **GitHub Issues**: https://github.com/SonarSource/sonarqube
- **Plugins Marketplace**: https://docs.sonarqube.org/latest/extend/available-plugins/

---

## Summary

SonarQube provides comprehensive code quality management from setup to advanced configuration. Start with basic Docker deployment, gradually move to CI/CD integration, and implement advanced features like multi-branch analysis and custom rules as your maturity increases.

**Key Takeaways:**
1. ✅ Use Docker for easy deployment
2. ✅ Integrate with CI/CD early
3. ✅ Set realistic quality gates
4. ✅ Monitor trends, not just numbers
5. ✅ Keep configuration documented
6. ✅ Regular maintenance and updates
7. ✅ Team collaboration and training
