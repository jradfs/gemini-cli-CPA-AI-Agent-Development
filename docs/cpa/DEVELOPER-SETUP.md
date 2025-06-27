# 🛠️ CPA AI Agent Developer Setup Guide

**Project:** Gemini CLI Enhanced for CPA Workflows  
**Version:** 1.0  
**Created:** 2024-12-27  
**Target:** Development Team

---

## 🎯 **Quick Start**

Get your CPA AI Agent development environment running in under 10 minutes:

```bash
# 1. Clone and setup
git clone https://github.com/jradfs/gemini-cli-CPA-AI-Agent-Development.git
cd gemini-cli-CPA-AI-Agent-Development

# 2. Install dependencies
npm install

# 3. Set up CPA package
cd packages/cpa
npm install

# 4. Configure environment
cp .env.example .env
# Edit .env with your API keys

# 5. Build and test
npm run build
npm test

# 6. Start development
npm run dev
```

---

## 📋 **Prerequisites**

### **Required Software**
- **Node.js:** v18+ (Latest LTS recommended)
- **npm:** v9+ (comes with Node.js)
- **Git:** Latest version
- **VS Code:** Recommended IDE with extensions
- **Docker:** For running MCP servers locally (optional)

### **Development Accounts**
- **Google AI Studio:** For Gemini API access
- **QuickBooks Developer:** For accounting integration
- **Square Developer:** For payment processing
- **Plaid Account:** For banking integration
- **Gmail API:** For client communication

### **VS Code Extensions (Recommended)**
```json
{
  "recommendations": [
    "ms-vscode.vscode-typescript-next",
    "esbenp.prettier-vscode",
    "ms-vscode.vscode-eslint",
    "bradlc.vscode-tailwindcss",
    "ms-vscode.vscode-jest",
    "ms-vscode.vscode-json",
    "redhat.vscode-yaml"
  ]
}
```

---

## 🏗️ **Project Structure**

### **Repository Layout**
```
gemini-cli-CPA-AI-Agent-Development/
├── packages/
│   ├── cli/                    # Original Gemini CLI
│   ├── core/                   # Original Gemini Core
│   └── cpa/                    # 🆕 CPA AI Agent Package
│       ├── src/                # Source code
│       ├── tests/              # Test suites
│       ├── docs/               # Package documentation
│       ├── examples/           # Usage examples
│       ├── mcp-servers/        # Custom MCP servers
│       └── scripts/            # Build/development scripts
├── docs/cpa/                   # CPA-specific documentation
├── scripts/                    # Project scripts
└── integration-tests/          # End-to-end tests
```

### **Development Workflow**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Core CLI      │    │   CPA Package   │    │  MCP Servers    │
│   (Unchanged)   │◄──►│  (New Package)  │◄──►│  (Integrations) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │                       │                       │
        └───────────────────────┼───────────────────────┘
                                │
                    ┌─────────────────┐
                    │  Your Changes   │
                    │   (Focus Here)  │
                    └─────────────────┘
```

---

## ⚙️ **Environment Setup**

### **1. Clone Repository**
```bash
# Clone your fork
git clone https://github.com/jradfs/gemini-cli-CPA-AI-Agent-Development.git
cd gemini-cli-CPA-AI-Agent-Development

# Add upstream remote for syncing
git remote add upstream https://github.com/google-gemini/gemini-cli.git

# Verify remotes
git remote -v
# origin    https://github.com/jradfs/gemini-cli-CPA-AI-Agent-Development.git (fetch)
# origin    https://github.com/jradfs/gemini-cli-CPA-AI-Agent-Development.git (push)
# upstream  https://github.com/google-gemini/gemini-cli.git (fetch)
# upstream  https://github.com/google-gemini/gemini-cli.git (push)
```

### **2. Install Dependencies**
```bash
# Install root dependencies
npm install

# Build core packages first
npm run build

# Verify core CLI works
./packages/cli/dist/gemini.js --version
```

### **3. Set Up CPA Package**
```bash
# Navigate to CPA package
cd packages/cpa

# Initialize if not exists
if [ ! -f package.json ]; then
  npm init -y
  # Configure package (see Implementation Guide)
fi

# Install CPA dependencies
npm install

# Link to core packages
npm link ../core
npm link ../cli
```

### **4. Environment Configuration**
```bash
# Create environment file
cp .env.example .env

# Edit with your configuration
nano .env
```

**Required Environment Variables:**
```bash
# .env file
# Gemini AI
GEMINI_API_KEY="your_gemini_api_key_here"

