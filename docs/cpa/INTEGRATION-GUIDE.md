# 🔌 CPA AI Agent Integration Guide

**Project:** Gemini CLI Enhanced for CPA Workflows  
**Version:** 1.0  
**Last Updated:** 2024-12-27

---

## 🎯 **Integration Overview**

This guide covers how to integrate the CPA AI Agent with existing accounting software, payment systems, and business workflows. The CPA Agent leverages MCP (Model Context Protocol) servers and modern APIs to connect with your existing tech stack.

---

## 🏗️ **Integration Architecture**

```
                    CPA AI Agent
                         │
              ┌──────────┼──────────┐
              │          │          │
         ┌────▼────┐ ┌───▼───┐ ┌────▼────┐
         │   MCP   │ │  API  │ │  File   │
         │ Servers │ │ Direct│ │ Import  │
         └────┬────┘ └───┬───┘ └────┬────┘
              │          │          │
    ┌─────────┼──────────┼──────────┼─────────┐
    │         │          │          │         │
┌───▼───┐ ┌──▼──┐ ┌─────▼─────┐ ┌──▼──┐ ┌───▼────┐
│QuickB.│ │Gmail│ │  Banking  │ │Square│ │Document│
│       │ │     │ │ Providers │ │      │ │Storage │
└───────┘ └─────┘ └───────────┘ └─────┘ └────────┘
```

---

## 💼 **QuickBooks Integration**

### Prerequisites
- QuickBooks Online or Desktop version
- QuickBooks API access (Intuit Developer account)
- OAuth 2.0 credentials

### Setup Process

1. **Register Application**
```bash
# Register at https://developer.intuit.com/
QUICKBOOKS_CLIENT_ID="your_client_id"
QUICKBOOKS_CLIENT_SECRET="your_client_secret"
QUICKBOOKS_REDIRECT_URI="http://localhost:3000/callback"
```

2. **Install QuickBooks MCP Server**
```bash
npm install @cpa-agent/quickbooks-mcp-server
```

3. **Configure Connection**
```typescript
// packages/cpa/src/integrations/quickbooks-client.ts
export class QuickBooksIntegration {
  private client: QuickBooksClient
  
  async initialize(): Promise<void> {
    this.client = new QuickBooksClient({
      clientId: process.env.QUICKBOOKS_CLIENT_ID,
      clientSecret: process.env.QUICKBOOKS_CLIENT_SECRET,
      environment: 'production', // or 'sandbox'
      redirectUri: process.env.QUICKBOOKS_REDIRECT_URI
    })
    
    await this.client.authenticate()
  }
}
```

### Available Operations

**Chart of Accounts Management:**
```typescript
// Get all accounts
const accounts = await quickbooks.getAccounts()

// Create new account
const newAccount = await quickbooks.createAccount({
  name: 'Office Supplies',
  type: 'Expense',
  subType: 'SuppliesMaterials'
})
```

**Transaction Management:**
```typescript
// Create journal entry
const journalEntry = await quickbooks.createJournalEntry({
  date: '2024-12-27',
  lines: [
    { account: 'Office Supplies', debit: 247.83 },
    { account: 'Checking Account', credit: 247.83 }
  ],
  memo: 'Office Depot receipt - automated entry'
})

// Get transactions by date range
const transactions = await quickbooks.getTransactions({
  startDate: '2024-12-01',
  endDate: '2024-12-31'
})
```

**Report Generation:**
```typescript
// Generate P&L statement
const profitLoss = await quickbooks.generateReport('ProfitAndLoss', {
  startDate: '2024-01-01',
  endDate: '2024-12-31',
  customer: clientId
})

// Generate balance sheet
const balanceSheet = await quickbooks.generateReport('BalanceSheet', {
  reportDate: '2024-12-31'
})
```

---

## 💳 **Square Payment Integration**

### Prerequisites
- Square Developer account
- Square API credentials
- Active Square merchant account

### Setup Process

1. **Get API Credentials**
```bash
# From Square Developer Dashboard
SQUARE_APPLICATION_ID="your_app_id"
SQUARE_ACCESS_TOKEN="your_access_token"
SQUARE_ENVIRONMENT="production" # or "sandbox"
```

