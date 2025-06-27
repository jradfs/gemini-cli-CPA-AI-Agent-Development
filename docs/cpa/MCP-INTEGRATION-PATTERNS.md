# 🔌 MCP Integration Patterns for CPA AI Agent

**Project:** Gemini CLI Enhanced for CPA Workflows  
**Version:** 1.0  
**Created:** 2024-12-27  
**Focus:** Model Context Protocol Integration Patterns

---

## 🎯 **MCP Integration Overview**

The CPA AI Agent leverages the Model Context Protocol (MCP) to integrate with external accounting systems, payment processors, and business tools. This document outlines proven patterns for building robust, scalable MCP integrations.

### **Key Benefits of MCP for CPA Workflows**
- **🔌 Unified Interface:** Consistent API across all integrations
- **🔒 Secure Connections:** Built-in authentication and encryption
- **⚡ Performance:** Optimized for real-time financial operations
- **🧪 Testable:** Easy mocking and testing of external services
- **📊 Observable:** Rich logging and monitoring capabilities

---

## 🏗️ **MCP Architecture for CPA**

### **High-Level Architecture**
```
┌─────────────────────────────────────────────────────────────────┐
│                    CPA AI Agent Core                            │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ Command Layer   │  │ Workflow Engine │  │ Context Manager │ │
│  │ (/client, etc)  │  │ (Automation)    │  │ (Client State)  │ │
│  └─────────┬───────┘  └─────────┬───────┘  └─────────┬───────┘ │
├───────────┼─────────────────────┼─────────────────────┼─────────┤
│           │                     │                     │         │
│  ┌────────▼────────┐  ┌─────────▼─────────┐  ┌────────▼───────┐ │
│  │  MCP Manager    │  │ Integration Layer │  │ Workflow State │ │
│  │  (Connections)  │  │   (Wrappers)      │  │  (Persistence) │ │
│  └────────┬────────┘  └─────────┬─────────┘  └────────┬───────┘ │
├───────────┼─────────────────────┼─────────────────────┼─────────┤
│           │                     │                     │         │
│  ┌────────▼────────┐  ┌─────────▼─────────┐  ┌────────▼───────┐ │
│  │ MCP Client Pool │  │  Tool Registry    │  │ Error Handling │ │
│  │ (Connections)   │  │   (Discovery)     │  │ (Resilience)   │ │
│  └────────┬────────┘  └─────────┬─────────┘  └────────┬───────┘ │
├───────────┼─────────────────────┼─────────────────────┼─────────┤
│                    MCP Transport Layer                          │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   QuickBooks    │  │     Square      │  │     Gmail       │ │
│  │   MCP Server    │  │   MCP Server    │  │   MCP Server    │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │    Banking      │  │   Document      │  │   Compliance    │ │
│  │   MCP Server    │  │   MCP Server    │  │   MCP Server    │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔧 **Core MCP Patterns**

### **1. MCP Client Manager Pattern**

```typescript
// packages/cpa/src/integrations/mcp-manager.ts
export class CPAMCPManager {
  private connections = new Map<string, MCPConnection>()
  private healthMonitor = new MCPHealthMonitor()
  private retryHandler = new MCPRetryHandler()

  async initialize(config: Config): Promise<void> {
    const serverConfigs = this.buildMCPServerConfigs()
    
    // Initialize connections with health monitoring
    for (const [name, serverConfig] of Object.entries(serverConfigs)) {
      try {
        const connection = await this.createConnection(name, serverConfig)
        this.connections.set(name, connection)
        this.healthMonitor.startMonitoring(name, connection)
      } catch (error) {
        console.error(`Failed to initialize MCP server: ${name}`, error)
        // Continue with other servers
      }
    }
  }

  private async createConnection(
    name: string, 
    config: MCPServerConfig
  ): Promise<MCPConnection> {
    return new MCPConnection({
      name,
      config,
      retryHandler: this.retryHandler,
      timeout: 30000,
      healthCheck: true
    })
  }

  getConnection(serverName: string): MCPConnection | null {
    return this.connections.get(serverName) || null
  }