# QuickBooks Integration
QUICKBOOKS_CLIENT_ID="your_quickbooks_client_id"
QUICKBOOKS_CLIENT_SECRET="your_quickbooks_client_secret"
QUICKBOOKS_ENVIRONMENT="sandbox"  # or "production"

# Square Integration
SQUARE_APPLICATION_ID="your_square_app_id"
SQUARE_ACCESS_TOKEN="your_square_access_token"
SQUARE_ENVIRONMENT="sandbox"      # or "production"

# Gmail Integration
GMAIL_CLIENT_ID="your_gmail_client_id"
GMAIL_CLIENT_SECRET="your_gmail_client_secret"
GMAIL_REFRESH_TOKEN="your_gmail_refresh_token"

# Banking Integration (Plaid)
PLAID_CLIENT_ID="your_plaid_client_id"
PLAID_SECRET="your_plaid_secret"
PLAID_ENVIRONMENT="sandbox"       # or "production"

# Database
DATABASE_URL="postgresql://localhost/cpa_agent_dev"

# Storage
CPA_STORAGE_PROVIDER="local"      # or "aws", "gcp", "azure"
AWS_ACCESS_KEY_ID="your_aws_key"  # if using AWS
AWS_SECRET_ACCESS_KEY="your_aws_secret"
S3_BUCKET_NAME="cpa-documents-dev"

# Security
CPA_ENCRYPTION_ENABLED="true"
CPA_AUDIT_LOGGING="true"
JWT_SECRET="your_jwt_secret_for_dev"
ENCRYPTION_KEY="your_encryption_key_for_dev"

# Development
NODE_ENV="development"
DEBUG="cpa:*"
LOG_LEVEL="debug"
```

---

## 🔧 **Development Commands**

### **Core Development**
```bash
# Build everything
npm run build

# Build only CPA package
cd packages/cpa && npm run build

# Watch mode for development
npm run dev

# Run specific package in watch mode
cd packages/cpa && npm run dev
```

### **Testing**
```bash
# Run all tests
npm test

# Run CPA tests only
cd packages/cpa && npm test

# Run tests in watch mode
npm run test:watch

# Run integration tests
npm run test:integration

# Run specific test file
npm test -- client-command.test.ts

# Coverage report
npm run test:coverage
```

### **Code Quality**
```bash
# Lint code
npm run lint

# Fix linting issues
npm run lint:fix

# Format code
npm run format

# Type checking
npm run type-check

# Run all quality checks
npm run quality
```

### **MCP Server Development**
```bash
# Start MCP servers locally
cd packages/cpa/mcp-servers
npm run start:all

# Start specific MCP server
npm run start:quickbooks
npm run start:square
npm run start:gmail
npm run start:banking

# Test MCP server connections
npm run test:mcp
```

---

## 🐛 **Debugging Setup**

### **VS Code Debug Configuration**
```json
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug CPA Package",
      "type": "node",
      "request": "launch",
      "program": "${workspaceFolder}/packages/cli/dist/gemini.js",
      "args": [],
      "env": {
        "NODE_ENV": "development",
        "DEBUG": "cpa:*"
      },
      "sourceMaps": true,
      "outFiles": [
        "${workspaceFolder}/packages/*/dist/**/*.js"
      ],
      "skipFiles": [
        "<node_internals>/**"
      ]
    },
    {
      "name": "Debug CPA Tests",
      "type": "node",
      "request": "launch",
      "program": "${workspaceFolder}/node_modules/.bin/jest",
      "args": [
        "--runInBand",
        "--no-cache",
        "${workspaceFolder}/packages/cpa/tests"
      ],
      "env": {
        "NODE_ENV": "test"
      },
      "sourceMaps": true,
      "outFiles": [
        "${workspaceFolder}/packages/*/dist/**/*.js"
      ]
    },
    {
      "name": "Debug MCP Server",
      "type": "node",
      "request": "launch",
      "program": "${workspaceFolder}/packages/cpa/mcp-servers/quickbooks/index.js",
      "env": {
        "NODE_ENV": "development",
        "DEBUG": "mcp:*"
      }
    }
  ]
}
```

### **Debug Logging**
```typescript
// packages/cpa/src/utils/debug.ts
import debug from 'debug'

export const debugCPA = debug('cpa:main')
export const debugCommands = debug('cpa:commands')
export const debugWorkflows = debug('cpa:workflows')
export const debugMCP = debug('cpa:mcp')
export const debugContext = debug('cpa:context')

