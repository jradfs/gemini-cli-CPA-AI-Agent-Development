# 🏗️ CPA AI Agent Implementation Guide

**Project:** Gemini CLI Enhanced for CPA Workflows  
**Version:** 1.0  
**Created:** 2024-12-27  
**Status:** Implementation Ready

---

## 🎯 **Implementation Overview**

This guide provides a step-by-step implementation plan for building the CPA AI Agent as a non-invasive extension to the Gemini CLI. The approach preserves full upstream compatibility while adding specialized CPA workflows, client management, and accounting integrations.

### **Key Principles**
- **🔌 Non-invasive Extension:** Zero modifications to core Gemini CLI packages
- **📦 Modular Architecture:** Independent CPA package with clean interfaces
- **🔒 Security First:** Enterprise-grade security for financial data
- **⚡ Performance Optimized:** <2 second response times for all operations
- **🧪 Test-Driven:** Comprehensive testing for financial accuracy

---

## 📦 **Package Structure Implementation**

### **Complete Directory Structure**
```
packages/cpa/                              # NEW: CPA-specific functionality
├── src/
│   ├── index.ts                          # Main package entry point
│   ├── commands/                         # CPA slash commands
│   │   ├── client-command.ts             # /client [name] - context switching
│   │   ├── morning-command.ts            # /morning - daily briefing
│   │   ├── close-command.ts              # /close [month] - monthly closing
│   │   ├── compliance-command.ts         # /compliance - deadline checks
│   │   └── index.ts                      # Commands barrel export
│   ├── workflows/                        # Automation engines
│   │   ├── morning-briefing.ts           # Daily briefing generation
│   │   ├── monthly-closing.ts            # Automated closing procedures
│   │   ├── document-processor.ts         # Receipt/invoice OCR processing
│   │   ├── compliance-monitor.ts         # Deadline monitoring system
│   │   └── index.ts                      # Workflows barrel export
│   ├── integrations/                     # MCP server wrappers
│   │   ├── mcp-manager.ts                # CPA MCP server manager
│   │   ├── quickbooks-mcp.ts             # QuickBooks MCP integration
│   │   ├── square-mcp.ts                 # Square payments MCP integration
│   │   ├── gmail-mcp.ts                  # Gmail communication MCP
│   │   ├── banking-mcp.ts                # Bank feeds MCP integration
│   │   └── index.ts                      # Integrations barrel export
│   ├── context/                          # Client context management
│   │   ├── client-manager.ts             # Client profile management
│   │   ├── session-context.ts            # Session state persistence
│   │   ├── context-switcher.ts           # Smart context switching logic
│   │   └── index.ts                      # Context barrel export
│   ├── ui/                              # CPA-specific UI components
│   │   ├── components/                   # React components
│   │   │   ├── ClientSummary.tsx         # Client overview display
│   │   │   ├── TaskPriority.tsx          # Priority task display
│   │   │   ├── ComplianceAlert.tsx       # Compliance alerts
│   │   │   ├── DocumentViewer.tsx        # Document processing UI
│   │   │   └── index.ts                  # Components barrel export
│   │   ├── themes/                       # CPA-specific themes
│   │   │   ├── cpa-professional.ts       # Professional color scheme
│   │   │   ├── cpa-minimal.ts            # Minimal interface
│   │   │   └── index.ts                  # Themes barrel export
│   │   ├── hooks/                        # CPA-specific React hooks
│   │   │   ├── useClientContext.ts       # Client context hook
│   │   │   ├── useWorkflowState.ts       # Workflow state management
│   │   │   ├── useComplianceCheck.ts     # Compliance monitoring
│   │   │   └── index.ts                  # Hooks barrel export
│   │   └── index.ts                      # UI barrel export
│   ├── data/                            # Data models and persistence
│   │   ├── models/                       # TypeScript data models
│   │   │   ├── client.ts                 # Client profile model
│   │   │   ├── transaction.ts            # Transaction model
│   │   │   ├── document.ts               # Document model
│   │   │   ├── task.ts                   # Task model
│   │   │   └── index.ts                  # Models barrel export
│   │   ├── repositories/                 # Data access layer
│   │   │   ├── client-repository.ts      # Client data access
│   │   │   ├── transaction-repository.ts # Transaction data access
│   │   │   ├── document-repository.ts    # Document data access
│   │   │   ├── task-repository.ts        # Task data access
│   │   │   └── index.ts                  # Repositories barrel export
│   │   ├── storage/                      # Data persistence layer
│   │   │   ├── client-storage.ts         # Client data storage
│   │   │   ├── document-storage.ts       # Document file storage
│   │   │   ├── session-storage.ts        # Session state storage
│   │   │   └── index.ts                  # Storage barrel export
│   │   ├── migrations/                   # Database migrations
│   │   │   ├── 001-initial-schema.sql    # Initial database schema
│   │   │   ├── 002-add-compliance.sql    # Compliance features
│   │   │   └── migration-runner.ts       # Migration execution
│   │   └── index.ts                      # Data barrel export
│   ├── utils/                           # CPA utility functions
│   │   ├── date-utils.ts                 # Tax year and deadline utils
│   │   ├── currency-utils.ts             # Currency formatting
│   │   ├── tax-utils.ts                  # Tax calculation helpers
│   │   ├── validation.ts                 # Input validation
│   │   ├── ai-helpers.ts                 # AI prompt utilities
│   │   └── index.ts                      # Utils barrel export
│   ├── types/                           # TypeScript type definitions
│   │   ├── cpa-types.ts                  # CPA-specific types
│   │   ├── integration-types.ts          # Integration interfaces
│   │   ├── workflow-types.ts             # Workflow type definitions
│   │   └── index.ts                      # Types barrel export
│   ├── config/                          # CPA configuration
│   │   ├── cpa-config.ts                 # CPA configuration interface
│   │   ├── mcp-servers.ts                # MCP server configurations
│   │   └── index.ts                      # Config barrel export
│   └── security/                        # Security utilities
│       ├── encryption.ts                 # Data encryption
│       ├── access-control.ts             # Permission management
│       ├── audit-logger.ts               # Audit trail logging
│       └── index.ts                      # Security barrel export
├── tests/                               # Comprehensive test suite
│   ├── unit/                            # Unit tests
│   │   ├── commands/                     # Command tests
│   │   ├── workflows/                    # Workflow tests
│   │   ├── integrations/                 # Integration tests
│   │   └── utils/                        # Utility tests
│   ├── integration/                     # Integration tests
│   │   ├── mcp-servers/                  # MCP server tests
│   │   ├── database/                     # Database tests
│   │   └── api/                          # API integration tests
│   ├── e2e/                            # End-to-end tests
│   │   ├── workflows/                    # Complete workflow tests
│   │   ├── user-scenarios/               # User journey tests
│   │   └── automation/                   # Automation scenario tests
│   ├── fixtures/                        # Test data and fixtures
│   │   ├── clients/                      # Sample client data
│   │   ├── documents/                    # Sample documents
│   │   └── transactions/                 # Sample transactions
│   ├── mocks/                           # Mock implementations
│   │   ├── mcp-servers/                  # Mock MCP servers
│   │   ├── external-apis/                # Mock external APIs
│   │   └── storage/                      # Mock storage
│   └── setup/                           # Test setup utilities
├── docs/                                # CPA-specific documentation
│   ├── api/                             # API documentation
│   │   ├── commands.md                   # Command API reference
│   │   ├── workflows.md                  # Workflow API reference
│   │   └── integrations.md               # Integration API reference
│   ├── workflows/                       # Workflow guides
│   │   ├── daily-briefing.md             # Daily briefing workflow
│   │   ├── monthly-closing.md            # Monthly closing workflow
│   │   └── document-processing.md        # Document processing workflow
│   ├── integrations/                    # Integration guides
│   │   ├── quickbooks-setup.md           # QuickBooks setup guide
│   │   ├── square-setup.md               # Square setup guide
│   │   └── banking-setup.md              # Banking setup guide
│   └── development/                     # Development guides
│       ├── getting-started.md            # Developer getting started
│       ├── testing-guide.md              # Testing guidelines
│       └── contributing.md               # Contribution guidelines
├── examples/                            # Usage examples
│   ├── workflows/                       # Example automation workflows
│   │   ├── basic-client-setup.ts        # Basic client onboarding
│   │   ├── monthly-close-demo.ts        # Monthly closing demo
│   │   └── compliance-check-demo.ts     # Compliance monitoring demo
│   ├── integrations/                    # Integration examples
│   │   ├── quickbooks-demo.ts           # QuickBooks integration demo
│   │   ├── square-demo.ts               # Square integration demo
│   │   └── gmail-demo.ts                # Gmail integration demo
│   └── scenarios/                       # Real-world scenarios
│       ├── small-business.ts            # Small business workflow
│       ├── freelancer.ts                # Freelancer workflow
│       └── multi-entity.ts              # Multi-entity workflow
├── scripts/                            # Build and deployment scripts
│   ├── build.js                         # Package build script
│   ├── test.js                          # Test runner script
│   ├── setup-dev.js                     # Development setup
│   └── deploy.js                        # Deployment script
├── mcp-servers/                        # Custom MCP server implementations
│   ├── quickbooks/                      # QuickBooks MCP server
│   │   ├── src/                         # Server source code
│   │   ├── package.json                 # Server package config
│   │   └── README.md                    # Server documentation
│   ├── square/                          # Square MCP server
│   ├── gmail/                           # Gmail MCP server
│   └── banking/                         # Banking MCP server
├── package.json                        # CPA package configuration
├── tsconfig.json                        # TypeScript configuration
├── jest.config.js                       # Jest test configuration
├── eslint.config.js                     # ESLint configuration
├── prettier.config.js                   # Prettier configuration
├── .gitignore                           # Git ignore rules
├── README.md                            # Package documentation
└── CHANGELOG.md                         # Version history
```

