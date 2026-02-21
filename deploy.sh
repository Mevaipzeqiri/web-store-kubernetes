#!/bin/bash

echo "=========================================="
echo "  Web Store - Kubernetes Deployment"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if k8s directory exists
if [ ! -d "k8s" ]; then
    echo -e "${RED}❌ k8s directory not found!${NC}"
    echo "Please make sure you're in the project directory"
    exit 1
fi

# Check if Minikube is running
echo "📌 Step 1: Checking Minikube..."
if ! minikube status > /dev/null 2>&1; then
    echo -e "${RED}❌ Minikube is not running!${NC}"
    echo "Starting Minikube..."
    minikube start --cpus=4 --memory=8192 --driver=docker
    minikube addons enable metrics-server
else
    echo -e "${GREEN}✅ Minikube is running${NC}"
fi
echo ""

# Deploy Namespaces
echo "📌 Step 2: Creating namespaces..."
kubectl apply -f k8s/namespaces/
echo -e "${GREEN}✅ Namespaces created${NC}"
echo ""

# Deploy ConfigMaps
echo "📌 Step 3: Creating ConfigMaps..."
kubectl apply -f k8s/configmaps/
kubectl apply -f k8s/frontend/frontend-configmap-dev.yaml
kubectl apply -f k8s/frontend/frontend-configmap-staging.yaml
kubectl apply -f k8s/frontend/frontend-configmap-prod.yaml
kubectl apply -f k8s/postgres/postgres-init-configmap-dev.yaml
kubectl apply -f k8s/postgres/postgres-init-configmap-staging.yaml
kubectl apply -f k8s/postgres/postgres-init-configmap-prod.yaml
echo -e "${GREEN}✅ ConfigMaps created${NC}"
echo ""

# Deploy Secrets
echo "📌 Step 4: Creating Secrets..."
kubectl apply -f k8s/secrets/
echo -e "${GREEN}✅ Secrets created${NC}"
echo ""

# Deploy PostgreSQL
echo "📌 Step 5: Deploying PostgreSQL..."
kubectl apply -f k8s/postgres/postgres-statefulset-dev.yaml
kubectl apply -f k8s/postgres/postgres-statefulset-staging.yaml
kubectl apply -f k8s/postgres/postgres-statefulset-prod.yaml
echo -e "${YELLOW}⏳ Waiting for PostgreSQL pods to be ready (60-90 seconds)...${NC}"
sleep 30
kubectl wait --for=condition=ready pod -l app=postgres -n development --timeout=180s 2>/dev/null
kubectl wait --for=condition=ready pod -l app=postgres -n staging --timeout=180s 2>/dev/null
kubectl wait --for=condition=ready pod -l app=postgres -n production --timeout=180s 2>/dev/null
echo -e "${GREEN}✅ PostgreSQL deployed and ready${NC}"
echo ""

# Initialize Databases
echo "📌 Step 6: Initializing database schemas..."
echo "  📊 Loading full schema.sql into development..."
kubectl cp backend/database/schema.sql development/postgres-0:/tmp/schema.sql 2>/dev/null
kubectl exec -n development postgres-0 -- psql -U dev_user -d web_store_dev -f /tmp/schema.sql 2>/dev/null && echo -e "  ${GREEN}✅ Development DB initialized${NC}" || echo -e "  ${YELLOW}⚠️  Development DB already initialized${NC}"

echo "  📊 Loading full schema.sql into staging..."
kubectl cp backend/database/schema.sql staging/postgres-0:/tmp/schema.sql 2>/dev/null
kubectl exec -n staging postgres-0 -- psql -U stg_user -d web_store_staging -f /tmp/schema.sql 2>/dev/null && echo -e "  ${GREEN}✅ Staging DB initialized${NC}" || echo -e "  ${YELLOW}⚠️  Staging DB already initialized${NC}"