// Usage in code
debugCommands('Client command executed: %s', clientName)
debugWorkflows('Morning briefing generated for client: %s', client.id)
debugMCP('QuickBooks MCP server connected')
```

---

## 🧪 **Testing Strategy**

### **Test Structure**
```
packages/cpa/tests/
├── unit/                       # Unit tests (fast, isolated)
│   ├── commands/               # Command logic tests
│   ├── workflows/              # Workflow engine tests
│   ├── integrations/           # Integration wrapper tests
│   └── utils/                  # Utility function tests
├── integration/                # Integration tests (slower, with services)
│   ├── mcp-servers/            # MCP server integration tests
│   ├── database/               # Database integration tests
│   └── external-apis/          # External API tests (mocked)
├── e2e/                        # End-to-end tests (full workflows)
│   ├── user-scenarios/         # Complete user journey tests
│   └── automation/             # Automation workflow tests
├── fixtures/                   # Test data
├── mocks/                      # Mock implementations
└── setup/                      # Test setup utilities
```

### **Writing Tests**
```typescript
// Example unit test
// packages/cpa/tests/unit/commands/client-command.test.ts
import { ClientCommand } from '../../../src/commands/client-command'
import { createMockClientManager } from '../../mocks/client-manager'

describe('ClientCommand', () => {
  let command: ClientCommand
  let mockClientManager: MockClientManager

  beforeEach(() => {
    mockClientManager = createMockClientManager()
    command = new ClientCommand(mockClientManager)
  })

  it('should switch to client context', async () => {
    const mockClient = { id: '1', name: 'Test Client' }
    mockClientManager.switchToClient.mockResolvedValue(mockClient)

    const result = await command.action('client', undefined, 'Test Client')

    expect(result.message).toContain('Switched to Client: Test Client')
    expect(mockClientManager.switchToClient).toHaveBeenCalledWith('Test Client')
  })
})
```

### **Running Tests**
```bash
# Run specific test types
npm run test:unit
npm run test:integration
npm run test:e2e

# Run tests for specific component
npm test -- --testPathPattern=commands

# Run tests in watch mode
npm run test:watch

# Generate coverage report
npm run test:coverage
# Open coverage/lcov-report/index.html
```

---

## 🔌 **MCP Server Development**

### **Local MCP Server Setup**
```bash
# Navigate to MCP servers directory
cd packages/cpa/mcp-servers

# Set up QuickBooks MCP server
cd quickbooks
npm init -y
npm install @modelcontextprotocol/sdk

# Create basic server structure
mkdir src
touch src/index.ts
```

### **QuickBooks MCP Server Example**
```typescript
// packages/cpa/mcp-servers/quickbooks/src/index.ts
import { Server } from '@modelcontextprotocol/sdk/server/index.js'
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js'

const server = new Server(
  {
    name: 'cpa-quickbooks-server',
    version: '1.0.0'
  },
  {
    capabilities: {
      tools: {}
    }
  }
)

// Register QuickBooks tools
server.setRequestHandler('tools/list', async () => {
  return {
    tools: [
      {
        name: 'create_journal_entry',
        description: 'Create a journal entry in QuickBooks',
        inputSchema: {
          type: 'object',
          properties: {
            date: { type: 'string', format: 'date' },
            lines: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  account: { type: 'string' },
                  debit: { type: 'number' },
                  credit: { type: 'number' }
                }
              }
            },
            memo: { type: 'string' }
          },
          required: ['date', 'lines']
        }
      }
    ]
  }
})

server.setRequestHandler('tools/call', async (request) => {
  if (request.params.name === 'create_journal_entry') {
    // Implement QuickBooks API call
    const journalEntry = await createQuickBooksJournalEntry(request.params.arguments)
    return {
      content: [
        {
          type: 'text',
          text: `Journal entry created: ${journalEntry.id}`
        }
      ]
    }
  }
})

// Start server
const transport = new StdioServerTransport()
server.connect(transport)
```

### **Testing MCP Servers**
```bash
# Test MCP server manually
echo '{"jsonrpc": "2.0", "id": 1, "method": "tools/list", "params": {}}' | \
  node packages/cpa/mcp-servers/quickbooks/dist/index.js

# Run MCP server tests
cd packages/cpa/mcp-servers/quickbooks
npm test
```

---

## 🏃‍♂️ **Development Workflow**

### **Daily Development Process**
```bash
# 1. Start development session
npm run dev                    # Start in watch mode

# 2. Open second terminal for testing
npm run test:watch            # Run tests in watch mode

# 3. Open third terminal for MCP servers
cd packages/cpa/mcp-servers
npm run start:all             # Start all MCP servers locally

# 4. Start coding!
# Edit files in packages/cpa/src/
# Tests run automatically on save
# Rebuild happens automatically on save
```

### **Feature Development Process**
```bash
# 1. Create feature branch
git checkout -b feature/add-client-onboarding

# 2. Implement feature
# - Write tests first (TDD approach)
# - Implement functionality
# - Test integration with MCP servers