  async getHealthStatus(): Promise<Record<string, MCPHealthStatus>> {
    const status: Record<string, MCPHealthStatus> = {}
    
    for (const [name, connection] of this.connections) {
      status[name] = await this.healthMonitor.checkHealth(connection)
    }
    
    return status
  }
}
```

### **2. Integration Wrapper Pattern**

```typescript
// packages/cpa/src/integrations/quickbooks-mcp.ts
export class QuickBooksMCPIntegration {
  private mcpConnection: MCPConnection
  private cache = new LRUCache<string, any>(100)
  private rateLimiter = new RateLimiter(10, 1000) // 10 requests per second

  constructor(mcpManager: CPAMCPManager) {
    this.mcpConnection = mcpManager.getConnection('cpa-quickbooks')
    if (!this.mcpConnection) {
      throw new Error('QuickBooks MCP server not available')
    }
  }

  async createJournalEntry(
    entry: JournalEntryRequest
  ): Promise<JournalEntryResponse> {
    await this.rateLimiter.acquire()
    
    try {
      const response = await this.mcpConnection.callTool('create_journal_entry', {
        date: entry.date,
        lines: entry.lines.map(line => ({
          account_id: line.accountId,
          debit_amount: line.debitAmount,
          credit_amount: line.creditAmount,
          description: line.description
        })),
        memo: entry.memo,
        client_id: entry.clientId
      })

      return this.transformResponse(response)
    } catch (error) {
      throw new QuickBooksIntegrationError(
        `Failed to create journal entry: ${error.message}`,
        error
      )
    }
  }

  async getChartOfAccounts(clientId: string): Promise<Account[]> {
    const cacheKey = `chart_of_accounts:${clientId}`
    
    // Check cache first
    if (this.cache.has(cacheKey)) {
      return this.cache.get(cacheKey)!
    }

    await this.rateLimiter.acquire()
    
    try {
      const response = await this.mcpConnection.callTool('get_chart_of_accounts', {
        client_id: clientId
      })

      const accounts = this.transformAccountsResponse(response)
      
      // Cache for 5 minutes
      this.cache.set(cacheKey, accounts, 5 * 60 * 1000)
      
      return accounts
    } catch (error) {
      throw new QuickBooksIntegrationError(
        `Failed to get chart of accounts: ${error.message}`,
        error
      )
    }
  }

  private transformResponse(response: any): JournalEntryResponse {
    return {
      id: response.Id,
      date: new Date(response.TxnDate),
      status: response.PrivateNote ? 'draft' : 'posted',
      amount: response.TotalAmt,
      lines: response.Line.map((line: any) => ({
        id: line.Id,
        accountId: line.JournalEntryLineDetail?.AccountRef?.value,
        accountName: line.JournalEntryLineDetail?.AccountRef?.name,
        debitAmount: line.JournalEntryLineDetail?.PostingType === 'Debit' 
          ? line.Amount : 0,
        creditAmount: line.JournalEntryLineDetail?.PostingType === 'Credit' 
          ? line.Amount : 0,
        description: line.Description
      }))
    }
  }
}
```

### **3. Error Handling and Resilience Pattern**

```typescript
// packages/cpa/src/integrations/mcp-error-handler.ts
export class MCPErrorHandler {
  private static readonly RETRY_DELAYS = [1000, 2000, 4000, 8000] // Exponential backoff
  private static readonly RETRIABLE_ERRORS = [
    'NETWORK_ERROR',
    'TIMEOUT_ERROR', 
    'RATE_LIMIT_ERROR',
    'SERVER_UNAVAILABLE'
  ]

  static async executeWithRetry<T>(
    operation: () => Promise<T>,
    context: string
  ): Promise<T> {
    let lastError: Error
    
    for (let attempt = 0; attempt < this.RETRY_DELAYS.length; attempt++) {
      try {
        return await operation()
      } catch (error) {
        lastError = error as Error
        
        if (!this.isRetriableError(error)) {
          throw error
        }
        
        if (attempt === this.RETRY_DELAYS.length - 1) {
          break // Last attempt, don't delay
        }
        
        const delay = this.RETRY_DELAYS[attempt]
        console.warn(
          `MCP operation failed (attempt ${attempt + 1}/${this.RETRY_DELAYS.length}): ${context}. ` +
          `Retrying in ${delay}ms...`
        )
        
        await this.sleep(delay)
      }
    }
    
    throw new MCPRetryExhaustedError(
      `Failed after ${this.RETRY_DELAYS.length} attempts: ${context}`,
      lastError
    )
  }

