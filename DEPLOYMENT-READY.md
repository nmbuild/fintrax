# 🚀 **Fintrax EKS Deployment Guide**

## 📋 **Single Cluster, Multi-Namespace Architecture**

This deployment uses **one EKS cluster** (`fintrax-eks-dev`) with **multiple namespaces** for environment isolation:

```
EKS Cluster: fintrax-eks-dev
├── fintrax-dev (namespace)        # Development environment
├── fintrax-staging (namespace)    # Staging environment  
├── fintrax-prod (namespace)       # Production environment
└── monitoring (namespace)         # Shared monitoring stack
```

---

## 🔥 **Quick Start Deployment**

### **Prerequisites:**
- AWS CLI configured with appropriate permissions
- kubectl installed
- Terraform >= 1.0
- Docker & Docker Compose
- Node.js & Yarn

### **Step 1: Deploy Infrastructure**
```bash
cd infra/terraform

# Initialize and validate
terraform init
terraform validate

# Deploy EKS cluster and infrastructure
terraform apply -var-file=dev.tfvars -auto-approve

# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name fintrax-eks-dev
```

### **Step 2: Create Namespaces**
```bash
# Create namespaces with resource quotas
kubectl apply -f infra/k8s/environments/

# Verify namespaces
kubectl get namespaces
```

### **Step 3: Deploy Applications via GitOps**
```bash
# Install ArgoCD (if not already installed)
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Deploy ArgoCD applications
kubectl apply -f infra/argocd/
```

---

## 🏗️ **Infrastructure Components**

### **EKS Cluster Configuration:**
- **Cluster Name**: `fintrax-eks-dev`
- **Kubernetes Version**: 1.28
- **Node Groups**: 
  - General: 3x t3.medium (ON_DEMAND)
  - Monitoring: 1x t3.medium (SPOT)
- **Encryption**: KMS encrypted secrets
- **Networking**: Custom VPC with public/private subnets

### **Database Setup:**
- **RDS PostgreSQL 15.13**
- **Instance**: db.t3.micro
- **Multi-Environment Databases**:
  - `fintrax_dev` (for development)
  - `fintrax_staging` (for staging)
  - `fintrax_prod` (for production)

---

## 🎯 **Environment-Specific Deployments**

### **Development Environment**
```bash
# Namespace: fintrax-dev
# Branch: develop
# Auto-sync: enabled
kubectl get pods -n fintrax-dev
```

### **Staging Environment**  
```bash
# Namespace: fintrax-staging
# Branch: staging
# Auto-sync: enabled (no self-heal)
kubectl get pods -n fintrax-staging
```

### **Production Environment**
```bash
# Namespace: fintrax-prod  
# Branch: main
# Auto-sync: disabled (manual approval)
kubectl get pods -n fintrax-prod
```

---

## 🔐 **Security Configuration**

### **Secrets Management:**
1. **Local Development**: Use `.env.local` files (gitignored)
2. **Kubernetes**: Store in Kubernetes secrets per namespace
3. **CI/CD**: Use GitHub Secrets for pipeline variables

### **Environment Variables Required:**
```bash
# Clerk Authentication
CLERK_PUBLISHABLE_KEY=pk_test_...
CLERK_SECRET_KEY=sk_test_...

# Database (injected automatically)
DATABASE_URL=postgresql://...

# Service Configuration
NODE_ENV=development|staging|production
PORT=3000
LOG_LEVEL=debug|info|warn
```

---

## 🧪 **Local Development**

### **Using Docker Compose:**
```bash
# Start all services locally
docker-compose up -d

# Services available at:
# - Frontend: http://localhost:3000
# - Auth Service: http://localhost:3001  
# - PostgreSQL: localhost:5432
```

### **Native Development:**
```bash
# Terminal 1: Start database
docker-compose up postgres

# Terminal 2: Start auth service
cd services/auth-service
yarn dev

# Terminal 3: Start frontend  
cd frontend
yarn dev
```

---

## 📊 **Monitoring & Observability**

### **Cluster Monitoring:**
```bash
# Check cluster status
kubectl cluster-info
kubectl get nodes
kubectl top nodes

# Check namespace resource usage
kubectl describe quota -n fintrax-dev
kubectl describe quota -n fintrax-staging  
kubectl describe quota -n fintrax-prod
```

### **Application Monitoring:**
```bash
# Check application pods
kubectl get pods -A
kubectl logs -f deployment/frontend -n fintrax-dev
kubectl logs -f deployment/auth-service -n fintrax-dev
```

---

## 🔄 **GitOps Workflow**

### **Development Flow:**
```bash
feature/branch → local development (Docker Compose)
    ↓
develop → fintrax-dev (auto-deploy)
    ↓  
staging → fintrax-staging (auto-deploy)
    ↓
main → fintrax-prod (manual approval)
```

### **Deployment Commands:**
```bash
# Deploy to dev (automatic on push to develop)
git checkout develop
git merge feature/your-feature
git push origin develop

# Deploy to staging
git checkout staging  
git merge develop
git push origin staging

# Deploy to production (requires manual ArgoCD sync)
git checkout main
git merge staging
git push origin main
```

---

## 🛠️ **Troubleshooting**

### **Common Issues:**

1. **Cluster Name Mismatch:**
   ```bash
   # Current cluster name: fintrax-eks-dev
   # All tfvars files updated to match this name
   ```

2. **Missing Secrets:**
   ```bash
   # Check secrets in namespace
   kubectl get secrets -n fintrax-dev
   
   # Create missing secrets
   kubectl create secret generic app-secrets \
     --from-literal=CLERK_PUBLISHABLE_KEY=pk_test_... \
     --from-literal=CLERK_SECRET_KEY=sk_test_... \
     -n fintrax-dev
   ```

3. **Pod Issues:**
   ```bash
   # Debug pod issues
   kubectl describe pod <pod-name> -n <namespace>
   kubectl logs <pod-name> -n <namespace>
   ```

### **Useful Commands:**
```bash
# Get cluster info
terraform output kubeconfig_command
terraform output db_endpoint

# Scale deployments
kubectl scale deployment frontend --replicas=3 -n fintrax-dev

# Port forward for testing
kubectl port-forward svc/frontend 8080:3000 -n fintrax-dev
```

---

## 📈 **Cost Optimization**

### **Current Setup Costs:**
- **EKS Control Plane**: ~$72/month
- **Worker Nodes**: 3x t3.medium = ~$95/month
- **Monitoring Node**: 1x t3.medium SPOT = ~$15/month
- **RDS PostgreSQL**: db.t3.micro = ~$13/month
- **Total**: ~$195/month

### **Cost Savings vs Multi-Cluster:**
- **Single Cluster**: $195/month
- **3 Separate Clusters**: $406/month  
- **Savings**: $211/month (52% reduction)

---

## 🚀 **Production Readiness**

### **Security Checklist:**
- [x] Secrets stored securely (not in git)
- [x] RBAC configured per namespace
- [x] Network policies for traffic isolation
- [x] Resource quotas to prevent resource starvation
- [x] KMS encryption for cluster secrets
- [x] Private subnets for worker nodes

### **Reliability Checklist:**
- [x] Multi-AZ deployment
- [x] Auto-scaling configured
- [x] Health checks implemented
- [x] Resource limits defined
- [x] Monitoring and alerting ready
- [x] Backup strategy for database

---

**🎉 Your Fintrax application is now ready for production deployment on EKS!**

**Next Steps:**
1. Set up your actual Clerk API keys
2. Configure domain names and SSL certificates
3. Set up monitoring dashboards  
4. Configure backup schedules
5. Set up CI/CD secrets in GitHub