# 3. Verify everything works
npm run build
npm test
npm run lint

# 4. Commit and push
git add .
git commit -m "feat: Add client onboarding workflow"
git push origin feature/add-client-onboarding

# 5. Create pull request
gh pr create --title "feat: Add client onboarding workflow"
```

### **Syncing with Upstream**
```bash
# Regularly sync with upstream Gemini CLI
git fetch upstream
git checkout main
git merge upstream/main
git push origin main

# Rebase feature branches
git checkout feature/your-feature
git rebase main
```

---

## 📊 **Performance Monitoring**

### **Development Performance Tools**
```bash
# Monitor build performance
npm run build:analyze

# Monitor test performance
npm run test:benchmark

# Monitor MCP server performance
npm run mcp:benchmark

# Profile memory usage
node --inspect packages/cli/dist/gemini.js
# Open chrome://inspect in Chrome
```

### **Performance Benchmarks**
```typescript
// packages/cpa/tests/performance/benchmark.test.ts
describe('Performance Benchmarks', () => {
  it('should process receipt in under 2 seconds', async () => {
    const startTime = Date.now()
    
    await documentProcessor.processReceipt(sampleReceipt, sampleClient)
    
    const duration = Date.now() - startTime
    expect(duration).toBeLessThan(2000) // 2 seconds
  })

  it('should generate morning briefing in under 1 second', async () => {
    const startTime = Date.now()
    
    await morningBriefingWorkflow.generate(sampleClient)
    
    const duration = Date.now() - startTime
    expect(duration).toBeLessThan(1000) // 1 second
  })
})
```

---

## 🔒 **Security Development**

### **Security Testing**
```bash
# Security audit
npm audit

# Check for vulnerabilities
npm run security:check

# Test encryption/decryption
npm run test:security

# Validate access controls
npm run test:permissions
```

### **Security Guidelines**
- **Never commit API keys** - Use environment variables
- **Encrypt sensitive data** - Use CPAEncryption class
- **Validate all inputs** - Use schema validation
- **Log security events** - Use audit logging
- **Test permissions** - Write access control tests

---

## 📚 **Learning Resources**

### **Gemini CLI Architecture**
- [Core Package Documentation](../../packages/core/README.md)
- [CLI Package Documentation](../../packages/cli/README.md)
- [MCP Protocol Documentation](https://modelcontextprotocol.io/)

### **CPA AI Agent Specific**
- [Technical Architecture](./TECHNICAL-ARCHITECTURE.md)
- [Implementation Guide](./IMPLEMENTATION-GUIDE.md)
- [Integration Guide](./INTEGRATION-GUIDE.md)
- [Development Roadmap](./DEVELOPMENT-ROADMAP.md)

### **External APIs**
- [QuickBooks API Documentation](https://developer.intuit.com/app/developer/qbo/docs/api/accounting)
- [Square API Documentation](https://developer.squareup.com/docs/)
- [Plaid API Documentation](https://plaid.com/docs/)
- [Gmail API Documentation](https://developers.google.com/gmail/api)

---

## 🆘 **Troubleshooting**

### **Common Issues**

**Build Errors:**
```bash
# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install

# Rebuild TypeScript
npm run build:clean
npm run build
```

**MCP Server Connection Issues:**
```bash
# Check MCP server status
npm run mcp:status

# Restart MCP servers
npm run mcp:restart

# Test MCP server manually
npm run mcp:test
```

**Test Failures:**
```bash
# Clear Jest cache
npm test -- --clearCache

# Run tests with verbose output
npm test -- --verbose

# Run specific failing test
npm test -- --testNamePattern="specific test name"
```

**Environment Issues:**
```bash
# Verify environment variables
npm run env:check

# Reset environment
cp .env.example .env
# Edit .env with correct values
```

### **Getting Help**
- **Documentation:** Check [docs/cpa/](../) directory
- **Issues:** Create GitHub issue with bug template
- **Discussions:** Use GitHub Discussions for questions
- **Code Review:** Request review on pull requests

---

## 🚀 **Next Steps**

Once your development environment is set up:

1. **Explore the Codebase**
   - Read through existing packages/cli and packages/core
   - Understand MCP integration patterns
   - Review CPA documentation

2. **Run Example Workflows**
   - Try the client switching command
   - Test document processing pipeline
   - Experiment with MCP integrations

3. **Start Contributing**
   - Pick up a task from the development roadmap
   - Write tests first (TDD approach)
   - Submit pull requests for review

4. **Build New Features**
   - Follow the implementation guide
   - Use established patterns
   - Maintain compatibility with upstream

Happy coding! 🎉