---

## 🔧 **Core Implementation Components**

### **1. Main Package Entry Point**

```typescript
// packages/cpa/src/index.ts
import { Config } from '@google/gemini-cli-core'
import { CPACommands } from './commands'
import { CPAMCPManager } from './integrations'
import { ClientManager } from './context'
import { CPAConfig, loadCPAConfig } from './config'

export class CPAExtension {
  private config: CPAConfig
  private mcpManager: CPAMCPManager
  private clientManager: ClientManager
  private initialized = false

  constructor() {
    this.config = loadCPAConfig()
    this.mcpManager = new CPAMCPManager(this.config)
    this.clientManager = new ClientManager(this.config)
  }

  /**
   * Register CPA extension with Gemini CLI
   * Called from main CLI initialization
   */
  static async register(geminiConfig: Config): Promise<CPAExtension> {
    const cpaExtension = new CPAExtension()
    await cpaExtension.initialize(geminiConfig)
    return cpaExtension
  }

  /**
   * Initialize CPA extension components
   */
  private async initialize(geminiConfig: Config): Promise<void> {
    if (this.initialized) return

    try {
      // 1. Register CPA commands with slash command processor
      await this.registerCommands(geminiConfig)
      
      // 2. Initialize MCP server connections
      await this.mcpManager.initialize(geminiConfig)
      
      // 3. Set up client context management
      await this.clientManager.initialize()
      
      // 4. Initialize CPA-specific UI themes
      await this.registerThemes(geminiConfig)
      
      this.initialized = true
      console.log('✅ CPA AI Agent extension loaded successfully')
    } catch (error) {
      console.error('❌ Failed to initialize CPA extension:', error)
      throw error
    }
  }

  /**
   * Register CPA slash commands
   */
  private async registerCommands(geminiConfig: Config): Promise<void> {
    const commands = CPACommands.getAllCommands({
      mcpManager: this.mcpManager,
      clientManager: this.clientManager,
      config: this.config
    })

    // Register each command with existing command system
    commands.forEach(command => {
      geminiConfig.registerSlashCommand(command)
    })
  }

  /**
   * Register CPA-specific themes
   */
  private async registerThemes(geminiConfig: Config): Promise<void> {
    // Register professional and minimal themes
    // Implementation depends on theme system structure
  }

  /**
   * Get current client context
   */
  getCurrentClient(): Client | null {
    return this.clientManager.getCurrentClient()
  }

  /**
   * Get CPA configuration
   */
  getConfig(): CPAConfig {
    return this.config
  }
}

// Export types and utilities for external use
export * from './types'
export * from './commands'
export * from './workflows'
export * from './integrations'
export * from './context'
export * from './utils'
```