  private static isRetriableError(error: any): boolean {
    if (error.code && this.RETRIABLE_ERRORS.includes(error.code)) {
      return true
    }
    
    // Check for network errors
    if (error.message?.includes('ECONNREFUSED') || 
        error.message?.includes('ETIMEDOUT')) {
      return true
    }
    
    return false
  }

  private static sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms))
  }
}

// Usage in integration
export class QuickBooksMCPIntegration {
  async createJournalEntry(entry: JournalEntryRequest): Promise<JournalEntryResponse> {
    return MCPErrorHandler.executeWithRetry(
      async () => {
        return await this.mcpConnection.callTool('create_journal_entry', entry)
      },
      `QuickBooks.createJournalEntry for client ${entry.clientId}`
    )
  }
}
```

### **4. Health Monitoring Pattern**

```typescript
// packages/cpa/src/integrations/mcp-health-monitor.ts
export class MCPHealthMonitor {
  private healthStatus = new Map<string, MCPHealthStatus>()
  private monitoringIntervals = new Map<string, NodeJS.Timeout>()

  startMonitoring(serverName: string, connection: MCPConnection): void {
    // Initial health check
    this.checkHealth(connection).then(status => {
      this.healthStatus.set(serverName, status)
    })

    // Set up periodic health checks
    const interval = setInterval(async () => {
      try {
        const status = await this.checkHealth(connection)
        this.updateHealthStatus(serverName, status)
      } catch (error) {
        this.updateHealthStatus(serverName, {
          status: 'unhealthy',
          lastCheck: new Date(),
          error: error.message,
          responseTime: null
        })
      }
    }, 30000) // Check every 30 seconds

    this.monitoringIntervals.set(serverName, interval)
  }

  async checkHealth(connection: MCPConnection): Promise<MCPHealthStatus> {
    const startTime = Date.now()
    
    try {
      // Use a lightweight health check tool
      await connection.callTool('health_check', {})
      
      const responseTime = Date.now() - startTime
      
      return {
        status: 'healthy',
        lastCheck: new Date(),
        responseTime,
        error: null
      }
    } catch (error) {
      return {
        status: 'unhealthy',
        lastCheck: new Date(),
        responseTime: null,
        error: error.message
      }
    }
  }

  private updateHealthStatus(serverName: string, status: MCPHealthStatus): void {
    const previousStatus = this.healthStatus.get(serverName)
    this.healthStatus.set(serverName, status)

    // Log status changes
    if (previousStatus?.status !== status.status) {
      if (status.status === 'healthy') {
        console.log(`✅ MCP server ${serverName} is now healthy`)
      } else {
        console.error(`❌ MCP server ${serverName} is unhealthy: ${status.error}`)
      }
    }
  }

  getStatus(serverName: string): MCPHealthStatus | null {
    return this.healthStatus.get(serverName) || null
  }

  getAllStatuses(): Record<string, MCPHealthStatus> {
    return Object.fromEntries(this.healthStatus)
  }

  stopMonitoring(serverName: string): void {
    const interval = this.monitoringIntervals.get(serverName)
    if (interval) {
      clearInterval(interval)
      this.monitoringIntervals.delete(serverName)
    }
    this.healthStatus.delete(serverName)
  }
}

export interface MCPHealthStatus {
  status: 'healthy' | 'unhealthy' | 'unknown'
  lastCheck: Date
  responseTime: number | null
  error: string | null
}
```

### **5. Rate Limiting Pattern**

```typescript
// packages/cpa/src/integrations/rate-limiter.ts
export class RateLimiter {
  private tokens: number
  private queue: Array<{
    resolve: () => void
    reject: (error: Error) => void
    timestamp: number
  }> = []
  private refillInterval: NodeJS.Timeout