2. **Configure Square Client**
```typescript
// packages/cpa/src/integrations/square-client.ts
export class SquareIntegration {
  private client: SquareApi
  
  constructor() {
    this.client = new SquareApi({
      accessToken: process.env.SQUARE_ACCESS_TOKEN,
      environment: process.env.SQUARE_ENVIRONMENT
    })
  }
}
```

### Payment Processing

**Transaction Retrieval:**
```typescript
// Get recent transactions
const transactions = await square.getTransactions({
  locationId: 'main-location',
  beginTime: '2024-12-27T00:00:00Z',
  endTime: '2024-12-27T23:59:59Z'
})

// Process transactions for accounting
const processedTransactions = transactions.map(tx => ({
  id: tx.id,
  amount: tx.totalMoney.amount / 100, // Convert from cents
  currency: tx.totalMoney.currency,
  date: new Date(tx.createdAt),
  paymentMethod: tx.cardDetails?.card?.cardBrand,
  description: `Square payment - ${tx.id.substring(0, 8)}`
}))
```

**Revenue Categorization:**
```typescript
// Automatically categorize Square revenue
const categorizeSquareTransaction = async (transaction: SquareTransaction) => {
  const category = await ai.categorize({
    description: transaction.description,
    amount: transaction.amount,
    merchant: 'Square',
    context: 'revenue'
  })
  
  return {
    ...transaction,
    account: category.account,
    taxCategory: category.taxCategory,
    deductible: category.deductible
  }
}
```

---

## 📧 **Gmail Integration**

### Prerequisites
- Google Workspace or Gmail account
- Google Cloud Console project
- Gmail API enabled

### Setup Process

1. **Enable Gmail API**
```bash
# Create credentials at https://console.cloud.google.com/
GMAIL_CLIENT_ID="your_gmail_client_id"
GMAIL_CLIENT_SECRET="your_gmail_client_secret"
GMAIL_REFRESH_TOKEN="your_refresh_token"
```

2. **Configure Gmail Client**
```typescript
// packages/cpa/src/integrations/gmail-client.ts
export class GmailIntegration {
  private gmail: gmail_v1.Gmail
  
  async initialize(): Promise<void> {
    const auth = new google.auth.OAuth2(
      process.env.GMAIL_CLIENT_ID,
      process.env.GMAIL_CLIENT_SECRET,
      'http://localhost:3000/oauth/callback'
    )
    
    auth.setCredentials({
      refresh_token: process.env.GMAIL_REFRESH_TOKEN
    })
    
    this.gmail = google.gmail({ version: 'v1', auth })
  }
}
```

### Client Communication Automation

**Send Client Updates:**
```typescript
// Send automated client update
const sendClientUpdate = async (client: Client, update: ClientUpdate) => {
  const template = await loadTemplate('client-update')
  const personalizedContent = await personalizeTemplate(template, {
    clientName: client.name,
    updateType: update.type,
    summary: update.summary,
    nextSteps: update.nextSteps
  })
  
  await gmail.users.messages.send({
    userId: 'me',
    requestBody: {
      raw: createEmailRaw({
        to: client.email,
        from: 'noreply@youracctingfirm.com',
        subject: `Update for ${client.name} - ${update.subject}`,
        body: personalizedContent,
        attachments: update.attachments
      })
    }
  })
}
```

**Document Request Automation:**
```typescript
// Request missing documents
const requestDocuments = async (client: Client, missingDocs: string[]) => {
  const template = await loadTemplate('document-request')
  const content = await personalizeTemplate(template, {
    clientName: client.name,
    missingDocuments: missingDocs,
    deadline: getNextDeadline(client),
    uploadLink: generateSecureUploadLink(client)
  })
  
  await sendEmail(client.email, 'Documents Needed', content)
  await logCommunication(client, 'document_request', missingDocs)
}
```

---

## 🏦 **Banking Integration**

### Supported Banks
- Chase Bank
- Bank of America  
- Wells Fargo
- US Bank
- Most banks via Plaid/Yodlee

### Setup Process