### **2. CPA Commands Implementation**

```typescript
// packages/cpa/src/commands/client-command.ts
import { SlashCommand, SlashCommandActionReturn } from '@google/gemini-cli-cli'
import { ClientManager } from '../context'
import { Client } from '../types'

export class ClientCommand implements SlashCommand {
  name = 'client'
  altName = 'c'
  description = 'Switch to client context for focused CPA workflows'

  constructor(
    private clientManager: ClientManager
  ) {}

  async completion(): Promise<string[]> {
    // Return list of active client names for tab completion
    const clients = await this.clientManager.getActiveClients()
    return clients.map(client => client.name)
  }

  async action(
    _mainCommand: string,
    _subCommand?: string,
    args?: string
  ): Promise<SlashCommandActionReturn> {
    const clientName = args?.trim()

    // Show help if no client name provided
    if (!clientName) {
      const activeClients = await this.clientManager.getActiveClients()
      return {
        message: this.formatClientHelp(activeClients)
      }
    }

    try {
      // Switch to client context
      const client = await this.clientManager.switchToClient(clientName)
      
      // Generate client summary
      const summary = await this.generateClientSummary(client)
      
      return {
        message: summary
      }
    } catch (error) {
      return {
        message: `❌ Error switching to client "${clientName}": ${error.message}\n\n` +
                 `💡 Use \`/client\` to see available clients.`
      }
    }
  }

  private formatClientHelp(clients: Client[]): string {
    return `🏢 **Client Context Switching**\n\n` +
           `**Usage:** \`/client <client-name>\`\n\n` +
           `**Active Clients:**\n` +
           clients.map(client => 
             `• **${client.name}** (${client.type}) - ${client.status}`
           ).join('\n') +
           `\n\n💡 **Tip:** Use tab completion to autocomplete client names.`
  }

  private async generateClientSummary(client: Client): Promise<string> {
    const recentActivity = await this.clientManager.getRecentActivity(client)
    const pendingTasks = await this.clientManager.getPendingTasks(client)
    const upcomingDeadlines = await this.clientManager.getUpcomingDeadlines(client)

    return `🎯 **Switched to Client: ${client.name}**\n\n` +
           `📊 **Quick Summary:**\n` +
           `• **Type:** ${client.type}\n` +
           `• **Tax Year:** ${client.taxYear}\n` +
           `• **Status:** ${client.status}\n` +
           `• **Last Activity:** ${recentActivity.lastActivityDate}\n\n` +
           `📋 **Current State:**\n` +
           `• **Pending Tasks:** ${pendingTasks.length}\n` +
           `• **Upcoming Deadlines:** ${upcomingDeadlines.length}\n` +
           `• **Unprocessed Documents:** ${recentActivity.unprocessedDocuments}\n\n` +
           `⚡ **Quick Actions:**\n` +
           `• \`/morning\` - Generate daily briefing\n` +
           `• \`/close\` - Start monthly closing\n` +
           `• \`/compliance\` - Check compliance status\n\n` +
           `🔗 **QuickBooks:** ${client.quickbooksId ? '✅ Connected' : '❌ Not connected'}`
  }
}
```

### **3. MCP Integration Manager**

```typescript
// packages/cpa/src/integrations/mcp-manager.ts
import { Config, MCPServerConfig, discoverMcpTools } from '@google/gemini-cli-core'
import { QuickBooksMCPIntegration } from './quickbooks-mcp'
import { SquareMCPIntegration } from './square-mcp'
import { GmailMCPIntegration } from './gmail-mcp'
import { BankingMCPIntegration } from './banking-mcp'
import { CPAConfig } from '../config'