  constructor(
    private maxTokens: number,
    private refillPeriodMs: number
  ) {
    this.tokens = maxTokens
    
    // Refill tokens periodically
    this.refillInterval = setInterval(() => {
      this.refillTokens()
    }, refillPeriodMs)
  }

  async acquire(): Promise<void> {
    if (this.tokens > 0) {
      this.tokens--
      return Promise.resolve()
    }

    // No tokens available, queue the request
    return new Promise((resolve, reject) => {
      this.queue.push({
        resolve,
        reject,
        timestamp: Date.now()
      })

      // Clean up old requests (timeout after 30 seconds)
      setTimeout(() => {
        const index = this.queue.findIndex(req => req.timestamp === Date.now())
        if (index !== -1) {
          const request = this.queue.splice(index, 1)[0]
          request.reject(new Error('Rate limit request timed out'))
        }
      }, 30000)
    })
  }

  private refillTokens(): void {
    this.tokens = Math.min(this.maxTokens, this.tokens + 1)
    
    // Process queued requests
    while (this.tokens > 0 && this.queue.length > 0) {
      this.tokens--
      const request = this.queue.shift()!
      request.resolve()
    }
  }

  destroy(): void {
    if (this.refillInterval) {
      clearInterval(this.refillInterval)
    }
    
    // Reject all pending requests
    this.queue.forEach(request => {
      request.reject(new Error('Rate limiter destroyed'))
    })
    this.queue = []
  }
}

// Usage in integration
export class SquareMCPIntegration {
  private rateLimiter = new RateLimiter(100, 60000) // 100 requests per minute

  async getTransactions(params: GetTransactionsParams): Promise<Transaction[]> {
    await this.rateLimiter.acquire()
    
    return this.mcpConnection.callTool('get_transactions', params)
  }
}
```

---

## 🏭 **MCP Server Implementation Patterns**

### **1. Custom MCP Server Structure**

```typescript
// packages/cpa/mcp-servers/quickbooks/src/index.ts
import { Server } from '@modelcontextprotocol/sdk/server/index.js'
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js'
import { QuickBooksAPI } from './quickbooks-api.js'
import { ConfigManager } from './config.js'
import { Logger } from './logger.js'

class QuickBooksMCPServer {
  private server: Server
  private qbAPI: QuickBooksAPI
  private config: ConfigManager
  private logger: Logger

  constructor() {
    this.config = new ConfigManager()
    this.logger = new Logger('QuickBooks-MCP')
    this.qbAPI = new QuickBooksAPI(this.config, this.logger)
    
    this.server = new Server(
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

    this.setupToolHandlers()
    this.setupErrorHandling()
  }

  private setupToolHandlers(): void {
    // List available tools
    this.server.setRequestHandler('tools/list', async () => {
      return {
        tools: [
          {
            name: 'create_journal_entry',
            description: 'Create a journal entry in QuickBooks',
            inputSchema: this.getJournalEntrySchema()
          },
          {
            name: 'get_chart_of_accounts',
            description: 'Get chart of accounts for a client',
            inputSchema: this.getChartOfAccountsSchema()
          },
          {
            name: 'get_transactions',
            description: 'Get transactions for a date range',
            inputSchema: this.getTransactionsSchema()
          },
          {
            name: 'health_check',
            description: 'Check server health and QuickBooks API connectivity',
            inputSchema: { type: 'object', properties: {} }
          }
        ]
      }
    })

    // Handle tool calls
    this.server.setRequestHandler('tools/call', async (request) => {
      const { name, arguments: args } = request.params

      this.logger.info(`Tool called: ${name}`, args)

      try {
        switch (name) {
          case 'create_journal_entry':
            return await this.handleCreateJournalEntry(args)
          
          case 'get_chart_of_accounts':
            return await this.handleGetChartOfAccounts(args)
          
          case 'get_transactions':
            return await this.handleGetTransactions(args)
          
          case 'health_check':
            return await this.handleHealthCheck()
          
          default:
            throw new Error(`Unknown tool: ${name}`)
        }
      } catch (error) {
        this.logger.error(`Tool execution failed: ${name}`, error)
        throw error
      }
    })
  }

  private async handleCreateJournalEntry(args: any) {
    const journalEntry = await this.qbAPI.createJournalEntry({
      date: args.date,
      lines: args.lines,
      memo: args.memo,
      clientId: args.client_id
    })

    return {
      content: [
        {
          type: 'text',
          text: `Journal entry created successfully: ${journalEntry.Id}`
        }
      ]
    }
  }

  private async handleGetChartOfAccounts(args: any) {
    const accounts = await this.qbAPI.getChartOfAccounts(args.client_id)

    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify(accounts, null, 2)
        }
      ]
    }
  }

  private async handleHealthCheck() {
    const health = await this.qbAPI.checkHealth()
    
    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify({
            status: 'healthy',
            timestamp: new Date().toISOString(),
            quickbooks_api: health.connected ? 'connected' : 'disconnected',
            response_time: health.responseTime
          })
        }
      ]
    }
  }

  private setupErrorHandling(): void {
    this.server.onerror = (error) => {
      this.logger.error('MCP Server error:', error)
    }
  }

  start(): void {
    const transport = new StdioServerTransport()
    this.server.connect(transport)
    this.logger.info('QuickBooks MCP Server started')
  }
}

