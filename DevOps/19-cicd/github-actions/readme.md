## 🎓 **GitHub Actions Complete Tutorial**

Learn to write CI/CD workflows from scratch!

---

## 1️⃣ **Basic Workflow Structure**

````yaml
name: My First Workflow                    # Workflow name (shown in Actions tab)

on:                                         # Trigger events
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 0 * * *'                    # Daily at midnight UTC

env:                                        # Global environment variables
  NODE_ENV: production

jobs:
  my-job:                                   # Job name
    runs-on: ubuntu-latest                 # Runner (machine to run on)
    steps:
      - name: Print hello                   # Step name
        run: echo "Hello World"
````

---

## 2️⃣ **Available Actions (Built-in & Community)**

### ✅ **Checkout Actions**

````yaml
steps:
  # Clone repository
  - uses: actions/checkout@v4
    with:
      fetch-depth: 0                       # Full history (useful for git analysis)
      ref: main                            # Specific branch/tag
      token: ${{ secrets.GITHUB_TOKEN }}   # Custom token

  # Shallow clone (faster)
  - uses: actions/checkout@v4
    with:
      fetch-depth: 1
````

### ✅ **Setup Language Environments**

````yaml
# Java setup
- uses: actions/setup-java@v3
  with:
    java-version: '17'
    distribution: 'temurin'                # or 'adopt', 'zulu', 'corretto'
    cache: maven                           # Auto cache Maven dependencies

# Node.js setup
- uses: actions/setup-node@v3
  with:
    node-version: '18'
    cache: 'npm'                           # Cache node_modules

# Python setup
- uses: actions/setup-python@v4
  with:
    python-version: '3.11'
    cache: 'pip'

# Go setup
- uses: actions/setup-go@v4
  with:
    go-version: '1.21'
````

### ✅ **Caching (Speed Up Builds)**

````yaml
# Cache dependencies
- uses: actions/cache@v3
  with:
    path: ~/.m2/repository                 # What to cache
    key: ${{ runner.os }}-maven-${{ hashFiles('**/pom.xml') }}
    restore-keys: |                        # Fallback keys
      ${{ runner.os }}-maven-
      ${{ runner.os }}-

# Multi-path caching
- uses: actions/cache@v3
  with:
    path: |
      ~/.m2/repository
      ~/.gradle/wrapper
      node_modules
    key: ${{ runner.os }}-build-${{ hashFiles('**/package-lock.json') }}
````

### ✅ **Artifacts (Store & Download)**

