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

## ⚡ Quick Start (3 Steps!)

### Step 1: Install Prerequisites
**You need to install these first** (see INSTALLATION.md):
1. ✅ Docker (you already have this!)
2. ⬜ Minikube - Local Kubernetes
3. ⬜ kubectl - Kubernetes command tool
4. ⬜ Docker Hub account - To store images

### Step 2: Build and Push Docker Images

```bash
# Build backend image
cd backend
docker build -t mevaipzeqiri/web-store-backend:latest .

# Build frontend image
cd ../frontend
docker build -t mevaipzeqiri/web-store-frontend:latest .

# Login to Docker Hub
docker login

# Push images
docker push mevaipzeqiri/web-store-backend:latest
docker push mevaipzeqiri/web-store-frontend:latest
```

### Step 3: Deploy Everything!

```bash
./deploy.sh
```

That's it! The script will:
- ✅ Start Minikube (if not running)
- ✅ Create 3 environments (dev, staging, production)
- ✅ Deploy PostgreSQL databases
- ✅ Deploy backend APIs
- ✅ Deploy frontend websites
- ✅ Setup autoscaling
- ✅ Show you how to access your application

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

| Environment | CPU | Memory | Pods | Autoscaling |
|-------------|-----|--------|------|-------------|
| Development | 1 core | 2GB | 1 each | No |
| Staging     | 2 cores | 4GB | 3 each | Yes (HPA + VPA) |
| Production  | Unlimited | Unlimited | 3+ each | Yes (HPA + VPA) |

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
kubectl exec -n development postgres-0 -- psql -U webstore_user -d web_store_dev -c 'SELECT * FROM roles;'

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
