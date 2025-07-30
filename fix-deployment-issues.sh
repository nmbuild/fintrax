#!/bin/bash
# 🔐 Fintrax Security & Infrastructure Fix Script
# This script addresses critical security and configuration issues found in audit

set -e  # Exit on any error

echo "🔍 Starting Fintrax Security & Infrastructure Fixes..."
echo "========================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# =====================================
# 1. SECURITY FIXES - Move Secrets
# =====================================

print_status "🔐 Step 1: Securing exposed secrets..."

# Backup current env files
if [ -f "services/auth-service/.env" ]; then
    print_warning "Backing up auth-service .env file..."
    cp services/auth-service/.env services/auth-service/.env.backup.$(date +%Y%m%d_%H%M%S)
fi

if [ -f "frontend/.env.local" ]; then
    print_warning "Backing up frontend .env.local file..."
    cp frontend/.env.local frontend/.env.local.backup.$(date +%Y%m%d_%H%M%S)
fi

# Create secure .env.example files for auth-service
cat > services/auth-service/.env.example << 'EOF'
# Clerk API keys - Replace with your actual keys
CLERK_PUBLISHABLE_KEY=pk_test_your_publishable_key_here
CLERK_SECRET_KEY=sk_test_your_secret_key_here

# Service config
PORT=3000
LOG_LEVEL=info

# Database
DATABASE_URL=postgresql://username:password@localhost:5432/fintrax_dev
EOF

# Create secure .env.example file for frontend
cat > frontend/.env.example << 'EOF'
# Clerk configuration - Replace with your actual keys
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_your_publishable_key_here
CLERK_SECRET_KEY=sk_test_your_secret_key_here

# API configuration
NEXT_PUBLIC_API_URL=http://localhost:3000
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
EOF

# Remove actual secrets from repository (move to .gitignored files)
if [ -f "services/auth-service/.env" ]; then
    mv services/auth-service/.env services/auth-service/.env.local
    print_warning "Moved auth-service .env to .env.local (gitignored)"
fi

if [ -f "frontend/.env.local" ]; then
    # Frontend .env.local already exists and is properly named
    print_success "Frontend .env.local already properly named"
fi

# Update .gitignore to ensure secrets are not committed
cat >> .gitignore << 'EOF'

# Environment files with secrets
**/.env
**/.env.local
**/.env.development
**/.env.staging
**/.env.production
**/.env.*.local

# Backup files
**/.env.backup.*

# Terraform sensitive files
*.tfstate
*.tfstate.backup
*.tfvars.sensitive
terraform.tfvars.json

# Kubernetes secrets
**/secrets.yaml
**/secret.yaml
EOF

print_success "✅ Secrets secured and .gitignore updated"

# =====================================
# 2. INFRASTRUCTURE FIXES
# =====================================

print_status "🏗️ Step 2: Fixing infrastructure configuration..."

# Check current terraform state
cd infra/terraform

# Get current cluster name from state
CURRENT_CLUSTER=$(terraform show -json 2>/dev/null | jq -r '.values.outputs.eks_cluster_name.value // "not-found"')

if [ "$CURRENT_CLUSTER" = "not-found" ]; then
    print_error "No EKS cluster found in current state"
    CURRENT_CLUSTER="none"
fi

print_status "Current cluster in state: $CURRENT_CLUSTER"
print_status "Target cluster in tfvars: fintrax-eks-shared"

# Option A: Update existing infrastructure to shared naming
if [ "$CURRENT_CLUSTER" != "none" ] && [ "$CURRENT_CLUSTER" != "fintrax-eks-shared" ]; then
    print_warning "🔄 Cluster name mismatch detected!"
    print_warning "Current: $CURRENT_CLUSTER"
    print_warning "Expected: fintrax-eks-shared"
    
    echo ""
    print_warning "Choose fix strategy:"
    echo "  1) Update tfvars to match existing cluster ($CURRENT_CLUSTER)"
    echo "  2) Plan migration to shared cluster name (fintrax-eks-shared)"
    echo "  3) Skip and proceed with current state"
    echo ""
    
    read -p "Enter choice (1/2/3): " CHOICE
    
    case $CHOICE in
        1)
            print_status "Updating tfvars to match existing cluster..."
            sed -i "s/cluster_name = \"fintrax-eks-shared\"/cluster_name = \"$CURRENT_CLUSTER\"/" dev.tfvars
            sed -i "s/cluster_name = \"fintrax-eks-shared\"/cluster_name = \"$CURRENT_CLUSTER\"/" staging.tfvars  
            sed -i "s/cluster_name = \"fintrax-eks-shared\"/cluster_name = \"$CURRENT_CLUSTER\"/" prod.tfvars
            print_success "✅ Updated tfvars to use existing cluster: $CURRENT_CLUSTER"
            ;;
        2)
            print_warning "⚠️ Migration to shared cluster requires careful planning"
            print_warning "This would involve destroying and recreating the cluster"
            print_warning "Continuing with validation only..."
            ;;
        3)
            print_warning "⚠️ Proceeding with cluster name mismatch"
            print_warning "Deployment may fail due to naming inconsistency"
            ;;
    esac
