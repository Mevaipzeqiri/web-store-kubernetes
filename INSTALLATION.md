# Installation Guide - Complete Setup from Scratch

## What You Need to Install

1. ✅ Docker (You already have this!)
2. Minikube - Local Kubernetes cluster
3. kubectl - Kubernetes command-line tool
4. Docker Hub Account - For storing your images

---

## Step 1: Install Homebrew (if you don't have it)

```bash
brew --version
```

If not installed, install it:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

---

## Step 2: Install kubectl

```bash
# Install kubectl
brew install kubectl

# Verify installation
kubectl version --client
```

## Step 3: Install Minikube

```bash
# Install Minikube
brew install minikube

# Verify installation
minikube version
```

---

## Step 4: Start Minikube

```bash
minikube start --cpus=3 --memory=5120 --driver=docker

```

**Verify Minikube is running:**
```bash
minikube status
```

**Enable metrics-server** (needed for autoscaling):
```bash
minikube addons enable metrics-server
```

---

## Step 5: Verify kubectl Works

```bash
kubectl cluster-info

kubectl get nodes

```

**Expected Output:**
```
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   1m    v1.x.x
```

---

## Step 6: Docker Hub Account

**Login to Docker Hub from terminal:**
```bash
docker login
```

Enter your Docker Hub username and password.

---

## Step 7: Build Your Docker Images

Now you're ready to build and push the images for your project.

```bash
cd "/Users/mevaipzeqiri/Documents/University/2.Master/Semester 1/4.Containerized Architecture/Project"

cd backend
docker build -t mevaipzeqiri/web-store-backend:latest .

cd ../frontend
docker build -t mevaipzeqiri/web-store-frontend:latest .
```

---

## Step 8: Push Images to Docker Hub

```bash
docker push mevaipzeqiri/web-store-backend:latest

docker push mevaipzeqiri/web-store-frontend:latest
```
---
---

## Step 10: Deploy Your Application!

```bash
cd "/Users/mevaipzeqiri/Documents/University/2.Master/Semester 1/4.Containerized Architecture/Project"

./deploy.sh
```

The script will:
1. Check Minikube is running
2. Create 3 namespaces (development, staging, production)
3. Deploy PostgreSQL databases
4. Deploy backend APIs
5. Deploy frontend applications
6. Setup autoscaling
7. Show you the status


---

## Step 11: Access Your Application

After deployment completes, get the URLs:

```bash
minikube service frontend -n development --url

minikube service frontend -n staging --url

minikube service frontend -n production --url
```
---

## Useful Commands

### Minikube Commands
```bash
# Start Minikube
minikube start

# Stop Minikube (keeps everything, just pauses)
minikube stop

# Delete Minikube (removes everything)
minikube delete

# Check status
minikube status

# Open Kubernetes dashboard
minikube dashboard
```

### kubectl Commands
```bash
# Get all pods
kubectl get pods --all-namespaces

# Get pods in one namespace
kubectl get pods -n development

# Get all resources
kubectl get all -n development

# View logs
kubectl logs <pod-name> -n development

# Describe pod (for troubleshooting)
kubectl describe pod <pod-name> -n development

# Delete namespace
kubectl delete namespace development
```

### Docker Commands
```bash
# List images
docker images

# Remove image
docker rmi <image-name>

# Check running containers
docker ps

# Login to Docker Hub
docker login
```
