# Web Store - Kubernetes Deployment

A containerized web store application deployed on Kubernetes with three isolated environments.

## 🎯 What This Project Does

This is a complete Kubernetes deployment for a web store application that includes:
- **Frontend**: Angular application with Nginx
- **Backend**: Node.js REST API
- **Database**: PostgreSQL with persistent storage
- **3 Environments**: Development, Staging, and Production

## 📁 Project Structure

```
Project/
├── backend/                # Node.js backend code
├── frontend/               # Angular frontend code
├── k8s/                    # All Kubernetes configurations
│   ├── namespaces/        # 3 environments
│   ├── configmaps/        # Configuration files
│   ├── secrets/           # Passwords and secrets
│   ├── postgres/          # Database setup
│   ├── backend/           # Backend deployment
│   ├── frontend/          # Frontend deployment
│   ├── quotas/            # Resource limits
│   └── autoscaling/       # Auto-scaling rules
└── deploy.sh              # ONE SCRIPT TO DEPLOY EVERYTHING!
```

## ⚡ Quick Start for Testing (3 Steps!)

> **Note:** Docker images are already built and publicly available on Docker Hub.  
> No build step needed — just clone, start Minikube, and deploy!

### Step 1: Install Prerequisites

```bash
# Install Minikube
brew install minikube

# Install kubectl
brew install kubectl

# Make sure Docker Desktop is running
```

### Step 2: Start Minikube

```bash
minikube start --cpus=3 --memory=5120 --driver=docker
minikube addons enable metrics-server
```

### Step 3: Deploy Everything!

```bash
./deploy.sh
```

The script automatically:
- ✅ Creates 3 namespaces (development, staging, production)
- ✅ Applies all ConfigMaps and Secrets
- ✅ Deploys PostgreSQL with persistent storage
- ✅ Loads the complete database schema (backend/database/schema.sql)
- ✅ Deploys backend APIs
- ✅ Deploys frontend (Angular + Nginx)
- ✅ Applies Resource Quotas
- ✅ Installs VPA CRDs and configures HPA + VPA autoscaling
- ✅ Pulls Docker images automatically from Docker Hub (no login needed)

**Total deployment time: ~3-5 minutes**

## 🌐 Access Your Application

After deployment, run these commands to get the URLs:

```bash
# Development environment
minikube service frontend -n development --url

# Staging environment
minikube service frontend -n staging --url

# Production environment
minikube service frontend -n production --url
```

Open the URL in your browser!

## 📊 The 3 Environments

| Environment | CPU Quota | Memory Quota | Replicas | HPA | VPA |
|-------------|-----------|--------------|----------|-----|-----|
| Development | 1 core | 2GB | 1 each | No | Yes (recommendation) |
| Staging | 2 cores | 4GB | 3 each | Yes (max 6) | Yes (recommendation) |
| Production | Unlimited | Unlimited | 3 each | Yes (max 10) | Yes (recommendation) |

## 🐳 Docker Images (Public — No Login Required)

| Image | Docker Hub |
|-------|-----------|
| Backend (Node.js) | `mevaipzeqiri/web-store-backend:latest` |
| Frontend (Angular/Nginx) | `mevaipzeqiri/web-store-frontend:latest` |

## 🛠️ Useful Commands

```bash
# Check if everything is running
kubectl get pods --all-namespaces | grep -E 'development|staging|production'

# Check one environment
kubectl get all -n development

# View backend logs
kubectl logs -n development -l app=backend -f

# View frontend logs
kubectl logs -n development -l app=frontend -f

# Check database
kubectl exec -n development postgres-0 -- psql -U dev_user -d web_store_dev -c 'SELECT * FROM roles;'

# Check autoscaling (staging/production only)
kubectl get hpa -n production
kubectl get vpa -n production
```

## 🔄 Cleanup (Remove Everything)

```bash
# Delete all deployments
kubectl delete namespace development staging production

# Stop Minikube
minikube stop

# Delete Minikube
minikube delete
```

## 📚 Documentation Files

- **INSTALLATION.md** - How to install all prerequisites (Minikube, kubectl, Docker Hub)
- **deploy.sh** - The deployment script

## ✅ Course Requirements

This project meets all requirements:
✅ Multi-component application (Frontend + Backend + Database)  
✅ 3 environments using Kubernetes namespaces  
✅ Deployments for stateless apps  
✅ StatefulSets for database  
✅ Services (ClusterIP, NodePort, Headless)  
✅ PersistentVolumes & PersistentVolumeClaims  
✅ ConfigMaps and Secrets  
✅ Resource Quotas  
✅ Horizontal Pod Autoscaler (HPA)  
✅ Vertical Pod Autoscaler (VPA)
