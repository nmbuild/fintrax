#!/bin/bash
set -e

echo "🌿 Setting up GitFlow Branch Strategy for Fintrax"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Not in a git repository${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Git repository detected${NC}"

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${BLUE}📍 Current branch: ${CURRENT_BRANCH}${NC}"

# Create and setup main branch (if not exists)
echo -e "${YELLOW}🌿 Setting up main branch...${NC}"
if ! git show-ref --verify --quiet refs/heads/main; then
    if git show-ref --verify --quiet refs/heads/master; then
        echo -e "${BLUE}📝 Renaming master to main...${NC}"
        git branch -m master main
        echo -e "${GREEN}✅ Renamed master to main${NC}"
    else
        echo -e "${BLUE}📝 Creating main branch...${NC}"
        git checkout -b main
        echo -e "${GREEN}✅ Created main branch${NC}"
    fi
else
    echo -e "${GREEN}✅ Main branch already exists${NC}"
fi

# Create and setup develop branch (if not exists)
echo -e "${YELLOW}🌿 Setting up develop branch...${NC}"
if ! git show-ref --verify --quiet refs/heads/develop; then
    echo -e "${BLUE}📝 Creating develop branch from main...${NC}"
    git checkout main
    git checkout -b develop
    echo -e "${GREEN}✅ Created develop branch${NC}"
else
    echo -e "${GREEN}✅ Develop branch already exists${NC}"
fi

# Create and setup staging branch (if not exists)
echo -e "${YELLOW}🌿 Setting up staging branch...${NC}"
if ! git show-ref --verify --quiet refs/heads/staging; then
    echo -e "${BLUE}📝 Creating staging branch from develop...${NC}"
    git checkout develop
    git checkout -b staging
    echo -e "${GREEN}✅ Created staging branch${NC}"
else
    echo -e "${GREEN}✅ Staging branch already exists${NC}"
fi

# Display branch structure
echo -e "${BLUE}🌳 Current branch structure:${NC}"
git branch -a

# Set up branch protection rules (informational)
echo -e "${YELLOW}📋 Branch Protection Rules (configure in GitHub):${NC}"
echo ""
echo -e "${BLUE}main branch:${NC}"
echo "  • Require pull request reviews (2 reviewers)"
echo "  • Require status checks to pass"
echo "  • Require branches to be up to date"
echo "  • Include administrators"
echo "  • Restrict pushes"
echo ""
echo -e "${BLUE}staging branch:${NC}"
echo "  • Require pull request reviews (1 reviewer)"
echo "  • Require status checks to pass"
echo "  • Require branches to be up to date"
echo ""
echo -e "${BLUE}develop branch:${NC}"
echo "  • Allow direct pushes for development"
echo "  • Require status checks to pass"

# Create .gitflow configuration
echo -e "${YELLOW}⚙️  Creating .gitflow configuration...${NC}"
cat > .gitflow << EOF
[gitflow "branch"]
	master = main
	develop = develop

[gitflow "prefix"]
	feature = feature/
	bugfix = bugfix/
	release = release/
	hotfix = hotfix/
	support = support/
	versiontag = v

[gitflow "path"]
	hooks = .git/hooks
EOF

echo -e "${GREEN}✅ GitFlow configuration created${NC}"

# Show workflow instructions
echo -e "${GREEN}🎉 GitFlow setup completed!${NC}"
echo ""
echo -e "${YELLOW}📋 Development Workflow:${NC}"
echo ""
echo -e "${BLUE}1. Feature Development:${NC}"
echo "   git checkout develop"
echo "   git checkout -b feature/new-feature"
echo "   # ... make changes & test locally ..."
echo "   git push origin feature/new-feature"
echo "   # Create PR: feature/new-feature → develop"
echo "   # NO automatic deployment for feature branches"
echo ""
echo -e "${BLUE}2. Development Testing:${NC}"
echo "   # Merge feature to develop"
echo "   # Auto-deploys to fintrax-dev namespace"
echo "   # Integration testing in shared dev environment"
echo ""
echo -e "${BLUE}3. Staging Release:${NC}"
echo "   git checkout staging"
echo "   git merge develop"
echo "   git push origin staging"
echo "   # Auto-deploys to fintrax-staging namespace"
echo ""
echo -e "${BLUE}4. Production Release:${NC}"
echo "   # Create PR: staging → main"
echo "   # Review & approve"
echo "   # Manual deploy to fintrax-prod namespace"
echo ""
echo -e "${BLUE}5. Environment Mapping:${NC}"
echo "   feature/* → Local only      (docker-compose)"
echo "   develop   → fintrax-dev     (auto-deploy)"
echo "   staging   → fintrax-staging (auto-deploy)"
echo "   main      → fintrax-prod    (manual approval)"
echo ""
echo -e "${YELLOW}🔗 Next Steps:${NC}"
echo "1. Configure branch protection rules in GitHub"
echo "2. Set up GitHub Actions CI/CD workflows"
echo "3. Deploy EKS cluster and namespaces"
echo "4. Configure ArgoCD applications"

# Return to original branch if it exists
if [ "$CURRENT_BRANCH" != "" ] && git show-ref --verify --quiet refs/heads/$CURRENT_BRANCH; then
    git checkout $CURRENT_BRANCH
    echo -e "${BLUE}📍 Returned to original branch: ${CURRENT_BRANCH}${NC}"
fi