// Start the server
const server = new QuickBooksMCPServer()
server.start()
```

### **2. Configuration Management for MCP Servers**

```typescript
// packages/cpa/mcp-servers/quickbooks/src/config.ts
export class ConfigManager {
  private config: QuickBooksConfig

  constructor() {
    this.config = this.loadConfig()
    this.validateConfig()
  }

  private loadConfig(): QuickBooksConfig {
    return {
      clientId: this.getRequired('QUICKBOOKS_CLIENT_ID'),
      clientSecret: this.getRequired('QUICKBOOKS_CLIENT_SECRET'),
      environment: (process.env.QUICKBOOKS_ENVIRONMENT || 'production') as 'sandbox' | 'production',
      redirectUri: process.env.QUICKBOOKS_REDIRECT_URI || 'http://localhost:3000/callback',
      
      // Rate limiting
      rateLimitPerSecond: parseInt(process.env.QB_RATE_LIMIT || '10'),
      
      // Caching
      cacheEnabled: process.env.QB_CACHE_ENABLED !== 'false',
      cacheTTLSeconds: parseInt(process.env.QB_CACHE_TTL || '300'),
      
      // Timeouts
      requestTimeoutMs: parseInt(process.env.QB_REQUEST_TIMEOUT || '30000'),
      
      // Logging
      logLevel: process.env.QB_LOG_LEVEL || 'info'
    }
  }

  private getRequired(key: string): string {
    const value = process.env[key]
    if (!value) {
      throw new Error(`Required environment variable ${key} is not set`)
    }
    return value
  }

  private validateConfig(): void {
    if (!['sandbox', 'production'].includes(this.config.environment)) {
      throw new Error('QUICKBOOKS_ENVIRONMENT must be "sandbox" or "production"')
    }

    if (this.config.rateLimitPerSecond < 1 || this.config.rateLimitPerSecond > 100) {
      throw new Error('QB_RATE_LIMIT must be between 1 and 100')
    }
  }

  get(): QuickBooksConfig {
    return { ...this.config }
  }
}

interface QuickBooksConfig {
  clientId: string
  clientSecret: string
  environment: 'sandbox' | 'production'
  redirectUri: string
  rateLimitPerSecond: number
  cacheEnabled: boolean
  cacheTTLSeconds: number
  requestTimeoutMs: number
  logLevel: string
}
```

### **3. API Client Wrapper Pattern**

```typescript
// packages/cpa/mcp-servers/quickbooks/src/quickbooks-api.ts
import QuickBooks from 'node-quickbooks'
import { ConfigManager } from './config.js'
import { Logger } from './logger.js'

export class QuickBooksAPI {
  private qb: any
  private config: ConfigManager
  private logger: Logger
  private rateLimiter: RateLimiter

