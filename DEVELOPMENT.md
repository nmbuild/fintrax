# Fintrax DevSecOps - Development Environment Setup

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- kubectl & helm
- Node.js 18+
- AWS CLI configured

### 1. Clone & Setup
```bash
git clone https://github.com/nmbuild/fintrax.git
cd fintrax
npm install -g pre-commit
pre-commit install
```

### 2. Local Development
```bash
# Start local services
docker-compose up -d

# Install dependencies
cd services/auth-service && npm install
cd ../frontend && npm install
```

### 3. Security Checks (Run Before Every Commit)
```bash
# Run all pre-commit hooks
pre-commit run --all-files

# Container security scan
trivy image ghcr.io/nmbuild/fintrax-auth-service:latest

# Generate SBOM
syft packages . -o spdx-json=sbom.json
```

## 🔐 DevSecOps Pipeline Features

### ✅ Security Integration Points
- **Pre-commit Hooks**: Secret detection, linting, formatting
- **SAST**: ESLint, SonarQube integration ready
- **Container Scanning**: Trivy in CI/CD pipeline
- **SBOM Generation**: Software Bill of Materials for compliance
- **Image Signing**: Cosign for supply chain security
- **Dependency Scanning**: npm audit, retire.js
- **IaC Security**: Checkov for Terraform and Kubernetes

### 🚀 Deployment Environments
- **Development**: `fintrax-dev` namespace, auto-deploy from feature branches
- **Staging**: `fintrax-staging` namespace, auto-deploy from main
- **Production**: `fintrax-prod` namespace, manual approval required

### 📊 Monitoring & Observability
- **Prometheus**: Metrics collection on dedicated monitoring nodes
- **Grafana**: Dashboards accessible at `http://localhost:3000`
- **ArgoCD**: GitOps management at `http://localhost:8080`
- **Logs**: Centralized logging with ELK stack (future)

## 🎯 Access Information

### Local Services
- **Grafana**: http://localhost:3000 (admin/fintrax-admin-2024)
- **ArgoCD**: http://localhost:8080 (admin/[generated])

### AWS Infrastructure
- **EKS Cluster**: fintrax-eks-dev (us-east-1)
- **RDS**: PostgreSQL instance for application data
- **S3**: Static assets and backup storage

## 📋 Development Workflow

1. **Feature Development**
   ```bash
   git checkout -b feature/your-feature
   # Make changes
   pre-commit run --all-files
   git commit -m "feat: your feature"
   git push origin feature/your-feature
   ```

2. **CI/CD Process**
   - Security scans run automatically
   - Container images built and scanned
   - Images signed with Cosign
   - Auto-deploy to dev environment

3. **Production Deployment**
   - Merge to main triggers staging deployment
   - Manual approval required for production
   - Post-deployment verification automated

## 🛠️ Troubleshooting

### Common Issues
- **kubectl context**: `aws eks update-kubeconfig --region us-east-1 --name fintrax-eks-dev`
- **Docker permissions**: Add user to docker group
- **Pre-commit failing**: `pre-commit clean` then `pre-commit install`

### Useful Commands
```bash
# Check cluster status
kubectl get nodes
kubectl get pods -A

# View monitoring
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# ArgoCD access
kubectl port-forward -n argocd svc/argocd-server 8080:80
```

## 🔒 Security Best Practices Implemented

- ✅ Secrets never committed to git (pre-commit hook)
- ✅ Container images scanned for vulnerabilities
- ✅ Infrastructure as Code with security policies
- ✅ Network segmentation (namespaces + network policies)
- ✅ RBAC configured for least privilege access
- ✅ Audit logging enabled on EKS
- ✅ Encrypted storage (EBS volumes)
- ✅ Supply chain security with image signing