export class CPAMCPManager {
  private quickbooks: QuickBooksMCPIntegration | null = null
  private square: SquareMCPIntegration | null = null
  private gmail: GmailMCPIntegration | null = null
  private banking: BankingMCPIntegration | null = null
  private initialized = false

  constructor(private cpaConfig: CPAConfig) {}

  async initialize(geminiConfig: Config): Promise<void> {
    if (this.initialized) return

    try {
      // Define CPA MCP servers
      const cpaServers = this.defineCPAServers()

      // Register with Gemini CLI's MCP discovery system
      await discoverMcpTools(cpaServers, undefined, geminiConfig.getToolRegistry())

      // Initialize integration wrappers
      await this.initializeIntegrations(geminiConfig)

      this.initialized = true
      console.log('✅ CPA MCP servers initialized successfully')
    } catch (error) {
      console.error('❌ Failed to initialize CPA MCP servers:', error)
      throw error
    }
  }

  private defineCPAServers(): Record<string, MCPServerConfig> {
    const serverPath = this.getServerPath()
    
    return {
      'cpa-quickbooks': new MCPServerConfig(
        'node',
        [`${serverPath}/quickbooks/index.js`],
        {
          QUICKBOOKS_CLIENT_ID: process.env.QUICKBOOKS_CLIENT_ID,
          QUICKBOOKS_CLIENT_SECRET: process.env.QUICKBOOKS_CLIENT_SECRET,
          QUICKBOOKS_ENVIRONMENT: process.env.QUICKBOOKS_ENVIRONMENT || 'production'
        },
        undefined, // cwd
        undefined, // url
        undefined, // httpUrl
        undefined, // tcp
        30000, // timeout
        true, // trust
        'QuickBooks Online integration for CPA workflows'
      ),
      'cpa-square': new MCPServerConfig(
        'node',
        [`${serverPath}/square/index.js`],
        {
          SQUARE_APPLICATION_ID: process.env.SQUARE_APPLICATION_ID,
          SQUARE_ACCESS_TOKEN: process.env.SQUARE_ACCESS_TOKEN,
          SQUARE_ENVIRONMENT: process.env.SQUARE_ENVIRONMENT || 'production'
        },
        undefined, undefined, undefined, undefined,
        30000, true,
        'Square payment processing integration'
      ),
      'cpa-gmail': new MCPServerConfig(
        'node',
        [`${serverPath}/gmail/index.js`],
        {
          GMAIL_CLIENT_ID: process.env.GMAIL_CLIENT_ID,
          GMAIL_CLIENT_SECRET: process.env.GMAIL_CLIENT_SECRET,
          GMAIL_REFRESH_TOKEN: process.env.GMAIL_REFRESH_TOKEN
        },
        undefined, undefined, undefined, undefined,
        30000, true,
        'Gmail client communication integration'
      ),
      'cpa-banking': new MCPServerConfig(
        'node',
        [`${serverPath}/banking/index.js`],
        {
          PLAID_CLIENT_ID: process.env.PLAID_CLIENT_ID,
          PLAID_SECRET: process.env.PLAID_SECRET,
          PLAID_ENVIRONMENT: process.env.PLAID_ENVIRONMENT || 'production'
        },
        undefined, undefined, undefined, undefined,
        30000, true,
        'Banking and transaction feed integration'
      )
    }
  }