  constructor(config: ConfigManager, logger: Logger) {
    this.config = config
    this.logger = logger
    this.rateLimiter = new RateLimiter(
      config.get().rateLimitPerSecond,
      1000
    )
    this.initializeClient()
  }

  private initializeClient(): void {
    const config = this.config.get()
    
    this.qb = new QuickBooks(
      config.clientId,
      config.clientSecret,
      process.env.QB_ACCESS_TOKEN!, // Retrieved during OAuth flow
      false, // Use sandbox
      config.environment === 'sandbox',
      true, // Enable debugging
      false, // Minorversion
      '2.0', // OAuth version
      process.env.QB_REFRESH_TOKEN! // Retrieved during OAuth flow
    )
  }

  async createJournalEntry(entry: JournalEntryRequest): Promise<any> {
    await this.rateLimiter.acquire()
    
    this.logger.info('Creating journal entry', { 
      date: entry.date, 
      clientId: entry.clientId 
    })

    return new Promise((resolve, reject) => {
      const journalEntryData = {
        Line: entry.lines.map(line => ({
          Amount: line.debitAmount || line.creditAmount,
          DetailType: 'JournalEntryLineDetail',
          JournalEntryLineDetail: {
            PostingType: line.debitAmount ? 'Debit' : 'Credit',
            AccountRef: { value: line.accountId }
          },
          Description: line.description
        })),
        TxnDate: entry.date,
        PrivateNote: entry.memo
      }

      this.qb.createJournalEntry(journalEntryData, (err: any, result: any) => {
        if (err) {
          this.logger.error('Failed to create journal entry', err)
          reject(new Error(`QuickBooks API error: ${err.message}`))
        } else {
          this.logger.info('Journal entry created', { id: result.Id })
          resolve(result)
        }
      })
    })
  }

  async getChartOfAccounts(clientId: string): Promise<any[]> {
    await this.rateLimiter.acquire()
    
    this.logger.info('Getting chart of accounts', { clientId })

    return new Promise((resolve, reject) => {
      this.qb.findAccounts((err: any, accounts: any) => {
        if (err) {
          this.logger.error('Failed to get chart of accounts', err)
          reject(new Error(`QuickBooks API error: ${err.message}`))
        } else {
          this.logger.info('Retrieved chart of accounts', { 
            count: accounts?.QueryResponse?.Account?.length || 0 
          })
          resolve(accounts?.QueryResponse?.Account || [])
        }
      })
    })
  }

  async checkHealth(): Promise<{ connected: boolean; responseTime: number }> {
    const startTime = Date.now()
    
    try {
      await this.rateLimiter.acquire()
      
      return new Promise((resolve, reject) => {
        this.qb.getCompanyInfo(process.env.QB_COMPANY_ID, (err: any, result: any) => {
          const responseTime = Date.now() - startTime
          
          if (err) {
            resolve({ connected: false, responseTime })
          } else {
            resolve({ connected: true, responseTime })
          }
        })
      })
    } catch (error) {
      return { connected: false, responseTime: Date.now() - startTime }
    }
  }
}
```

---

## 🧪 **Testing MCP Integrations**

### **1. Mock MCP Server for Testing**

```typescript
// packages/cpa/tests/mocks/quickbooks-mcp-mock.ts
export class QuickBooksMCPMock {
  private tools = new Map<string, any>()

  constructor() {
    this.setupMockTools()
  }

  private setupMockTools(): void {
    this.tools.set('create_journal_entry', async (args: any) => {
      // Simulate QuickBooks response
      return {
        content: [{
          type: 'text',
          text: JSON.stringify({
            Id: `mock-${Date.now()}`,
            TxnDate: args.date,
            TotalAmt: args.lines.reduce((sum: number, line: any) => 
              sum + (line.debit_amount || line.credit_amount), 0
            )
          })
        }]
      }
    })

    this.tools.set('get_chart_of_accounts', async (args: any) => {
      return {
        content: [{
          type: 'text',
          text: JSON.stringify([
            { Id: '1', Name: 'Checking Account', AccountType: 'Bank' },
            { Id: '2', Name: 'Accounts Receivable', AccountType: 'Accounts Receivable' },
            { Id: '3', Name: 'Office Supplies', AccountType: 'Expense' }
          ])
        }]
      }
    })

    this.tools.set('health_check', async () => {
      return {
        content: [{
          type: 'text',
          text: JSON.stringify({
            status: 'healthy',
            timestamp: new Date().toISOString(),
            quickbooks_api: 'connected',
            response_time: 100
          })
        }]
      }
    })
  }

