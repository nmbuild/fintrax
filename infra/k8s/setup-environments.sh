#!/bin/bash
set -e

echo "🚀 Setting up Fintrax Multi-Environment Namespace Architecture"
echo "============================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if kubectl is configured
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ kubectl is not configured or cluster is not reachable${NC}"
    echo "Please run: aws eks update-kubeconfig --region us-east-1 --name fintrax-eks-shared"
    exit 1
fi

echo -e "${GREEN}✅ Kubectl is configured and cluster is reachable${NC}"

# Function to apply namespace configuration
apply_namespace() {
    local env=$1
    local file="environments/${env}-namespace.yaml"
    
    echo -e "${BLUE}📦 Creating ${env} namespace and policies...${NC}"
    
    if kubectl apply -f "$file"; then
        echo -e "${GREEN}✅ ${env} namespace created successfully${NC}"
    else
        echo -e "${RED}❌ Failed to create ${env} namespace${NC}"
        return 1
    fi
}

# Create all namespaces
echo -e "${YELLOW}🏗️  Creating environment namespaces...${NC}"
apply_namespace "dev"
apply_namespace "staging" 
apply_namespace "prod"
apply_namespace "monitoring"

# Verify namespaces
echo -e "${BLUE}🔍 Verifying created namespaces...${NC}"
kubectl get namespaces -l project=fintrax

# Create RBAC for environment isolation
echo -e "${YELLOW}🔐 Setting up RBAC for environment isolation...${NC}"

# Dev environment service account and role
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: fintrax-dev-sa
  namespace: fintrax-dev
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: fintrax-dev
  name: fintrax-dev-role
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: fintrax-dev-binding
  namespace: fintrax-dev
subjects:
- kind: ServiceAccount
  name: fintrax-dev-sa
  namespace: fintrax-dev
roleRef:
  kind: Role
  name: fintrax-dev-role
  apiGroup: rbac.authorization.k8s.io
EOF

# Staging environment service account and role
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: fintrax-staging-sa
  namespace: fintrax-staging
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: fintrax-staging
  name: fintrax-staging-role
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: fintrax-staging-binding
  namespace: fintrax-staging
subjects:
- kind: ServiceAccount
  name: fintrax-staging-sa
  namespace: fintrax-staging
roleRef:
  kind: Role
  name: fintrax-staging-role
  apiGroup: rbac.authorization.k8s.io
EOF

# Production environment service account and role (more restrictive)
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: fintrax-prod-sa
  namespace: fintrax-prod
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: fintrax-prod
  name: fintrax-prod-role
rules:
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "watch", "create", "update", "patch"]
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets"]
  verbs: ["get", "list", "watch", "create", "update", "patch"]
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["get", "list", "watch", "create", "update", "patch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: fintrax-prod-binding
  namespace: fintrax-prod
subjects:
- kind: ServiceAccount
  name: fintrax-prod-sa
  namespace: fintrax-prod
roleRef:
  kind: Role
  name: fintrax-prod-role
  apiGroup: rbac.authorization.k8s.io
EOF

echo -e "${GREEN}✅ RBAC setup completed${NC}"

# Show namespace resource quotas
echo -e "${BLUE}📊 Environment resource quotas:${NC}"
kubectl get resourcequota -A -l project=fintrax

# Show final status
echo -e "${GREEN}🎉 Multi-environment setup completed successfully!${NC}"
echo ""
echo -e "${YELLOW}📋 Summary:${NC}"
echo "• fintrax-dev: Development environment (2 CPU, 4Gi RAM)"
echo "• fintrax-staging: Staging environment (3 CPU, 6Gi RAM)" 
echo "• fintrax-prod: Production environment (4 CPU, 8Gi RAM)"
echo "• monitoring: Shared monitoring stack (2 CPU, 4Gi RAM)"
echo ""
echo -e "${BLUE}🔧 Next steps:${NC}"
echo "1. Deploy applications to respective namespaces"
echo "2. Configure monitoring in the monitoring namespace"
echo "3. Set up ingress controllers and certificates"
echo "4. Configure ArgoCD for GitOps deployment"