1. **Choose Banking Provider**
```bash
# Option 1: Plaid (Recommended)
PLAID_CLIENT_ID="your_plaid_client_id"
PLAID_SECRET="your_plaid_secret"
PLAID_ENVIRONMENT="production" # or "sandbox"

# Option 2: Yodlee
YODLEE_CLIENT_ID="your_yodlee_client_id"
YODLEE_SECRET="your_yodlee_secret"
```

2. **Configure Bank Feed Integration**
```typescript
// packages/cpa/src/integrations/bank-feeds.ts
export class BankFeedIntegration {
  private plaid: PlaidApi
  
  constructor() {
    this.plaid = new PlaidApi({
      clientId: process.env.PLAID_CLIENT_ID,
      secret: process.env.PLAID_SECRET,
      environment: process.env.PLAID_ENVIRONMENT
    })
  }
}
```

### Transaction Import

**Automated Transaction Sync:**
```typescript
// Daily transaction sync
const syncBankTransactions = async (client: Client) => {
  const accounts = await plaid.getAccounts(client.plaidAccessToken)
  
  for (const account of accounts) {
    const transactions = await plaid.getTransactions({
      accessToken: client.plaidAccessToken,
      accountId: account.id,
      startDate: getLastSyncDate(client, account),
      endDate: new Date()
    })
    
    for (const transaction of transactions) {
      const categorized = await aiCategorizer.categorize(transaction)
      await saveTransaction({
        ...transaction,
        clientId: client.id,
        category: categorized.category,
        needsReview: categorized.confidence < 0.90
      })
    }
  }
}
```

**Reconciliation Automation:**
```typescript
// Bank reconciliation
const reconcileAccount = async (client: Client, accountId: string, month: string) => {
  const bankTransactions = await getBankTransactions(accountId, month)
  const qbTransactions = await getQuickBooksTransactions(client, accountId, month)
  
  const reconciliation = await performReconciliation(bankTransactions, qbTransactions)
  
  return {
    matched: reconciliation.matched,
    unmatched: reconciliation.unmatched,
    suggestions: reconciliation.suggestions,
    summary: reconciliation.summary
  }
}
```

---

## 📊 **Database Integration**

### Client Database Schema

```sql
-- Client management tables
CREATE TABLE clients (
  id UUID PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  type VARCHAR(50) NOT NULL,
  email VARCHAR(255) UNIQUE,
  phone VARCHAR(20),
  tax_year INTEGER,
  status VARCHAR(20) DEFAULT 'active',
  quickbooks_id VARCHAR(100),
  plaid_access_token TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE client_documents (
  id UUID PRIMARY KEY,
  client_id UUID REFERENCES clients(id),
  filename VARCHAR(255) NOT NULL,
  file_type VARCHAR(50),
  file_path TEXT NOT NULL,
  processed_at TIMESTAMP,
  extraction_data JSONB,
  category VARCHAR(100),
  confidence DECIMAL(3,2),
  needs_review BOOLEAN DEFAULT FALSE
);

CREATE TABLE transactions (
  id UUID PRIMARY KEY,
  client_id UUID REFERENCES clients(id),
  external_id VARCHAR(255),
  date DATE NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  description TEXT,
  category VARCHAR(100),
  account VARCHAR(100),
  source VARCHAR(50),
  ai_categorized BOOLEAN DEFAULT FALSE,
  confidence DECIMAL(3,2),
  needs_review BOOLEAN DEFAULT FALSE,
  quickbooks_entry_id VARCHAR(100)
);
```

### Database Operations

**Client Management:**
```typescript
// packages/cpa/src/data/repositories/client-repository.ts
export class ClientRepository {
  async createClient(client: CreateClientRequest): Promise<Client> {
    const result = await this.db.query(`
      INSERT INTO clients (name, type, email, phone, tax_year)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
    `, [client.name, client.type, client.email, client.phone, client.taxYear])
    
    return this.mapToClient(result.rows[0])
  }
  
  async getClientByName(name: string): Promise<Client | null> {
    const result = await this.db.query(`
      SELECT * FROM clients 
      WHERE LOWER(name) = LOWER($1) 
      AND status = 'active'
    `, [name])
    
    return result.rows[0] ? this.mapToClient(result.rows[0]) : null
  }
}
```