echo "  📊 Loading full schema.sql into production..."
kubectl cp backend/database/schema.sql production/postgres-0:/tmp/schema.sql 2>/dev/null
kubectl exec -n production postgres-0 -- psql -U prod_user -d web_store_production -f /tmp/schema.sql 2>/dev/null && echo -e "  ${GREEN}✅ Production DB initialized${NC}" || echo -e "  ${YELLOW}⚠️  Production DB already initialized${NC}"

echo -e "${GREEN}✅ All databases initialized with complete schema${NC}"
echo ""

# Deploy Backend
echo "📌 Step 7: Deploying Backend services..."
kubectl apply -f k8s/backend/
echo -e "${YELLOW}⏳ Waiting for backend pods to be ready (30-60 seconds)...${NC}"
sleep 20
kubectl wait --for=condition=ready pod -l app=backend -n development --timeout=180s 2>/dev/null
kubectl wait --for=condition=ready pod -l app=backend -n staging --timeout=180s 2>/dev/null
kubectl wait --for=condition=ready pod -l app=backend -n production --timeout=180s 2>/dev/null
echo -e "${GREEN}✅ Backend services deployed${NC}"
echo ""

# Deploy Frontend
echo "📌 Step 8: Deploying Frontend services..."
kubectl apply -f k8s/frontend/
echo -e "${YELLOW}⏳ Waiting for frontend pods to be ready (30-60 seconds)...${NC}"
sleep 20
kubectl wait --for=condition=ready pod -l app=frontend -n development --timeout=180s 2>/dev/null
kubectl wait --for=condition=ready pod -l app=frontend -n staging --timeout=180s 2>/dev/null
kubectl wait --for=condition=ready pod -l app=frontend -n production --timeout=180s 2>/dev/null
echo -e "${GREEN}✅ Frontend services deployed${NC}"
echo ""

# Deploy Resource Quotas
echo "📌 Step 9: Applying Resource Quotas..."
kubectl apply -f k8s/quotas/
echo -e "${GREEN}✅ Resource quotas applied${NC}"
echo ""

# Deploy Autoscaling
echo "📌 Step 10: Configuring Autoscaling..."

# Install VPA CRDs if not already present
if ! kubectl get crd verticalpodautoscalers.autoscaling.k8s.io &>/dev/null; then
  echo "  📦 Installing VPA CRDs..."
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/vertical-pod-autoscaler/deploy/vpa-v1-crd-gen.yaml
  echo "  ✅ VPA CRDs installed"
else
  echo "  ✅ VPA CRDs already present"
fi

kubectl apply -f k8s/autoscaling/
echo -e "${GREEN}✅ Autoscaling configured (HPA + VPA)${NC}"
echo ""

# Summary
echo "=========================================="
echo -e "${GREEN}🎉 DEPLOYMENT COMPLETE!${NC}"
echo "=========================================="
echo ""
echo "📊 All Pods Status:"
echo ""
echo -e "${YELLOW}DEVELOPMENT:${NC}"
kubectl get pods -n development
echo ""
echo -e "${YELLOW}STAGING:${NC}"
kubectl get pods -n staging
echo ""
echo -e "${YELLOW}PRODUCTION:${NC}"
kubectl get pods -n production
echo ""
echo "=========================================="
echo "🌐 Access Your Application:"
echo "=========================================="
echo ""
echo -e "${YELLOW}To get the URLs, run these commands in separate terminals:${NC}"
echo ""
echo "minikube service frontend -n development --url"
echo "minikube service frontend -n staging --url"
echo "minikube service frontend -n production --url"
echo ""
echo "=========================================="
echo -e "${GREEN}✅ Your Web Store is ready!${NC}"
echo "=========================================="
echo ""
echo "📋 Quick Test Commands:"
echo ""
echo "# Check all pods:"
echo "kubectl get pods --all-namespaces | grep -E 'development|staging|production'"
echo ""
echo "# Check database:"
echo "kubectl exec -n production postgres-0 -- psql -U prod_user -d web_store_production -c 'SELECT * FROM roles;'"
echo ""
echo "# Check HPA:"
echo "kubectl get hpa -n production"
echo ""