  async callTool(name: string, args: any): Promise<any> {
    const tool = this.tools.get(name)
    if (!tool) {
      throw new Error(`Mock tool not found: ${name}`)
    }
    return await tool(args)
  }

  listTools(): string[] {
    return Array.from(this.tools.keys())
  }
}
```

### **2. Integration Testing Pattern**

```typescript
// packages/cpa/tests/integration/quickbooks-integration.test.ts
describe('QuickBooks MCP Integration', () => {
  let mcpManager: CPAMCPManager
  let quickbooks: QuickBooksMCPIntegration
  let mockServer: QuickBooksMCPMock

  beforeEach(async () => {
    // Set up mock MCP server
    mockServer = new QuickBooksMCPMock()
    
    // Create test MCP manager
    mcpManager = new CPAMCPManager(createTestConfig())
    await mcpManager.initialize(createMockGeminiConfig())
    
    // Create integration instance
    quickbooks = new QuickBooksMCPIntegration(mcpManager)
  })

  afterEach(async () => {
    await mcpManager.cleanup()
  })

  describe('createJournalEntry', () => {
    it('should create journal entry successfully', async () => {
      const entry: JournalEntryRequest = {
        date: '2024-12-27',
        lines: [
          { accountId: '1', debitAmount: 100.00, description: 'Test debit' },
          { accountId: '2', creditAmount: 100.00, description: 'Test credit' }
        ],
        memo: 'Test journal entry',
        clientId: 'test-client-1'
      }

      const result = await quickbooks.createJournalEntry(entry)

      expect(result.id).toBeDefined()
      expect(result.date).toEqual(new Date(entry.date))
      expect(result.amount).toBe(100.00)
    })

    it('should handle QuickBooks API errors', async () => {
      // Configure mock to return error
      jest.spyOn(mockServer, 'callTool').mockRejectedValue(
        new Error('QuickBooks API error: Invalid account')
      )

      const entry: JournalEntryRequest = {
        date: '2024-12-27',
        lines: [{ accountId: 'invalid', debitAmount: 100.00, description: 'Test' }],
        memo: 'Test',
        clientId: 'test-client-1'
      }

      await expect(quickbooks.createJournalEntry(entry))
        .rejects
        .toThrow('Failed to create journal entry')
    })
  })

  describe('health monitoring', () => {
    it('should report healthy status when QuickBooks is accessible', async () => {
      const status = await mcpManager.getHealthStatus()
      
      expect(status['cpa-quickbooks']).toBeDefined()
      expect(status['cpa-quickbooks'].status).toBe('healthy')
    })

    it('should report unhealthy status when QuickBooks is not accessible', async () => {
      // Simulate connection failure
      jest.spyOn(mockServer, 'callTool').mockRejectedValue(
        new Error('Connection refused')
      )

      const status = await mcpManager.getHealthStatus()
      
      expect(status['cpa-quickbooks'].status).toBe('unhealthy')
      expect(status['cpa-quickbooks'].error).toContain('Connection refused')
    })
  })
})
```

### **3. Performance Testing for MCP**

```typescript
// packages/cpa/tests/performance/mcp-performance.test.ts
describe('MCP Performance Tests', () => {
  let quickbooks: QuickBooksMCPIntegration

  beforeEach(async () => {
    quickbooks = await setupQuickBooksIntegration()
  })

  it('should handle burst requests within rate limits', async () => {
    const requests = Array.from({ length: 50 }, (_, i) => 
      quickbooks.createJournalEntry(createTestJournalEntry(i))
    )

    const startTime = Date.now()
    const results = await Promise.all(requests)
    const duration = Date.now() - startTime

    expect(results).toHaveLength(50)
    expect(results.every(result => result.id)).toBe(true)
    
    // Should complete within reasonable time (considering rate limits)
    expect(duration).toBeLessThan(60000) // 1 minute
  })

  it('should maintain performance under sustained load', async () => {
    const metrics: number[] = []

    for (let i = 0; i < 100; i++) {
      const startTime = Date.now()
      await quickbooks.getChartOfAccounts('test-client')
      const duration = Date.now() - startTime
      
      metrics.push(duration)
      
      // Small delay to avoid overwhelming the rate limiter
      await new Promise(resolve => setTimeout(resolve, 100))
    }

    const averageTime = metrics.reduce((sum, time) => sum + time, 0) / metrics.length
    const maxTime = Math.max(...metrics)

    expect(averageTime).toBeLessThan(2000) // Average under 2 seconds
    expect(maxTime).toBeLessThan(5000)     // Max under 5 seconds
  })
})
```

---

## 📊 **Monitoring and Observability**

### **1. MCP Metrics Collection**

```typescript
// packages/cpa/src/integrations/mcp-metrics.ts
export class MCPMetrics {
  private static instance: MCPMetrics
  private metrics = new Map<string, any>()

