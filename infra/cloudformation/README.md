# 🏗️ FinTrax Infrastructure Management

This directory contains CloudFormation templates and GitHub Actions workflows for managing FinTrax infrastructure on AWS.

## 📁 Directory Structure

```
infra/cloudformation/
├── fintrax-infrastructure.yaml    # Main CloudFormation template
├── parameters-dev.json           # Development environment parameters
├── parameters-staging.json       # Staging environment parameters
├── parameters-prod.json          # Production environment parameters
└── README.md                     # This file
```

## 🚀 How to Deploy/Delete Infrastructure

### Using GitHub Actions (Recommended)

1. **Go to GitHub Actions** in your repository
2. **Select "🏗️ Infrastructure Management"** workflow
3. **Click "Run workflow"**
4. **Choose your options:**
   - **Action:** `deploy`, `delete`, or `list`
   - **Environment:** `dev`, `staging`, or `prod`
   - **Confirm Delete:** Type `DELETE` (only for delete action)

### Manual Deployment (Alternative)

```bash
# Deploy development environment
aws cloudformation create-stack \
  --stack-name fintrax-dev \
  --template-body file://fintrax-infrastructure.yaml \
  --parameters file://parameters-dev.json \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
  --region us-east-1

# Delete development environment
aws cloudformation delete-stack \
  --stack-name fintrax-dev \
  --region us-east-1
```

## 📋 What Gets Created

### AWS Resources:
- **🌐 VPC** with public/private subnets
- **🚀 EKS Cluster** with managed node groups
- **🗄️ RDS PostgreSQL** database (private)
- **📦 S3 Bucket** for static assets (public)
- **🛡️ Security Groups** and IAM roles
- **🔧 EKS Add-ons** (VPC CNI, CoreDNS, EBS CSI)

### Estimated Monthly Costs:
- **Dev Environment:** ~$120/month
- **Staging Environment:** ~$150/month
- **Production Environment:** ~$200/month

## 🛡️ Security Features

- **Private Database:** RDS in private subnets
- **IAM Roles:** Principle of least privilege
- **Security Groups:** Restrictive ingress rules
- **Encryption:** S3 server-side encryption
- **Logging:** EKS control plane logging enabled

## 🎯 After Deployment

1. **Update kubeconfig:**
   ```bash
   aws eks update-kubeconfig --name fintrax-eks-dev --region us-east-1
   ```

2. **Deploy ArgoCD:**
   ```bash
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

3. **Deploy your applications** via GitOps workflows

## 🔧 Environment Customization

Edit the parameter files to customize each environment:
- **Node counts and instance types**
- **Database configuration**
- **S3 bucket names**
- **Kubernetes version**

## 💰 Cost Management

- **Monitor AWS billing dashboard**
- **Delete stacks when not in use**
- **Use smaller instance types for dev/testing**
- **Enable AWS Budget alerts**

## 🚨 Important Notes

- **Deletion is permanent** - make sure to backup data
- **S3 bucket names must be globally unique**
- **Database passwords are stored in CloudFormation**
- **EKS control plane charges $0.10/hour (24/7)**

## 🔗 Related Documentation

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [CloudFormation Documentation](https://docs.aws.amazon.com/cloudformation/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [FinTrax GitOps Setup](../gitops/README.md)
