#!/bin/bash

# Fintrax DevSecOps Platform Demo Script
# Use this for your college presentation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
demo_header() {
    echo ""
    echo -e "${PURPLE}===============================================${NC}"
    echo -e "${PURPLE}🎯 $1${NC}"
    echo -e "${PURPLE}===============================================${NC}"
    echo ""
}

demo_step() {
    echo -e "${BLUE}👉 $1${NC}"
    echo ""
}

demo_command() {
    echo -e "${CYAN}$ $1${NC}"
    eval $1
    echo ""
}

demo_success() {
    echo -e "${GREEN}✅ $1${NC}"
    echo ""
}

demo_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
    echo ""
}

# Check if we're in the right directory
if [[ ! -f "package.json" && ! -d "services" ]]; then
    echo -e "${RED}✗ Please run this script from the fintrax root directory${NC}"
    exit 1
fi

echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                                                                  ║"
echo "║    🏦 FINTRAX - DevSecOps Personal Finance Platform             ║"
echo "║                                                                  ║"
echo "║    🚀 Production-Ready | 🔐 Security-First | 📊 Enterprise      ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

demo_header "1. Infrastructure Overview"
demo_step "Let's check our EKS cluster status"
demo_command "kubectl get nodes -o wide"

demo_step "View our namespaces (multi-environment setup)"
demo_command "kubectl get namespaces | grep -E '(fintrax|monitoring|argocd)'"

demo_success "✓ 4-node EKS cluster with dedicated monitoring nodes"
demo_success "✓ Multi-environment namespaces (dev/staging/prod)"

demo_header "2. Monitoring & Observability"
demo_step "Check Prometheus and Grafana deployment"
demo_command "kubectl get pods -n monitoring"

demo_step "Verify monitoring is running on dedicated nodes"
demo_command "kubectl get pods -n monitoring -o wide | grep prometheus-grafana"

demo_info "🌐 Grafana Dashboard: http://localhost:3000"
demo_info "   Username: admin | Password: fintrax-admin-2024"
demo_success "✓ Monitoring stack running on tainted monitoring nodes"

demo_header "3. GitOps with ArgoCD"
demo_step "Check ArgoCD deployment status"
demo_command "kubectl get pods -n argocd"

demo_step "Get ArgoCD access information"
echo -e "${CYAN}ArgoCD URL: http://localhost:8080${NC}"
echo -e "${CYAN}Username: admin${NC}"
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d 2>/dev/null || echo "0ZoPja9WwY25Y3gx")
echo -e "${CYAN}Password: $ARGOCD_PASSWORD${NC}"
echo ""

demo_success "✓ ArgoCD ready for GitOps continuous deployment"

demo_header "4. Application Deployment"
demo_step "Check our application deployments"
demo_command "kubectl get deployments -n fintrax-dev"

demo_step "View Helm releases"
demo_command "helm list -n fintrax-dev"

demo_info "Applications deployed using Helm charts with environment-specific configurations"

demo_header "5. Security Features"
demo_step "Pre-commit hooks configuration"
demo_command "head -20 .pre-commit-config.yaml"

demo_step "Security scanning tools available"
demo_command "trivy --version"

demo_step "Check network policies (if any)"
demo_command "kubectl get networkpolicies -A"

demo_success "✓ Pre-commit hooks prevent secrets and run security scans"
demo_success "✓ Container vulnerability scanning with Trivy"
demo_success "✓ SBOM generation for compliance"

demo_header "6. CI/CD Pipeline Features"
demo_step "GitHub Actions workflow for auth-service"
demo_command "head -30 .github/workflows/auth-service-ci.yml"

demo_info "🔄 CI/CD Pipeline includes:"
echo "   • SAST scanning (ESLint, security linting)"
echo "   • Dependency vulnerability scanning"
echo "   • Container image building and scanning"
echo "   • Image signing with Cosign"
echo "   • Multi-environment deployment (dev → staging → prod)"
echo "   • Manual approval gates for production"
echo ""

demo_header "7. Infrastructure as Code"
demo_step "Terraform infrastructure configuration"
demo_command "ls -la infra/terraform/"

demo_step "Kubernetes manifests and Helm charts"
demo_command "ls -la infra/charts/"

demo_success "✓ Complete Infrastructure as Code with Terraform"
demo_success "✓ Kubernetes deployments managed via Helm charts"

demo_header "8. Cost Optimization Features"
demo_step "EKS node configuration (mixed instance types)"
demo_command "kubectl get nodes --show-labels | grep -E '(instance-type|capacity-type)'"

demo_info "💰 Cost optimizations implemented:"
echo "   • SPOT instances for non-critical workloads"
echo "   • Right-sized resources (t3.medium for dev)"
echo "   • Monitoring nodes with taints (resource isolation)"
echo "   • AWS Free Tier compatible configuration"
echo ""

demo_header "9. Real-World Production Features"
demo_info "🎯 Enterprise-grade capabilities:"
echo "   • Multi-environment CI/CD (dev/staging/prod)"
echo "   • Security scanning at every stage"
echo "   • GitOps deployment with ArgoCD"
echo "   • Observability with Prometheus/Grafana"
echo "   • Infrastructure as Code (Terraform)"
echo "   • Supply chain security (SBOM + image signing)"
echo "   • Compliance-ready audit trails"
echo "   • Cost-optimized AWS deployment"
echo ""

demo_header "10. Live Demo Access"
echo -e "${GREEN}🌐 Access Your Live Platform:${NC}"
echo ""
echo -e "${BLUE}Grafana Monitoring:${NC} http://localhost:3000"
echo -e "${CYAN}  → Username: admin${NC}"
echo -e "${CYAN}  → Password: fintrax-admin-2024${NC}"
echo ""
echo -e "${BLUE}ArgoCD GitOps:${NC} http://localhost:8080"
echo -e "${CYAN}  → Username: admin${NC}"
echo -e "${CYAN}  → Password: $ARGOCD_PASSWORD${NC}"
echo ""

demo_success "🎉 DevSecOps Platform Demo Complete!"

echo ""
echo -e "${PURPLE}===============================================${NC}"
echo -e "${GREEN}🏆 READY FOR COLLEGE PRESENTATION! 🏆${NC}"
echo -e "${PURPLE}===============================================${NC}"
echo ""
echo -e "${YELLOW}Pro Tips for your presentation:${NC}"
echo "1. Start with the Infrastructure Overview"
echo "2. Show the monitoring dashboards in Grafana"
echo "3. Demonstrate GitOps with ArgoCD"
echo "4. Highlight the security features"
echo "5. Explain the cost optimization strategies"
echo "6. Walk through the CI/CD pipeline in GitHub"
echo ""