**Transaction Management:**
```typescript
// packages/cpa/src/data/repositories/transaction-repository.ts
export class TransactionRepository {
  async saveTransaction(transaction: Transaction): Promise<void> {
    await this.db.query(`
      INSERT INTO transactions (
        client_id, external_id, date, amount, description,
        category, account, source, ai_categorized, confidence
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      ON CONFLICT (external_id) DO UPDATE SET
        category = EXCLUDED.category,
        confidence = EXCLUDED.confidence,
        updated_at = NOW()
    `, [
      transaction.clientId,
      transaction.externalId,
      transaction.date,
      transaction.amount,
      transaction.description,
      transaction.category,
      transaction.account,
      transaction.source,
      transaction.aiCategorized,
      transaction.confidence
    ])
  }
}
```

---

## 📁 **Document Storage Integration**

### Supported Storage Providers
- AWS S3
- Google Cloud Storage
- Azure Blob Storage
- Local file system

### Setup Process

1. **Configure Storage Provider**
```bash
# AWS S3 Configuration
AWS_ACCESS_KEY_ID="your_access_key"
AWS_SECRET_ACCESS_KEY="your_secret_key"
AWS_REGION="us-east-1"
S3_BUCKET_NAME="cpa-agent-documents"

# Google Cloud Storage
GOOGLE_CLOUD_PROJECT="your-project-id"
GOOGLE_CLOUD_KEYFILE="path/to/service-account.json"
GCS_BUCKET_NAME="cpa-agent-documents"
```

2. **Document Storage Client**
```typescript
// packages/cpa/src/integrations/document-storage.ts
export class DocumentStorage {
  private s3: AWS.S3
  
  constructor() {
    this.s3 = new AWS.S3({
      region: process.env.AWS_REGION,
      accessKeyId: process.env.AWS_ACCESS_KEY_ID,
      secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
    })
  }
  
  async storeDocument(file: File, client: Client): Promise<string> {
    const key = `clients/${client.id}/documents/${Date.now()}-${file.name}`
    
    await this.s3.upload({
      Bucket: process.env.S3_BUCKET_NAME,
      Key: key,
      Body: file.buffer,
      ContentType: file.mimetype,
      Metadata: {
        clientId: client.id,
        originalName: file.name,
        uploadDate: new Date().toISOString()
      }
    }).promise()
    
    return key
  }
}
```

### Document Processing Pipeline

**Receipt Processing:**
```typescript
// Process uploaded receipt
const processReceipt = async (file: File, client: Client): Promise<ProcessedDocument> => {
  // Step 1: Store original document
  const storagePath = await documentStorage.storeDocument(file, client)
  
  // Step 2: Extract data using Gemini Vision
  const extractedData = await geminiVision.extractReceiptData(file)
  
  // Step 3: AI categorization
  const category = await aiCategorizer.categorizeExpense(extractedData, client.context)
  
  // Step 4: Generate QuickBooks entry
  const qbEntry = await quickbooks.createJournalEntry({
    date: extractedData.date,
    amount: extractedData.amount,
    description: extractedData.description,
    category: category.account,
    client: client.quickbooksId
  })
  
  // Step 5: Save processing results
  const document = await documentRepository.save({
    clientId: client.id,
    originalFilename: file.name,
    storagePath,
    extractedData,
    category: category.category,
    confidence: category.confidence,
    quickbooksEntryId: qbEntry.id,
    needsReview: category.confidence < 0.95
  })
  
  return document
}
```

---

## ⚙️ **Configuration Management**

### Environment Configuration

```bash
# .env.production
# Gemini AI
GEMINI_API_KEY="your_gemini_api_key"

# QuickBooks Integration
QUICKBOOKS_CLIENT_ID="your_qb_client_id"
QUICKBOOKS_CLIENT_SECRET="your_qb_client_secret"
QUICKBOOKS_REDIRECT_URI="https://yourdomain.com/qb/callback"

# Square Integration
SQUARE_APPLICATION_ID="your_square_app_id"
SQUARE_ACCESS_TOKEN="your_square_access_token"
SQUARE_ENVIRONMENT="production"

# Banking (Plaid)
PLAID_CLIENT_ID="your_plaid_client_id"
PLAID_SECRET="your_plaid_secret"
PLAID_ENVIRONMENT="production"

# Gmail
GMAIL_CLIENT_ID="your_gmail_client_id"
GMAIL_CLIENT_SECRET="your_gmail_client_secret"

# Database
DATABASE_URL="postgresql://user:pass@localhost/cpa_agent"

# Storage
AWS_ACCESS_KEY_ID="your_aws_key"
AWS_SECRET_ACCESS_KEY="your_aws_secret"
S3_BUCKET_NAME="cpa-documents"

# Security
JWT_SECRET="your_jwt_secret"
ENCRYPTION_KEY="your_encryption_key"
```

### Application Configuration

```typescript
// packages/cpa/src/config/app-config.ts
export interface CPAConfig {
  ai: {
    provider: 'gemini' | 'openai'
    apiKey: string
    model: string
  }
  integrations: {
    quickbooks: QuickBooksConfig
    square: SquareConfig
    gmail: GmailConfig
    banking: BankingConfig
  }
  storage: {
    provider: 'aws' | 'gcp' | 'azure' | 'local'
    config: StorageConfig
  }
  security: {
    jwtSecret: string
    encryptionKey: string
    sessionTimeout: number
  }
}

export const loadConfig = (): CPAConfig => {
  return {
    ai: {
      provider: 'gemini',
      apiKey: process.env.GEMINI_API_KEY!,
      model: 'gemini-pro'
    },
    integrations: {
      quickbooks: {
        clientId: process.env.QUICKBOOKS_CLIENT_ID!,
        clientSecret: process.env.QUICKBOOKS_CLIENT_SECRET!,
        redirectUri: process.env.QUICKBOOKS_REDIRECT_URI!,
        environment: process.env.QUICKBOOKS_ENVIRONMENT || 'production'
      },
      // ... other integrations
    },
    // ... other config sections
  }
}
```

---

## 🧪 **Testing Integrations**

### Integration Test Setup

```typescript
// packages/cpa/tests/integration/quickbooks.test.ts
describe('QuickBooks Integration', () => {
  let quickbooks: QuickBooksIntegration
  
  beforeEach(async () => {
    quickbooks = new QuickBooksIntegration({
      environment: 'sandbox',
      credentials: getTestCredentials()
    })
    await quickbooks.initialize()
  })
  
  test('should create journal entry', async () => {
    const entry = await quickbooks.createJournalEntry({
      date: '2024-12-27',
      lines: [
        { account: 'Office Supplies', debit: 100.00 },
        { account: 'Checking', credit: 100.00 }
      ]
    })
    
    expect(entry.id).toBeDefined()
    expect(entry.status).toBe('active')
  })
})
```

### Mock Integrations for Development

```typescript
// packages/cpa/src/integrations/mocks/quickbooks-mock.ts
export class QuickBooksMock implements QuickBooksIntegration {
  async createJournalEntry(entry: JournalEntryRequest): Promise<JournalEntry> {
    return {
      id: `mock-${Date.now()}`,
      date: entry.date,
      lines: entry.lines,
      status: 'active',
      created: new Date()
    }
  }
  
  async getAccounts(): Promise<Account[]> {
    return [
      { id: '1', name: 'Checking Account', type: 'Bank' },
      { id: '2', name: 'Office Supplies', type: 'Expense' },
      { id: '3', name: 'Revenue', type: 'Income' }
    ]
  }
}
```

---

## 🚀 **Deployment Considerations**

### Security Best Practices
- Store all API keys in secure environment variables
- Use OAuth 2.0 flows for user authentication
- Encrypt sensitive data at rest and in transit
- Implement proper access controls and audit logging

### Performance Optimization
- Cache frequently accessed data (client profiles, chart of accounts)
- Use connection pooling for database operations
- Implement rate limiting for external API calls
- Monitor and optimize expensive operations

### Error Handling
- Implement circuit breaker patterns for external services
- Provide meaningful error messages to users
- Log all integration errors for debugging
- Implement retry logic with exponential backoff

---

This integration guide provides a comprehensive foundation for connecting the CPA AI Agent with your existing business systems. Each integration can be implemented incrementally, allowing you to start with the most critical connections first.