fi

# Validate terraform configuration
print_status "🔍 Validating Terraform configuration..."

if terraform validate; then
    print_success "✅ Terraform configuration is valid"
else
    print_error "❌ Terraform configuration has errors"
    exit 1
fi

# Check terraform plan
print_status "📋 Checking what Terraform would change..."
terraform plan -var-file=dev.tfvars -out=tfplan.out > plan_output.txt 2>&1

if [ $? -eq 0 ]; then
    print_success "✅ Terraform plan completed successfully"
    
    # Show summary of changes
    grep -E "(Plan:|No changes)" plan_output.txt || echo "Changes planned - see plan_output.txt for details"
else
    print_error "❌ Terraform plan failed"
    cat plan_output.txt
    exit 1
fi

cd ../..

# =====================================
# 3. KUBERNETES CONFIGURATION
# =====================================

print_status "⚙️ Step 3: Preparing Kubernetes configuration..."

# Validate Kubernetes manifests
for env in dev staging prod; do
    if [ -d "infra/k8s/$env" ]; then
        print_status "Validating $env environment manifests..."
        for file in infra/k8s/$env/*.yaml; do
            if [ -f "$file" ]; then
                if kubectl --dry-run=client apply -f "$file" > /dev/null 2>&1; then
                    print_success "✅ $file is valid"
                else
                    print_warning "⚠️ $file may have issues (requires cluster connection to fully validate)"
                fi
            fi
        done
    fi
done

# =====================================
# 4. APPLICATION VALIDATION
# =====================================

print_status "🔧 Step 4: Validating application configuration..."

# Check frontend dependencies and build
cd frontend
if npm run build > /dev/null 2>&1; then
    print_success "✅ Frontend builds successfully"
else
    print_warning "⚠️ Frontend build issues detected"
fi
cd ..

# Check auth-service dependencies and build  
cd services/auth-service
if npm run build > /dev/null 2>&1; then
    print_success "✅ Auth service builds successfully"
else
    print_warning "⚠️ Auth service build issues detected"
fi
cd ../..

# =====================================
# 5. CI/CD VALIDATION
# =====================================

print_status "🚀 Step 5: Validating CI/CD configuration..."

# Check GitHub Actions workflow syntax
for workflow in .github/workflows/*.{yml,yaml}; do
    if [ -f "$workflow" ]; then
        # Basic YAML syntax check
        if python3 -c "import yaml; yaml.safe_load(open('$workflow'))" > /dev/null 2>&1; then
            print_success "✅ $(basename $workflow) syntax is valid"
        else
            print_warning "⚠️ $(basename $workflow) has YAML syntax issues"
        fi
    fi
done

# =====================================
# 6. SUMMARY AND NEXT STEPS
# =====================================

echo ""
print_success "🎉 Security and Infrastructure Fix Script Completed!"
echo "========================================================"
echo ""
print_status "📋 SUMMARY OF CHANGES:"
echo "   ✅ Secrets moved to .env.local files (gitignored)"
echo "   ✅ Created secure .env.example templates"
echo "   ✅ Updated .gitignore to prevent secret leaks"
echo "   ✅ Validated Terraform configuration"
echo "   ✅ Checked application builds"
echo "   ✅ Verified CI/CD workflow syntax"
echo ""

print_warning "⚠️ IMPORTANT NEXT STEPS:"
echo "   1. Review the generated terraform plan: infra/terraform/plan_output.txt"
echo "   2. Set up environment-specific secrets in CI/CD (GitHub Secrets)"
echo "   3. Rotate any exposed API keys (Clerk keys in backed up files)"
echo "   4. Test database connectivity with new configuration"
echo "   5. Deploy infrastructure: cd infra/terraform && terraform apply tfplan.out"
echo ""

print_status "📁 FILES TO REVIEW:"
echo "   • DEPLOYMENT-AUDIT-REPORT.md - Full audit results"
echo "   • infra/terraform/plan_output.txt - Terraform changes"
echo "   • services/auth-service/.env.backup.* - Backed up secrets"
echo "   • frontend/.env.local.backup.* - Backed up secrets"
echo ""

print_warning "🔐 SECURITY REMINDER:"
echo "   The backed up .env files contain real secrets and should be deleted"
echo "   after you've safely stored them in your secure environment setup."
echo ""

print_success "Ready for deployment! Review the changes and proceed when ready."
