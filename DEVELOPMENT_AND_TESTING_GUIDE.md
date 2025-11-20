# Taiga Frontend Development and Testing Guide

This document provides comprehensive instructions for setting up, running, and testing the Taiga frontend application, with special focus on backend integration scenarios.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Running Frontend on Linux](#2-running-frontend-on-linux)
3. [Using VS Code Dev Container](#3-using-vs-code-dev-container)
4. [Backend Integration Testing](#4-backend-integration-testing)
5. [Automated Testing](#5-automated-testing)
6. [Troubleshooting](#6-troubleshooting)

---

## 1. Project Overview

### Technology Stack

- **Framework**: AngularJS 1.x
- **Language**: CoffeeScript
- **Build Tool**: Gulp
- **Package Manager**: npm
- **Node.js Version**: 16.x (recommended 16.19.1)

### Project Structure

```
taiga-front/
├── app/                    # Application source code
│   ├── coffee/            # CoffeeScript source files
│   │   └── modules/       # Feature modules
│   │       ├── issues/    # Issues module
│   │       └── common/    # Common services
│   ├── styles/            # Stylesheet files
│   ├── partials/          # HTML templates
│   └── locales/           # Translation files
├── dist/                  # Build output directory
│   └── conf.json          # Frontend configuration (Important!)
├── e2e/                   # End-to-end tests
├── gulp/                  # Gulp build tasks
├── package.json           # Dependencies configuration
└── gulpfile.js            # Gulp entry point
```

### Key Feature Locations

- **AI Analysis Service**: `app/coffee/modules/issues/ai-analysis.service.coffee`
- **Performance Monitor**: `app/coffee/modules/common/performance-monitor.service.coffee`
- **Locale Service**: `app/coffee/modules/common/locale.service.coffee`
- **Issues Templates**: `app/partials/issue/`
- **Styles**: `app/styles/extras/`

---

## 2. Running Frontend on Linux

### Ubuntu/Debian Installation

```bash
# 1. Install Node.js 16.x
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version  # Should show v16.x.x
npm --version

# 2. Clone repository
git clone <your-repository-url> taiga-front
cd taiga-front

# 3. Install dependencies
npm install

# 4. Configure backend connection
cp dist/conf.example.json dist/conf.json
nano dist/conf.json
# Update the "api" field with your backend URL

# 5. Start development server
npm start
```

### CentOS/RHEL Installation

```bash
# 1. Install Node.js 16.x
curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo yum install -y nodejs

# Steps 2-5 are the same as Ubuntu
```

### Docker Deployment (Recommended)

```bash
# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM node:16.19.1-alpine

WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Expose port
EXPOSE 9001

# Start command
CMD ["npm", "start"]
EOF

# Build image
docker build -t taiga-front:dev .

# Run container
docker run -d -p 9001:9001 \
  -v $(pwd)/dist/conf.json:/app/dist/conf.json \
  --name taiga-front \
  taiga-front:dev

# View logs
docker logs -f taiga-front
```

**Important**: Replace `localhost` or `127.0.0.1` in the configuration with your actual backend server IP address (e.g., `192.168.1.100`).

---

## 3. Using VS Code Dev Container

Dev Container provides a standardized development environment, eliminating environment configuration issues.

### Prerequisites

#### Required Software

1. **Docker Desktop**
   - macOS: https://www.docker.com/products/docker-desktop
   - Windows: https://www.docker.com/products/docker-desktop
   - Linux: `sudo apt-get install docker.io`

2. **VS Code** with **Remote - Containers** extension
   ```bash
   # Install VS Code, then install the extension
   code --install-extension ms-vscode-remote.remote-containers
   ```

### Dev Container Configuration

Create `.devcontainer` directory in project root:

```bash
cd taiga-front
mkdir -p .devcontainer
```

#### Create `devcontainer.json`

```json
{
  "name": "Taiga Frontend Development",
  "dockerComposeFile": "docker-compose.yml",
  "service": "taiga-front",
  "workspaceFolder": "/workspace",
  
  "postCreateCommand": "npm install",
  
  "forwardPorts": [9001],
  
  "customizations": {
    "vscode": {
      "extensions": [
        "dbaeumer.vscode-eslint",
        "esbenp.prettier-vscode",
        "ms-vscode.vscode-typescript-next",
        "angular.ng-template"
      ],
      "settings": {
        "terminal.integrated.defaultProfile.linux": "bash"
      }
    }
  },
  
  "remoteUser": "node"
}
```

#### Create `docker-compose.yml`

```yaml
version: '3.8'

services:
  taiga-front:
    build:
      context: ..
      dockerfile: .devcontainer/Dockerfile
    
    volumes:
      - ..:/workspace:cached
      - node_modules:/workspace/node_modules
    
    ports:
      - "9001:9001"
    
    command: sleep infinity
    
    environment:
      - NODE_ENV=development

volumes:
  node_modules:
```

#### Create `Dockerfile`

```dockerfile
FROM node:16.19.1

# Install basic tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Install gulp-cli globally
RUN npm install -g gulp-cli

# Switch to node user
USER node
```

### Using Dev Container

1. **Open project in VS Code**
   ```bash
   code ~/path/to/taiga-front
   ```

2. **Open Command Palette** (Cmd/Ctrl + Shift + P)

3. **Select**: `Remote-Containers: Reopen in Container`

4. **Wait for container to build** (takes a few minutes on first run)

5. **Run in container terminal**:
   ```bash
   # Configure backend connection
   cp dist/conf.example.json dist/conf.json
   nano dist/conf.json
   
   # Start development server
   npm start
   ```

6. **Access in browser**: `http://localhost:9001`

### Dev Container Benefits

- ✅ Environment consistency across all developers
- ✅ Quick onboarding without manual dependency installation
- ✅ Isolated from local environment
- ✅ Configuration version-controlled in Git

---

## 4. Backend Integration Testing

### Test Preparation

#### Verify Backend Service is Running

```bash
# Check on backend server
curl http://localhost:8000/api/v1/

# Test from frontend machine (replace with actual IP)
curl http://192.168.1.100:8000/api/v1/
```

#### Configure Frontend to Backend Connection

Edit `dist/conf.json`:

```json
{
    "api": "http://192.168.1.100:8000/api/v1/",
    "debug": true,
    "publicRegisterEnabled": true,
    "feedbackEnabled": true,
    "privacyPolicyUrl": null,
    "termsOfServiceUrl": null,
    "maxUploadFileSize": null,
    "contribPlugins": []
}
```

### Manual Testing Workflow

#### 1. Login to System

- Visit `http://localhost:9001`
- Use default credentials: `admin` / `123123`
- Or create a new account if public registration is enabled

#### 2. Create or Enter Project

- Create a new project or select an existing one
- Navigate to project details page

#### 3. Test Issues Feature

```
# Create test issues:
1. Click "Issues" menu
2. Click "New Issue" button
3. Fill in title and description
4. Save the issue
5. Repeat to create multiple issues
```

#### 4. Test AI Analysis Feature

```
# Perform AI analysis:
1. Select one or more issues (check checkboxes)
2. Click "AI Analysis" button
3. Wait for analysis results (typically 3-10 seconds)
4. Review analysis report in modal
5. Verify priority recommendations, type classifications, and module associations
```

#### 5. Verify Data Communication

Open browser developer tools (F12):

```javascript
// Network tab - Look for API requests
// POST /api/v1/issues/ai_analyze

// Request payload format:
{
    "project_id": 1,
    "issue_ids": [1, 2, 3],
    "issues": [
        {
            "id": 1,
            "subject": "Issue title",
            "description": "Issue description",
            "status": "New",
            "priority": "Normal"
        }
    ]
}

// Response format:
{
    "results": [
        {
            "issue_id": 1,
            "issue_ref": "#1",
            "subject": "Issue title",
            "analysis": {
                "priority": "High",
                "priority_reason": "Critical bug affecting authentication",
                "type": "Bug",
                "severity": "Critical",
                "description": "Detailed analysis...",
                "related_modules": ["Authentication", "Database"],
                "solutions": ["Fix database connection", "Add error handling"],
                "confidence": "0.95"
            }
        }
    ]
}
```

### API Testing with curl/Postman

#### Obtain Authentication Token

```bash
# 1. Login to get token
curl -X POST http://192.168.1.100:8000/api/v1/auth \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "123123",
    "type": "normal"
  }'

# Response contains auth_token
```

#### Test AI Analysis Endpoint

```bash
# 2. Call AI analysis with token
curl -X POST http://192.168.1.100:8000/api/v1/issues/ai_analyze \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "project_id": 1,
    "issue_ids": [1, 2],
    "issues": [
      {
        "id": 1,
        "subject": "Login page inaccessible",
        "description": "Users cannot access login page, getting 500 error"
      },
      {
        "id": 2,
        "subject": "Dashboard loads slowly",
        "description": "Dashboard takes more than 10 seconds to load"
      }
    ]
  }'
```

### Browser DevTools Debugging

#### Console Debugging

```javascript
// Execute in browser Console

// 1. Get Angular injector
var injector = angular.element(document.body).injector();

// 2. Get AI analysis service
var aiService = injector.get('tgAiAnalysisService');

// 3. Manually invoke analysis
aiService.analyzeIssues(1, [1, 2], [
    {id: 1, subject: "Test issue", description: "Test description"}
]).then(function(result) {
    console.log('Analysis result:', result);
});
```

#### Network Monitoring

1. Open DevTools → Network tab
2. Filter by XHR requests
3. Look for `/api/v1/issues/ai_analyze`
4. Inspect request and response data
5. Check response time and status codes

---

## 5. Automated Testing

### Unit Testing

#### Install Test Dependencies

```bash
npm install --save-dev \
  karma \
  karma-chrome-launcher \
  karma-jasmine \
  jasmine-core
```

#### Run Unit Tests

```bash
# Run all tests
npm test

# Run specific test suite
npm test -- --grep="AI Analysis"

# Watch mode for continuous testing
npm test -- --watch
```

#### Example Unit Test

File: `app/coffee/modules/issues/ai-analysis.service.spec.coffee`

```coffeescript
describe "AI Analysis Service", ->
    $httpBackend = null
    aiService = null
    
    beforeEach ->
        module "taigaIssues"
        
        inject ($injector) ->
            $httpBackend = $injector.get("$httpBackend")
            aiService = $injector.get("tgAiAnalysisService")
    
    afterEach ->
        $httpBackend.verifyNoOutstandingExpectation()
        $httpBackend.verifyNoOutstandingRequest()
    
    it "should analyze issues successfully", ->
        projectId = 1
        issueIds = [1, 2]
        issues = [
            {id: 1, subject: "Test Issue", description: "Test Description"}
        ]
        
        mockResponse =
            results: [
                issue_id: 1
                issue_ref: "#1"
                analysis:
                    priority: "High"
                    priority_reason: "Critical bug"
                    related_modules: ["Authentication"]
            ]
        
        $httpBackend
            .expectPOST("/api/v1/issues/ai_analyze")
            .respond(200, mockResponse)
        
        aiService.analyzeIssues(projectId, issueIds, issues)
            .then (result) ->
                expect(result.results.length).toBe(1)
                expect(result.results[0].issueId).toBe(1)
        
        $httpBackend.flush()
```

### End-to-End Testing with Playwright

Playwright is recommended for modern E2E testing.

#### Install Playwright

```bash
npm install --save-dev @playwright/test
npx playwright install
```

#### Create Playwright Configuration

```javascript
// playwright.config.js
module.exports = {
    testDir: './e2e-playwright',
    use: {
        baseURL: 'http://localhost:9001',
        screenshot: 'only-on-failure',
        video: 'retain-on-failure',
    },
    webServer: {
        command: 'npm start',
        port: 9001,
        timeout: 120 * 1000,
        reuseExistingServer: !process.env.CI,
    },
};
```

#### Example E2E Test

File: `e2e-playwright/ai-analysis.spec.js`

```javascript
const { test, expect } = require('@playwright/test');

test.describe('AI Analysis Feature', () => {
    test.beforeEach(async ({ page }) => {
        // Login
        await page.goto('/');
        await page.fill('input[name="username"]', 'admin');
        await page.fill('input[name="password"]', '123123');
        await page.click('button[type="submit"]');
        await page.waitForURL('**/project/**');
    });
    
    test('should create and analyze multiple issues', async ({ page }) => {
        // Navigate to project
        await page.click('.project-item:first-child');
        await page.click('a:has-text("Issues")');
        await page.waitForSelector('.issues-table');
        
        // Create first issue
        await page.click('.new-issue-button');
        await page.fill('input[name="subject"]', 'Login system failure');
        await page.fill('textarea[name="description"]', 
            'Multiple users report inability to login. Returns authentication error.');
        await page.click('button:has-text("Save")');
        await page.waitForURL('**/issues/**');
        
        // Create second issue
        await page.click('a:has-text("Issues")');
        await page.click('.new-issue-button');
        await page.fill('input[name="subject"]', 'Dashboard loading slowly');
        await page.fill('textarea[name="description"]', 
            'Project dashboard takes over 15 seconds to load. Needs performance optimization.');
        await page.click('button:has-text("Save")');
        await page.waitForURL('**/issues/**');
        
        // Return to issues list
        await page.click('a:has-text("Issues")');
        await page.waitForSelector('.issues-table');
        
        // Select created issues
        const checkboxes = page.locator('.issue-checkbox');
        await checkboxes.nth(0).click();
        await checkboxes.nth(1).click();
        
        // Click AI Analysis button
        await page.click('.ai-analysis-button');
        
        // Wait for analysis results
        await page.waitForSelector('.ai-results', { timeout: 30000 });
        
        // Verify results
        const results = await page.locator('.ai-result-item').count();
        expect(results).toBe(2);
        
        // Verify result structure
        const firstResult = page.locator('.ai-result-item').first();
        await expect(firstResult.locator('.issue-ref')).toBeVisible();
        await expect(firstResult.locator('.priority-reason')).toBeVisible();
        await expect(firstResult.locator('.related-modules')).toBeVisible();
        
        // Save screenshot
        await page.screenshot({ 
            path: 'test-results/ai-analysis-results.png',
            fullPage: true 
        });
    });
});
```

#### Run Playwright Tests

```bash
# Run all tests
npx playwright test

# Run specific test
npx playwright test ai-analysis

# Debug mode
npx playwright test --debug

# Generate HTML report
npx playwright test --reporter=html
```

### Integration Test Script

Create complete integration test script `test-integration.sh`:

```bash
#!/bin/bash

echo "🧪 Starting frontend-backend integration tests..."

# Color definitions
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# 1. Check backend service
echo "📡 Checking backend service..."
BACKEND_URL="http://192.168.1.100:8000/api/v1/"
if curl -s "$BACKEND_URL" > /dev/null; then
    echo -e "${GREEN}✓${NC} Backend service is running"
else
    echo -e "${RED}✗${NC} Backend service unavailable"
    exit 1
fi

# 2. Check frontend configuration
echo "⚙️  Checking frontend configuration..."
if grep -q "$BACKEND_URL" dist/conf.json; then
    echo -e "${GREEN}✓${NC} Frontend correctly configured"
else
    echo -e "${RED}✗${NC} Frontend configuration error"
    exit 1
fi

# 3. Start frontend
echo "🚀 Starting frontend service..."
npm start > /dev/null 2>&1 &
FRONTEND_PID=$!
sleep 10

# 4. Run unit tests
echo "🧪 Running unit tests..."
npm test
UNIT_TEST_RESULT=$?

# 5. Run E2E tests
echo "🎭 Running end-to-end tests..."
npx playwright test
E2E_TEST_RESULT=$?

# 6. Cleanup
kill $FRONTEND_PID

# 7. Generate report
echo ""
echo "📊 Test Results Summary"
echo "===================="
if [ $UNIT_TEST_RESULT -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Unit Tests: Passed"
else
    echo -e "${RED}✗${NC} Unit Tests: Failed"
fi

if [ $E2E_TEST_RESULT -eq 0 ]; then
    echo -e "${GREEN}✓${NC} E2E Tests: Passed"
else
    echo -e "${RED}✗${NC} E2E Tests: Failed"
fi

# Exit code
if [ $UNIT_TEST_RESULT -eq 0 ] && [ $E2E_TEST_RESULT -eq 0 ]; then
    echo -e "\n${GREEN}✅ All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed${NC}"
    exit 1
fi
```

Usage:

```bash
chmod +x test-integration.sh
./test-integration.sh
```

---

## 6. Troubleshooting

### Node.js Version Issues

**Problem**: `npm install` fails with version incompatibility errors

**Solution**:
```bash
# Check Node.js version
node --version

# If not 16.x, reinstall
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs

# Clean and reinstall
rm -rf node_modules package-lock.json
npm install
```

### Port Already in Use

**Problem**: Port 9001 already occupied when starting

**Solution**:
```bash
# Find process using port
sudo lsof -ti:9001

# Kill the process
sudo kill -9 $(lsof -ti:9001)

# Or modify port in gulpfile.js
```

### CORS Cross-Origin Issues

**Problem**: Browser console shows CORS errors

**Solution**:

In backend `settings/config.py`:

```python
# Allow frontend domain
CORS_ALLOWED_ORIGINS = [
    "http://localhost:9001",
    "http://127.0.0.1:9001",
]

# Or allow all in development
CORS_ALLOW_ALL_ORIGINS = True
```

### API Connection Failure

**Problem**: Frontend cannot connect to backend API

**Troubleshooting Steps**:

```bash
# 1. Check network connectivity
ping 192.168.1.100

# 2. Check if port is open
telnet 192.168.1.100 8000
# or
nc -zv 192.168.1.100 8000

# 3. Check backend firewall
# On backend server:
sudo ufw status
sudo ufw allow 8000/tcp

# 4. Verify frontend configuration
cat dist/conf.json | grep api

# 5. Test in browser
curl http://192.168.1.100:8000/api/v1/
```

### Build Errors

**Problem**: `gulp` or `npm start` errors

**Solution**:
```bash
# Clear cache
npm cache clean --force

# Remove dependencies and reinstall
rm -rf node_modules package-lock.json
npm install

# If Python-related errors (node-gyp)
npm install --ignore-scripts
```

### AI Feature Not Working

**Problem**: AI Analysis button click has no response

**Troubleshooting**:

1. **Check Browser Console**:
   Look for JavaScript errors

2. **Check Network Requests**:
   - Was POST request sent to `/api/v1/issues/ai_analyze`?
   - What is the response status code?
   - What is the response content?

3. **Check Backend Logs**:
   ```bash
   # On backend server
   tail -f ~/taiga-back-dev/logs/backend.log
   ```

4. **Check Backend Configuration**:
   ```bash
   cat ~/taiga-back-dev/.env
   # Ensure ARK_API_KEY is configured correctly
   ```

---

## 7. Continuous Integration

### GitHub Actions Example

Create `.github/workflows/frontend-test.yml`:

```yaml
name: Frontend Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node-version: [16.x]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run unit tests
      run: npm test
    
    - name: Install Playwright
      run: npx playwright install --with-deps
    
    - name: Run E2E tests
      run: npx playwright test
    
    - name: Upload test results
      if: always()
      uses: actions/upload-artifact@v3
      with:
        name: playwright-report
        path: playwright-report/
```

---

## 8. Summary

This guide covers:

- ✅ Running frontend on Linux (Ubuntu/CentOS + Docker)
- ✅ Using VS Code Dev Container for standardized development
- ✅ Backend integration testing workflows
- ✅ Complete unit testing examples
- ✅ Comprehensive E2E testing with Playwright
- ✅ Troubleshooting common issues
- ✅ CI/CD integration

### Quick Reference

```bash
# Install dependencies
npm install

# Configure backend
nano dist/conf.json

# Start development server
npm start

# Run tests
npm test
npx playwright test

# Build for production
npm run build
```