  private async initializeIntegrations(geminiConfig: Config): Promise<void> {
    const toolRegistry = geminiConfig.getToolRegistry()

    // Initialize QuickBooks integration
    if (this.cpaConfig.integrations.quickbooks.enabled) {
      this.quickbooks = new QuickBooksMCPIntegration(toolRegistry)
      await this.quickbooks.initialize()
    }

    // Initialize Square integration
    if (this.cpaConfig.integrations.square.enabled) {
      this.square = new SquareMCPIntegration(toolRegistry)
      await this.square.initialize()
    }

    // Initialize Gmail integration
    if (this.cpaConfig.integrations.gmail.enabled) {
      this.gmail = new GmailMCPIntegration(toolRegistry)
      await this.gmail.initialize()
    }

    // Initialize Banking integration
    if (this.cpaConfig.integrations.banking.enabled) {
      this.banking = new BankingMCPIntegration(toolRegistry)
      await this.banking.initialize()
    }
  }

  private getServerPath(): string {
    // Get path to MCP server implementations
    return `${__dirname}/../../mcp-servers`
  }

  // Getter methods for integrations
  getQuickBooks(): QuickBooksMCPIntegration | null {
    return this.quickbooks
  }

  getSquare(): SquareMCPIntegration | null {
    return this.square
  }