  static getInstance(): MCPMetrics {
    if (!MCPMetrics.instance) {
      MCPMetrics.instance = new MCPMetrics()
    }
    return MCPMetrics.instance
  }

  recordToolCall(
    serverName: string,
    toolName: string,
    duration: number,
    success: boolean
  ): void {
    const key = `${serverName}.${toolName}`
    
    if (!this.metrics.has(key)) {
      this.metrics.set(key, {
        totalCalls: 0,
        successfulCalls: 0,
        failedCalls: 0,
        totalDuration: 0,
        averageDuration: 0,
        minDuration: Infinity,
        maxDuration: 0
      })
    }

    const metric = this.metrics.get(key)
    metric.totalCalls++
    
    if (success) {
      metric.successfulCalls++
    } else {
      metric.failedCalls++
    }

    metric.totalDuration += duration
    metric.averageDuration = metric.totalDuration / metric.totalCalls
    metric.minDuration = Math.min(metric.minDuration, duration)
    metric.maxDuration = Math.max(metric.maxDuration, duration)
  }

  getMetrics(): Record<string, any> {
    return Object.fromEntries(this.metrics)
  }

  getServerMetrics(serverName: string): Record<string, any> {
    const serverMetrics: Record<string, any> = {}
    
    for (const [key, value] of this.metrics) {
      if (key.startsWith(serverName + '.')) {
        serverMetrics[key] = value
      }
    }
    
    return serverMetrics
  }

  reset(): void {
    this.metrics.clear()
  }
}
```

### **2. Logging Pattern**

```typescript
// packages/cpa/src/integrations/mcp-logger.ts
export class MCPLogger {
  constructor(private serverName: string) {}

  info(message: string, metadata?: any): void {
    console.log(JSON.stringify({
      level: 'info',
      timestamp: new Date().toISOString(),
      server: this.serverName,
      message,
      metadata
    }))
  }

  error(message: string, error?: any): void {
    console.error(JSON.stringify({
      level: 'error',
      timestamp: new Date().toISOString(),
      server: this.serverName,
      message,
      error: error?.message || error,
      stack: error?.stack
    }))
  }

  warn(message: string, metadata?: any): void {
    console.warn(JSON.stringify({
      level: 'warn',
      timestamp: new Date().toISOString(),
      server: this.serverName,
      message,
      metadata
    }))
  }

  debug(message: string, metadata?: any): void {
    if (process.env.DEBUG?.includes('mcp') || process.env.NODE_ENV === 'development') {
      console.debug(JSON.stringify({
        level: 'debug',
        timestamp: new Date().toISOString(),
        server: this.serverName,
        message,
        metadata
      }))
    }
  }
}
```

---

This comprehensive guide provides proven patterns for building robust, scalable MCP integrations for the CPA AI Agent. These patterns ensure reliability, performance, and maintainability while integrating with external accounting systems and business tools.