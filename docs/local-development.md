# 🏠 Local Development Setup

## **Why No Feature Branch Deployments?**

Feature branches should **NOT** be deployed to cloud environments because:

### **❌ Problems with Feature Branch Deployments:**
- **Cost**: Every feature = new environment = $$$ 
- **Resource Waste**: Most features are short-lived
- **Complexity**: Managing dozens of temporary environments
- **Security**: Exposed unfinished features
- **Database Issues**: Schema conflicts between features

### **✅ Better Approach: Local Development**
- **Docker Compose**: Full stack locally
- **Fast Iteration**: No deployment delays
- **Cost Free**: No cloud resources
- **Privacy**: Work on sensitive features locally
- **Offline**: Work without internet

## 🐳 **Local Development Stack**

### **Docker Compose Setup**
```yaml
# docker-compose.local.yml
version: '3.8'
services:
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    environment:
      - NEXT_PUBLIC_API_URL=http://localhost:3001
    
  auth-service:
    build: ./services/auth-service
    ports:
      - "3001:3001"
    environment:
      - DATABASE_URL=postgresql://fintrax:password@postgres:5432/fintrax_local
      - JWT_SECRET=local-dev-secret
    
  postgres:
    image: postgres:15
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_DB=fintrax_local
      - POSTGRES_USER=fintrax
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  postgres_data:
```

### **Development Workflow**
```bash
# 1. Start local stack
docker-compose -f docker-compose.local.yml up -d

# 2. Work on feature
git checkout develop
git checkout -b feature/user-authentication

# 3. Make changes and test locally
# Frontend: http://localhost:3000
# API: http://localhost:3001
# Database: localhost:5432

# 4. Run tests
npm test
npm run e2e

# 5. Push and create PR
git push origin feature/user-authentication
# Create PR: feature/user-authentication → develop

# 6. Merge triggers deployment to fintrax-dev
```

## 🚀 **Branch Deployment Strategy**

| Branch | Environment | Deployment | Purpose |
|--------|-------------|------------|---------|
| `feature/*` | **Local Only** | Docker Compose | Development & Testing |
| `develop` | **fintrax-dev** | Auto-deploy | Integration Testing |
| `staging` | **fintrax-staging** | Auto-deploy | UAT & QA |
| `main` | **fintrax-prod** | Manual | Production |

## 🛠️ **Local Development Commands**

```bash
# Start development environment
make dev-up

# Stop development environment  
make dev-down

# View logs
make dev-logs

# Reset database
make dev-reset-db

# Run tests
make test

# Run specific service
make dev-service service=auth-service
```

## 📋 **Makefile for Development**

```makefile
# Local development commands
.PHONY: dev-up dev-down dev-logs dev-reset-db test

dev-up:
	docker-compose -f docker-compose.local.yml up -d
	@echo "🚀 Development environment started"
	@echo "Frontend: http://localhost:3000"
	@echo "API: http://localhost:3001"

dev-down:
	docker-compose -f docker-compose.local.yml down
	@echo "🛑 Development environment stopped"

dev-logs:
	docker-compose -f docker-compose.local.yml logs -f

dev-reset-db:
	docker-compose -f docker-compose.local.yml down postgres
	docker volume rm fintrax_postgres_data || true
	docker-compose -f docker-compose.local.yml up -d postgres
	@echo "🗄️ Database reset complete"

test:
	npm run test:unit
	npm run test:integration
	npm run test:e2e

dev-service:
	docker-compose -f docker-compose.local.yml up -d $(service)
	docker-compose -f docker-compose.local.yml logs -f $(service)
```

## 🔥 **Benefits of This Approach**

### **💰 Cost Savings**
- **No cloud costs** for feature development
- **Shared dev environment** for integration testing
- **Efficient resource usage**

### **🚀 Developer Experience**
- **Fast feedback loop** (no deployment wait)
- **Full control** over local environment
- **Offline development** capability
- **Easy debugging** with local tools

### **🔒 Security**
- **No secrets** in feature branches
- **Private development** of sensitive features
- **No exposed endpoints** for unfinished work

### **🎯 Quality**
- **Consistent environment** across team
- **Integration testing** in shared dev environment
- **Proper QA** in staging before production

This approach saves money, improves developer productivity, and maintains proper environment isolation! 🎉