````yaml
# Upload artifacts
- uses: actions/upload-artifact@v3
  with:
    name: build-output                     # Artifact name
    path: |                                # Multiple paths
      target/*.jar
      dist/
      build/
    retention-days: 30                     # Auto-delete after 30 days

# Download artifacts
- uses: actions/download-artifact@v3
  with:
    name: build-output
    path: ./downloaded-artifacts

# Download all artifacts
- uses: actions/download-artifact@v3
````

### ✅ **Docker Actions**

````yaml
# Setup Docker Buildx (for building)
- uses: docker/setup-buildx-action@v2

# Login to Docker Hub
- uses: docker/login-action@v2
  with:
    username: ${{ secrets.DOCKER_USERNAME }}
    password: ${{ secrets.DOCKER_PASSWORD }}

# Login to other registries
- uses: docker/login-action@v2
  with:
    registry: ghcr.io                      # GitHub Container Registry
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}

# Build and push image
- uses: docker/build-push-action@v4
  with:
    context: .
    push: true                             # Push to registry
    tags: myimage:latest
    cache-from: type=registry,ref=myimage:buildcache
    cache-to: type=registry,ref=myimage:buildcache,mode=max
    build-args: |                          # Build arguments
      VERSION=1.0
      BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
````

### ✅ **Security & Testing**

````yaml
# Trivy security scan
- uses: aquasecurity/trivy-action@master
  with:
    scan-type: 'fs'                        # 'fs', 'image', 'rootfs'
    scan-ref: '.'
    format: 'sarif'
    output: 'trivy-results.sarif'

# Upload SARIF to GitHub Security
- uses: github/codeql-action/upload-sarif@v2
  with:
    sarif_file: 'trivy-results.sarif'

# SonarQube scan
- uses: sonarsource/sonarqube-scan-action@master
  env:
    SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}

# Code coverage
- uses: codecov/codecov-action@v3
  with:
    files: ./coverage/coverage.xml
    flags: unittests
    name: codecov-umbrella
````

### ✅ **Notifications**

````yaml
# Slack notification
- uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}              # success, failure
    text: 'Build ${{ job.status }}'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
    fields: repo,message,commit,author

# Discord notification
- uses: sarisia/actions-status-discord@v1
  if: always()
  with:
    webhook_url: ${{ secrets.DISCORD_WEBHOOK }}
    status: ${{ job.status }}

# Email notification  (requires external action)
- uses: dawidd6/action-send-mail@v3
  with:
    server_address: smtp.gmail.com
    server_port: 465
    username: ${{ secrets.EMAIL_USER }}
    password: ${{ secrets.EMAIL_PASSWORD }}
    subject: Build Report
    to: admin@example.com
    from: ci@example.com
    body: Build ${{ job.status }}
````

### ✅ **Kubernetes & Cloud Deployment**

````yaml
# Setup kubectl
- uses: azure/setup-kubectl@v3
  with:
    version: 'v1.31.0'

# AWS CLI setup
- uses: aws-actions/configure-aws-credentials@v2
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: us-east-1

# Helm deployment
- uses: azure/setup-helm@v3
  with:
    version: '3.12.0'

# Terraform
- uses: hashicorp/setup-terraform@v2
  with:
    terraform_version: 1.6.0
````

### ✅ **Release & Publishing**

````yaml
# Create GitHub Release
- uses: softprops/action-gh-release@v1
  if: startsWith(github.ref, 'refs/tags/')
  with:
    files: |
      dist/*.jar
      build/*.zip
    body: Release notes here
    draft: false
    prerelease: false

# Publish to npm
- uses: actions/setup-node@v3
  with:
    node-version: '18'
    registry-url: 'https://registry.npmjs.org'
- run: npm publish
  env:
    NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}

# Publish to Maven Central
- uses: actions/setup-java@v3
  with:
    java-version: '17'
    distribution: 'temurin'
    server-id: ossrh
    server-username: MAVEN_USERNAME
    server-password: MAVEN_PASSWORD
- run: mvn deploy
  env:
    MAVEN_USERNAME: ${{ secrets.OSSRH_USERNAME }}
    MAVEN_PASSWORD: ${{ secrets.OSSRH_TOKEN }}
````

---

## 3️⃣ **Understanding Workflow Syntax**

### ✅ **Run Command vs Uses**

````yaml
steps:
  # 'run' = Execute shell commands
  - name: Run shell command
    run: |
      echo "Hello"
      mvn clean test
      docker build .

  # 'uses' = Use pre-built actions from marketplace
  - name: Use action
    uses: actions/checkout@v4
    with:
      fetch-depth: 0
````

### ✅ **Variables & Secrets**

````yaml
env:
  # Global environment variables
  ENVIRONMENT: production

jobs:
  build:
    env:
      # Job-level environment variable
      BUILD_VERSION: 1.0.0
    
    steps:
      - name: Use variables
        env:
          # Step-level environment variable
          STEP_VAR: value
        run: |
          echo $ENVIRONMENT              # Global
          echo $BUILD_VERSION            # Job
          echo $STEP_VAR                 # Step
          echo ${{ secrets.MY_SECRET }}  # From GitHub Secrets
          echo ${{ github.ref }}         # GitHub context
          echo ${{ runner.os }}          # Runner context
````

### ✅ **Contexts Available**

````yaml
- name: Print contexts
  run: |
    # github context
    echo ${{ github.repository }}        # owner/repo
    echo ${{ github.ref }}               # refs/heads/main
    echo ${{ github.sha }}               # commit SHA
    echo ${{ github.actor }}             # who triggered (username)
    echo ${{ github.event_name }}        # push, pull_request, etc
    echo ${{ github.workspace }}         # working directory
    
    # runner context
    echo ${{ runner.os }}                # Linux, Windows, macOS
    echo ${{ runner.arch }}              # X64, X86, ARM64
    echo ${{ runner.name }}              # GitHub Actions 1
    
    # job context
    echo ${{ job.status }}               # success, failure
    echo ${{ job.container.id }}         # container ID
    
    # steps context
    echo ${{ steps.step-id.outputs.var }}  # Access step output
````

### ✅ **Conditions (if)**

````yaml
steps:
  # Run only on main branch
  - name: Deploy
    if: github.ref == 'refs/heads/main'
    run: kubectl apply -f deployment.yaml

  # Run only on tags
  - name: Release
    if: startsWith(github.ref, 'refs/tags/')
    run: npm publish

  # Run on failure
  - name: Notify on failure
    if: failure()
    run: echo "Build failed"

  # Run always (success or failure)
  - name: Cleanup
    if: always()
    run: docker system prune -f

  # Run only if previous step succeeded
  - name: Upload
    if: success()
    run: aws s3 cp build/ s3://bucket/

  # Custom condition
  - name: Conditional step
    if: contains(github.event.head_commit.message, '[deploy]')
    run: echo "Deploy keyword found"
````

### ✅ **Matrix Builds (Multiple Versions)**

````yaml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        java-version: ['11', '17', '21']
        os: [ubuntu-latest, macos-latest]
        include:
          - java-version: '21'
            experimental: true
        exclude:
          - java-version: '11'
            os: macos-latest
    
    steps:
      - uses: actions/setup-java@v3
        with:
          java-version: ${{ matrix.java-version }}
      
      - run: |
          mvn test
          if [ "${{ matrix.experimental }}" = "true" ]; then
            echo "Experimental version"
          fi
````

### ✅ **Job Dependencies (Wait for Other Jobs)**

````yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - run: mvn test

  build:
    runs-on: ubuntu-latest
    needs: test                            # Wait for 'test' job
    steps:
      - run: mvn package

  deploy:
    runs-on: ubuntu-latest
    needs: [test, build]                   # Wait for multiple jobs
    if: success()
    steps:
      - run: kubectl apply -f deployment.yaml
````

---

## 4️⃣ **Common Workflow Patterns**

### ✅ **Simple CI (Test on Push)**

````yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-java@v3
        with:
          java-version: '17'
          cache: maven
      
      - run: mvn test
````

### ✅ **Build & Push Docker Image**

````yaml
name: Docker Build

on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: docker/setup-buildx-action@v2
      
      - uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: |
            ${{ secrets.DOCKER_USERNAME }}/myapp:latest
            ${{ secrets.DOCKER_USERNAME }}/myapp:${{ github.sha }}
````

### ✅ **Deploy to Kubernetes**

````yaml
name: Deploy to K8s

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: azure/setup-kubectl@v3
      
      - name: Deploy
        env:
          KUBECONFIG_CONTENT: ${{ secrets.KUBECONFIG }}
        run: |
          mkdir -p $HOME/.kube
          echo "$KUBECONFIG_CONTENT" | base64 -d > $HOME/.kube/config
          kubectl apply -f deployment.yaml
          kubectl rollout status deployment/myapp
````

### ✅ **Scheduled Jobs (Cron)**

````yaml
name: Nightly Scan

on:
  schedule:
    - cron: '0 2 * * *'                   # Daily at 2 AM UTC
  workflow_dispatch:                       # Manual trigger

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          format: 'sarif'
          output: 'trivy.sarif'
      
      - uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy.sarif'
````

---

## 5️⃣ **Output Variables (Pass Data Between Steps)**

````yaml
steps:
  - name: Generate version
    id: version                            # Step ID
    run: |
      VERSION="1.0.$(date +%s)"
      echo "version=$VERSION" >> $GITHUB_OUTPUT  # Set output
      echo "Built version: $VERSION"
  
  - name: Use version output
    run: |
      echo "Version is: ${{ steps.version.outputs.version }}"
      docker build -t myapp:${{ steps.version.outputs.version }} .
````

---

## 6️⃣ **Complete Real-World Example**

````yaml
name: Full CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  # Stage 1: Test
  test:
    name: Test & Coverage
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-java@v3
        with:
          java-version: '17'
          cache: maven
      
      - name: Run tests
        run: mvn clean test
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./target/coverage.xml
      
      - name: Upload test reports
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-reports
          path: target/surefire-reports/

  # Stage 2: Security scan
  security:
    name: Security Scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          format: 'sarif'
          output: 'trivy.sarif'
      
      - uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy.sarif'

  # Stage 3: Build
  build:
    name: Build
    runs-on: ubuntu-latest
    needs: [test, security]
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-java@v3
        with:
          java-version: '17'
          cache: maven
      
      - name: Build JAR
        run: mvn clean package -DskipTests
      
      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: build-artifact
          path: target/*.jar

  # Stage 4: Docker build & push
  docker:
    name: Docker Build & Push
    runs-on: ubuntu-latest
    needs: build
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/download-artifact@v3
        with:
          name: build-artifact
      
      - uses: docker/setup-buildx-action@v2
      
      - uses: docker/login-action@v2
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - uses: docker/metadata-action@v4
        id: meta
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=sha,prefix={{branch}}-
            type=semver,pattern={{version}}
      
      - uses: docker/build-push-action@v4
        with:
          context: .
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}

  # Stage 5: Deploy (only on main)
  deploy:
    name: Deploy to K8s
    runs-on: ubuntu-latest
    needs: docker
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    steps:
      - uses: actions/checkout@v4
      
      - uses: azure/setup-kubectl@v3
      
      - name: Deploy
        env:
          KUBECONFIG_CONTENT: ${{ secrets.KUBECONFIG }}
        run: |
          mkdir -p $HOME/.kube
          echo "$KUBECONFIG_CONTENT" | base64 -d > $HOME/.kube/config
          kubectl set image deployment/myapp myapp=${{ needs.docker.outputs.image-tag }}
          kubectl rollout status deployment/myapp
      
      - name: Notify
        if: always()
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
````

---

## 📚 **Resources**

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
- [workflow-syntax-for-github-actions](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)

**Now you can write any CI/CD workflow!** 🚀

Similar code found with 2 license types