  getGmail(): GmailMCPIntegration | null {
    return this.gmail
  }

  getBanking(): BankingMCPIntegration | null {
    return this.banking
  }

  // Health check methods
  async getIntegrationStatus(): Promise<Record<string, boolean>> {
    return {
      quickbooks: this.quickbooks?.isConnected() ?? false,
      square: this.square?.isConnected() ?? false,
      gmail: this.gmail?.isConnected() ?? false,
      banking: this.banking?.isConnected() ?? false
    }
  }
}
```

---

## 🚀 **Implementation Steps**

### **Phase 1: Foundation Setup (Week 1)**

```bash
# 1. Create package structure
mkdir -p packages/cpa/src/{commands,workflows,integrations,context,ui,data,utils,types,config,security}
mkdir -p packages/cpa/{tests,docs,examples,scripts,mcp-servers}

# 2. Initialize package
cd packages/cpa
npm init -y

# 3. Configure TypeScript
cat > tsconfig.json << 'EOF'
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src",
    "baseUrl": "./src",
    "paths": {
      "@cpa/*": ["./*"],
      "@core/*": ["../core/src/*"],
      "@cli/*": ["../cli/src/*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["tests/**/*", "dist/**/*"]
}
EOF

# 4. Configure package.json
npm pkg set name="@google/gemini-cli-cpa"
npm pkg set version="0.1.0"
npm pkg set main="dist/index.js"
npm pkg set types="dist/index.d.ts"
npm pkg set scripts.build="tsc"
npm pkg set scripts.test="jest"
npm pkg set scripts.lint="eslint src/**/*.ts"
npm pkg set scripts.dev="tsc --watch"

# 5. Install dependencies
npm install --save @google/gemini-cli-core @google/gemini-cli-cli
npm install --save-dev typescript jest @types/jest eslint prettier
```

### **Phase 2: Core Implementation (Week 2)**

```bash
# 1. Implement main entry point
# Create packages/cpa/src/index.ts (as shown above)

# 2. Implement basic commands
# Create packages/cpa/src/commands/ structure

# 3. Implement context management
# Create packages/cpa/src/context/ structure

# 4. Set up basic testing
# Create packages/cpa/tests/ structure

# 5. Integration with main CLI
# Modify packages/cli/src/config/config.ts to load CPA extension
```

### **Phase 3: MCP Integration (Week 3)**

```bash
# 1. Implement MCP server manager
# Create packages/cpa/src/integrations/mcp-manager.ts

# 2. Create custom MCP servers
# Implement packages/cpa/mcp-servers/ structure

# 3. Test MCP connections
# Create integration tests

# 4. Document MCP patterns
# Update documentation
```

---

## 📚 **Development Guidelines**

### **Code Organization Standards**

```typescript
// Barrel export pattern for clean imports
// packages/cpa/src/commands/index.ts
export { ClientCommand } from './client-command'
export { MorningCommand } from './morning-command'
export { CloseCommand } from './close-command'
export { ComplianceCommand } from './compliance-command'

// Centralized command factory
export class CPACommands {
  static getAllCommands(dependencies: CPADependencies): SlashCommand[] {
    return [
      new ClientCommand(dependencies.clientManager),
      new MorningCommand(dependencies.mcpManager, dependencies.clientManager),
      new CloseCommand(dependencies.mcpManager, dependencies.clientManager),
      new ComplianceCommand(dependencies.clientManager)
    ]
  }
}
```

### **Testing Standards**

```typescript
// packages/cpa/tests/unit/commands/client-command.test.ts
describe('ClientCommand', () => {
  let clientCommand: ClientCommand
  let mockClientManager: jest.Mocked<ClientManager>

  beforeEach(() => {
    mockClientManager = createMockClientManager()
    clientCommand = new ClientCommand(mockClientManager)
  })

  describe('action', () => {
    it('should switch to client when valid name provided', async () => {
      const mockClient = createMockClient('Test Client')
      mockClientManager.switchToClient.mockResolvedValue(mockClient)

      const result = await clientCommand.action('client', undefined, 'Test Client')

      expect(result.message).toContain('Switched to Client: Test Client')
      expect(mockClientManager.switchToClient).toHaveBeenCalledWith('Test Client')
    })

    it('should show help when no client name provided', async () => {
      const mockClients = [createMockClient('Client 1'), createMockClient('Client 2')]
      mockClientManager.getActiveClients.mockResolvedValue(mockClients)

      const result = await clientCommand.action('client', undefined, '')

      expect(result.message).toContain('Active Clients:')
      expect(result.message).toContain('Client 1')
      expect(result.message).toContain('Client 2')
    })
  })
})
```

### **Configuration Management**

```typescript
// packages/cpa/src/config/cpa-config.ts
export interface CPAConfig {
  version: string
  environment: 'development' | 'production' | 'test'
  
  integrations: {
    quickbooks: {
      enabled: boolean
      clientId?: string
      environment: 'sandbox' | 'production'
    }
    square: {
      enabled: boolean
      applicationId?: string
      environment: 'sandbox' | 'production'
    }
    gmail: {
      enabled: boolean
      clientId?: string
    }
    banking: {
      enabled: boolean
      provider: 'plaid' | 'yodlee'
      environment: 'sandbox' | 'production'
    }
  }
  
  storage: {
    provider: 'local' | 'aws' | 'gcp' | 'azure'
    config: Record<string, unknown>
  }
  
  security: {
    encryptionEnabled: boolean
    auditLoggingEnabled: boolean
  }
  
  ui: {
    defaultTheme: 'professional' | 'minimal'
    showAdvancedFeatures: boolean
  }
}

export function loadCPAConfig(): CPAConfig {
  return {
    version: '1.0.0',
    environment: (process.env.NODE_ENV as any) || 'development',
    
    integrations: {
      quickbooks: {
        enabled: !!process.env.QUICKBOOKS_CLIENT_ID,
        clientId: process.env.QUICKBOOKS_CLIENT_ID,
        environment: (process.env.QUICKBOOKS_ENVIRONMENT as any) || 'production'
      },
      square: {
        enabled: !!process.env.SQUARE_APPLICATION_ID,
        applicationId: process.env.SQUARE_APPLICATION_ID,
        environment: (process.env.SQUARE_ENVIRONMENT as any) || 'production'
      },
      gmail: {
        enabled: !!process.env.GMAIL_CLIENT_ID,
        clientId: process.env.GMAIL_CLIENT_ID
      },
      banking: {
        enabled: !!process.env.PLAID_CLIENT_ID,
        provider: 'plaid',
        environment: (process.env.PLAID_ENVIRONMENT as any) || 'production'
      }
    },
    
    storage: {
      provider: (process.env.CPA_STORAGE_PROVIDER as any) || 'local',
      config: {}
    },
    
    security: {
      encryptionEnabled: process.env.CPA_ENCRYPTION_ENABLED === 'true',
      auditLoggingEnabled: process.env.CPA_AUDIT_LOGGING === 'true'
    },
    
    ui: {
      defaultTheme: (process.env.CPA_DEFAULT_THEME as any) || 'professional',
      showAdvancedFeatures: process.env.CPA_ADVANCED_FEATURES === 'true'
    }
  }
}
```

---

## 🔒 **Security Implementation**

### **Data Encryption**

```typescript
// packages/cpa/src/security/encryption.ts
import crypto from 'crypto'

export class CPAEncryption {
  private static readonly ALGORITHM = 'aes-256-gcm'
  private readonly key: Buffer

  constructor(encryptionKey?: string) {
    if (!encryptionKey) {
      throw new Error('Encryption key is required for CPA data protection')
    }
    this.key = crypto.scryptSync(encryptionKey, 'salt', 32)
  }

  encrypt(data: string): { encrypted: string; iv: string; authTag: string } {
    const iv = crypto.randomBytes(16)
    const cipher = crypto.createCipher(CPAEncryption.ALGORITHM, this.key)
    cipher.setAAD(Buffer.from('cpa-agent'))
    
    let encrypted = cipher.update(data, 'utf8', 'hex')
    encrypted += cipher.final('hex')
    
    const authTag = cipher.getAuthTag()
    
    return {
      encrypted,
      iv: iv.toString('hex'),
      authTag: authTag.toString('hex')
    }
  }

  decrypt(encryptedData: { encrypted: string; iv: string; authTag: string }): string {
    const decipher = crypto.createDecipher(CPAEncryption.ALGORITHM, this.key)
    decipher.setAAD(Buffer.from('cpa-agent'))
    decipher.setAuthTag(Buffer.from(encryptedData.authTag, 'hex'))
    
    let decrypted = decipher.update(encryptedData.encrypted, 'hex', 'utf8')
    decrypted += decipher.final('utf8')
    
    return decrypted
  }
}
```

### **Access Control**

```typescript
// packages/cpa/src/security/access-control.ts
export class CPAAccessControl {
  private permissions = new Map<string, Set<string>>()

  constructor() {
    this.initializeDefaultPermissions()
  }

  private initializeDefaultPermissions(): void {
    // CPA role permissions
    this.permissions.set('cpa', new Set([
      'client:read', 'client:write', 'client:delete',
      'transaction:read', 'transaction:write',
      'document:read', 'document:write', 'document:delete',
      'workflow:execute', 'compliance:check'
    ]))

    // Staff role permissions (limited)
    this.permissions.set('staff', new Set([
      'client:read', 'transaction:read',
      'document:read', 'document:write',
      'workflow:execute'
    ]))

    // Read-only role permissions
    this.permissions.set('readonly', new Set([
      'client:read', 'transaction:read', 'document:read'
    ]))
  }

  hasPermission(role: string, permission: string): boolean {
    const rolePermissions = this.permissions.get(role)
    return rolePermissions?.has(permission) ?? false
  }

  checkPermission(role: string, permission: string): void {
    if (!this.hasPermission(role, permission)) {
      throw new Error(`Access denied: ${role} does not have ${permission} permission`)
    }
  }
}
```

---

## 📊 **Quality Assurance**

### **Testing Strategy**

```typescript
// packages/cpa/tests/setup/test-setup.ts
export const createTestEnvironment = async (): Promise<TestEnvironment> => {
  // Set up test database
  const testDb = await setupTestDatabase()
  
  // Create mock MCP servers
  const mockMCPServers = createMockMCPServers()
  
  // Initialize test configuration
  const testConfig = createTestConfig()
  
  return {
    database: testDb,
    mcpServers: mockMCPServers,
    config: testConfig,
    cleanup: async () => {
      await testDb.cleanup()
      await mockMCPServers.cleanup()
    }
  }
}

// Integration test helper
export const createIntegrationTest = (
  name: string, 
  testFn: (env: TestEnvironment) => Promise<void>
) => {
  return async () => {
    const env = await createTestEnvironment()
    try {
      await testFn(env)
    } finally {
      await env.cleanup()
    }
  }
}
```

### **Performance Monitoring**

```typescript
// packages/cpa/src/utils/performance.ts
export class CPAPerformanceMonitor {
  private static readonly MAX_RESPONSE_TIME = 2000 // 2 seconds

  static async measureAsync<T>(
    operationName: string,
    operation: () => Promise<T>
  ): Promise<T> {
    const startTime = Date.now()
    
    try {
      const result = await operation()
      const duration = Date.now() - startTime
      
      if (duration > CPAPerformanceMonitor.MAX_RESPONSE_TIME) {
        console.warn(`⚠️ Slow operation: ${operationName} took ${duration}ms`)
      }
      
      // Log to telemetry if available
      this.logPerformanceMetric(operationName, duration, 'success')
      
      return result
    } catch (error) {
      const duration = Date.now() - startTime
      this.logPerformanceMetric(operationName, duration, 'error')
      throw error
    }
  }

  private static logPerformanceMetric(
    operation: string, 
    duration: number, 
    status: 'success' | 'error'
  ): void {
    // Integration with existing Gemini CLI telemetry system
    // TODO: Implement telemetry logging
  }
}
```

---

This comprehensive implementation guide provides everything needed to build the CPA AI Agent extension while maintaining full compatibility with the upstream Gemini CLI. The architecture is designed for scalability, security, and maintainability, ensuring a production-ready foundation for CPA workflows.