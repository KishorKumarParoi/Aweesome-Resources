# Docker & Containerization 🐳

Complete guide to Docker for containerizing applications.

---

## Container Basics

### Run Container with Command

```bash
# Run command in container
docker run busybox echo hi kkp

# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Remove unused resources
docker system prune
```

---

## Create vs Run

```bash
# Create container (doesn't start)
docker create busybox echo hi

# Start the created container
docker start <container_id>

# Run = create + start (combined)
docker run busybox echo hi
```

---

## Container Logs & Interaction

### View Logs

```bash
# View container output
docker logs <container_id>

# Follow logs (tail -f style)
docker logs -f <container_id>

# Show last 50 lines
docker logs --tail 50 <container_id>

# Show timestamps
docker logs -t <container_id>
```

### Interactive Shell

```bash
# Execute interactive shell in running container
docker exec -it <container_id> sh
# -i: Keep STDIN open even if not attached
# -t: Allocate pseudo-terminal

# Create new container with shell
docker run -it busybox sh
```

---

## Container Lifecycle

```bash
# Graceful stop (10 second timeout)
docker stop <container_id>

# Force kill immediately
docker kill <container_id>

# Pause container
docker pause <container_id>

# Resume paused container
docker unpause <container_id>

# Remove container
docker rm <container_id>
```

---

## Image Management

### Build Images

```bash
# Build from Dockerfile in current directory
docker build .

# Build with tag
docker build -t mywebapp:02 .

# Build with multiple tags
docker build -t myapp:latest -t myapp:v1.0 .

# Build with build arguments
docker build --build-arg ENV=production -t myapp .
```

### Image Operations

```bash
# List all images
docker image ls

# Search Docker Hub
docker search nginx

# Pull image from registry
docker pull ubuntu:22.04

# Remove image
docker rmi <image_id>

# Force remove image
docker rmi -f <image_id>

# Tag image
docker tag <image_id> myapp:v1.0

# Push to registry
docker push myapp:v1.0

# Inspect image
docker inspect <image_id>

# Show image history
docker history <image_id>
```

---

## Container Ports & Persistence

### Port Mapping

```bash
# Expose and map port
docker run -d --rm --name myapp -p 5174:3000 <image_id>
# -d: Detach (run in background)
# --rm: Auto-remove on stop
# -p: Port mapping (host:container)

# Expose multiple ports
docker run -p 8080:8000 -p 3306:3306 <image_id>

# Map all exposed ports
docker run -P <image_id>
```

### Volumes (Persistent Storage)

```bash
# Named volume
docker run -t --rm -v myvolume:/myapp/ <image_id>

# Bind mount (local directory)
docker run -v /local/path:/container/path --rm <image_id>

# Read-only mount
docker run -v /data:/data:ro <image_id>

# Create volume
docker volume create myvolume

# List volumes
docker volume ls

# Inspect volume
docker volume inspect myvolume

# Remove volume
docker volume rm myvolume
```

### Environment Variables

```bash
# Pass environment variable
docker run -e DATABASE_URL=postgres://... <image_id>

# From file
docker run --env-file .env <image_id>

# Multiple variables
docker run -e VAR1=value1 -e VAR2=value2 <image_id>
```

---

## Docker Compose

### Basic docker-compose.yml

```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgres://db:5432/myapp
    depends_on:
      - db
  
  db:
    image: postgres:14
    environment:
      - POSTGRES_PASSWORD=password
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  db_data:
```

### Docker Compose Commands

```bash
# Start services
docker compose up

# In background
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs

# Follow logs
docker compose logs -f

# Run one-off command
docker compose exec web python manage.py migrate

# Scale service
docker compose up -d --scale web=3
```

---

## Cleanup & Maintenance

### Remove Stopped Containers

```bash
# Remove stopped containers
docker container prune

# Remove dangling images
docker image prune

# Remove unused volumes
docker volume prune

# Remove all unused resources
docker system prune

# Force cleanup (including in-use)
docker system prune -af
```

---

## Best Practices

✅ **Multi-stage builds** - Reduce image size
✅ **Use .dockerignore** - Exclude files from build context
✅ **Don't run as root** - Security best practice
✅ **Use specific base image tags** - Avoid `latest` in production
✅ **Minimize layers** - Reduce image size and build time
✅ **Health checks** - Monitor container health

### Example Dockerfile

```dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application
COPY . .

# Create non-root user
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD node healthcheck.js

# Start application
CMD ["node", "server.js"]
```

---

## **1. Docker Advanced Networking**

**Types of Networks:**
- **Bridge** (default): Isolated network for containers
- **Host**: Container uses host's network stack
- **Overlay**: Multi-host networking for Swarm/Kubernetes
- **Macvlan**: Assign MAC addresses to containers

**Example - Custom Bridge Network:**
```bash
docker network create my-app-network
docker run --network my-app-network --name flask-app myapp:latest
docker run --network my-app-network --name db postgres:latest
```

## **2. Multistage Builds**

Reduces image size by separating build and runtime stages.

````dockerfile
# Stage 1: Builder
FROM python:3.11-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH
COPY . .
EXPOSE 8000
CMD ["python3", "main.py"]
````

## **3. Multiplatform Builds**

Build images for multiple architectures (ARM64, AMD64, etc.):

```bash
# Enable BuildKit
export DOCKER_BUILDKIT=1

# Build for multiple platforms
docker buildx build --platform linux/amd64,linux/arm64 -t myapp:latest .

# Push to registry
docker buildx build --platform linux/amd64,linux/arm64 -t myapp:latest --push .
```

**Docker Buildx setup:**
```bash
docker buildx create --name mybuilder
docker buildx use mybuilder
docker buildx inspect --bootstrap
```

**Last Updated:** December 22, 2025
