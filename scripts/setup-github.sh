#!/bin/bash

# Fintrax DevSecOps - GitHub Integration Setup
# Run this script to complete GitHub integration

set -e

echo "🚀 Setting up Fintrax DevSecOps GitHub Integration..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Check if we're in the right directory
if [[ ! -f "package.json" && ! -d "services" ]]; then
    print_error "Please run this script from the fintrax root directory"
    exit 1
fi

# 1. Initialize git repository if not already done
if [[ ! -d ".git" ]]; then
    print_info "Initializing Git repository..."
    git init
    git branch -m main
    print_status "Git repository initialized"
else
    print_status "Git repository already exists"
fi

# 2. Create .gitignore if it doesn't exist
if [[ ! -f ".gitignore" ]]; then
    print_info "Creating .gitignore file..."
    cat > .gitignore << 'EOF'
# Dependencies
node_modules/
*/node_modules/
package-lock.json.backup
yarn-error.log
.pnpm-debug.log*

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Build outputs
dist/
build/
.next/
out/

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# OS files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/
*.lcov

# nyc test coverage
.nyc_output

# Terraform
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl

# Secrets
*.pem
*.key
.secrets.baseline

# Docker
.dockerignore
EOF
    print_status ".gitignore created"
fi

# 3. Add all files to git
print_info "Adding files to git..."
git add .

# 4. Create initial commit
if git diff --staged --quiet; then
    print_warning "No changes to commit"
else
    git commit -m "feat: initial DevSecOps fintrax platform setup

- Complete EKS infrastructure with monitoring
- CI/CD pipelines for auth-service and frontend
- Security scanning with Trivy, pre-commit hooks
- Monitoring with Prometheus and Grafana
- GitOps deployment with ArgoCD
- Supply chain security with SBOM and image signing"
    print_status "Initial commit created"
fi

echo ""
echo "🎯 Next Steps:"
echo "1. Create a new repository on GitHub: https://github.com/new"
echo "2. Repository name: fintrax"
echo "3. Set it to public or private as needed"
echo "4. Run the following commands:"
echo ""
echo -e "${BLUE}git remote add origin https://github.com/YOUR_USERNAME/fintrax.git${NC}"
echo -e "${BLUE}git push -u origin main${NC}"
echo ""
echo "5. Set up the following GitHub Secrets in your repository:"
echo "   - Settings → Secrets and variables → Actions → New repository secret"
echo ""
print_info "Required GitHub Secrets:"
echo "   AWS_ACCESS_KEY_ID          : Your AWS access key"
echo "   AWS_SECRET_ACCESS_KEY      : Your AWS secret key"
echo "   NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY : Your Clerk publishable key"
echo "   CLERK_SECRET_KEY           : Your Clerk secret key"
echo ""
print_info "Optional Secrets (for full functionality):"
echo "   DATABASE_URL               : PostgreSQL connection string"
echo "   PLAID_CLIENT_ID           : Plaid API client ID"
echo "   PLAID_SECRET              : Plaid API secret"
echo ""
echo "6. Push code to trigger CI/CD:"
echo -e "${BLUE}git checkout -b feature/demo${NC}"
echo -e "${BLUE}echo '# Demo update' >> README.md${NC}"
echo -e "${BLUE}git add . && git commit -m 'feat: trigger CI/CD demo'${NC}"
echo -e "${BLUE}git push origin feature/demo${NC}"
echo ""
print_status "Setup script completed!"
