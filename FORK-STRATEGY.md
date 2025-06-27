# 🍴 Fork Strategy & Contribution Guidelines

**Project:** Gemini CLI Enhanced for CPA Workflows  
**Repository:** [jradfs/gemini-cli-CPA-AI-Agent-Development](https://github.com/jradfs/gemini-cli-CPA-AI-Agent-Development)  
**Upstream:** [google-gemini/gemini-cli](https://github.com/google-gemini/gemini-cli)

---

## 🎯 **Fork Strategy Overview**

This repository is a strategic fork of Google's Gemini CLI, designed to add CPA-specific functionality while maintaining compatibility with the upstream project. Our approach ensures we can benefit from upstream improvements while developing specialized accounting workflows.

---

## 🔄 **Upstream Relationship**

### Fork Structure
```
google-gemini/gemini-cli (upstream)
         ↓
jradfs/gemini-cli-CPA-AI-Agent-Development (our fork)
         ↓
feature branches for CPA development
```

### Sync Strategy
- **Monthly upstream syncs** to incorporate Gemini CLI improvements
- **Selective merging** to avoid conflicts with CPA extensions
- **Clear separation** between core Gemini and CPA functionality

---

## 🚫 **Files We CANNOT Modify**

To maintain compatibility and enable upstream syncing, these files must remain unchanged:

### Core Gemini CLI Files (READ ONLY)
```
packages/cli/src/
├── ui/                    # Original React UI components
├── hooks/                 # Original React hooks
├── config/                # Original configuration
└── utils/                 # Original utilities

packages/core/src/
├── core/                  # Chat engine and API calls
├── tools/                 # Built-in tools and MCP client
├── services/              # Core services
└── utils/                 # Core utilities

Root Configuration (READ ONLY)
├── package.json           # Main package configuration
├── tsconfig.json          # TypeScript configuration
├── eslint.config.js       # ESLint configuration
├── esbuild.config.js      # Build configuration
└── scripts/               # Build and deployment scripts
```

### Build and Deployment (READ ONLY)
```
├── Dockerfile             # Container configuration
├── Makefile              # Build automation
├── bundle/               # Built artifacts
└── integration-tests/    # Core integration tests
```

---

## ✅ **Files We CAN Modify/Extend**

### Documentation (SAFE TO MODIFY)
```
├── README.md             # Add CPA section
├── CONTRIBUTING.md       # Add CPA contribution guidelines
└── docs/                 # Add CPA documentation folder
    └── cpa/              # Our CPA-specific docs
```

### New Packages (SAFE TO ADD)
```
packages/
└── cpa/                  # NEW: CPA-specific functionality
    ├── src/
    ├── tests/
    ├── docs/
    └── package.json
```

### Configuration Extensions (SAFE TO MODIFY)
```
├── .gitignore            # Add CPA-specific ignores
├── .github/              # Add CPA-specific workflows
└── scripts/              # Add CPA-specific scripts (non-conflicting)
```

---

## 🏗️ **Development Approach**

### 1. Extension Pattern (Preferred)
Add new functionality through separate packages rather than modifying existing code:

```typescript
// ✅ GOOD: Extend through new package
packages/cpa/src/extensions/cpa-commands.ts

export function registerCPACommands(cli: GeminiCLI): void {
  cli.registerCommand(new ClientCommand())
  cli.registerCommand(new MorningCommand())
}
```

```typescript
// ❌ AVOID: Modifying core files
packages/cli/src/hooks/slashCommandProcessor.ts
// Don't modify this file directly
```

### 2. Plugin Architecture
Integrate CPA functionality through the existing plugin system:

```typescript
// packages/cpa/src/index.ts
export class CPAPlugin implements GeminiPlugin {
  name = 'cpa-agent'
  version = '1.0.0'
  
  async initialize(cli: GeminiCLI): Promise<void> {
    this.registerCommands(cli)
    this.registerWorkflows(cli)
    this.setupIntegrations(cli)
  }
}
```

### 3. MCP Server Integration
Use the existing MCP architecture for external integrations:

```typescript
// packages/cpa/src/mcp-servers/quickbooks-server.ts
export class QuickBooksMCPServer extends MCPServer {
  // Implement QuickBooks integration as MCP server
}
```

---

## 🔄 **Upstream Sync Process**

### Monthly Sync Workflow

1. **Fetch Upstream Changes**
```bash
git fetch upstream main
git checkout main
git merge upstream/main
```

2. **Test Compatibility**
```bash
npm run test:ci
npm run build
npm run test:integration
```

3. **Resolve Conflicts (if any)**
- Prioritize upstream changes
- Adapt CPA extensions if needed
- Document any breaking changes

4. **Update CPA Extensions**
```bash
cd packages/cpa
npm test
npm run type-check
```

### Conflict Resolution Strategy

**Core Files (packages/cli, packages/core):**
- Always accept upstream changes
- Adapt CPA extensions to work with new upstream

**Documentation:**
- Merge carefully, preserving CPA additions
- Update CPA docs to reflect upstream changes

**Configuration:**
- Review changes carefully
- Test CPA functionality after merges

---

## 🧪 **Testing Strategy**

### Pre-Sync Testing
```bash
# Test current CPA functionality
npm run test:cpa
npm run test:integration:cpa

# Test core Gemini functionality
npm run test:core
npm run test:cli
```

### Post-Sync Testing
```bash
# Full test suite
npm run test:ci
npm run test:integration:all

# CPA-specific regression tests
npm run test:cpa:regression
```

### Compatibility Matrix
| Upstream Version | CPA Package Version | Compatibility Status |
|------------------|--------------------|--------------------|
| 0.1.5           | 1.0.0              | ✅ Compatible      |
| 0.1.6           | 1.0.1              | 🔄 Testing         |

---

## 🚀 **Contribution Workflow**

### For CPA Features

1. **Create Feature Branch**
```bash
git checkout -b feature/cpa-morning-briefing
```

2. **Develop in CPA Package**
```bash
cd packages/cpa
# Develop new features here
```

3. **Test Thoroughly**
```bash
npm run test:cpa
npm run test:integration
npm run lint:cpa
```

4. **Submit Pull Request**
- Target the `main` branch
- Include CPA-specific tests
- Document any core CLI interactions

### For Bug Fixes

**CPA-Specific Bugs:**
- Fix in `packages/cpa/`
- Submit PR to our fork

**Core CLI Bugs:**
- Report to upstream repository
- Create temporary workaround in CPA package if needed

---

## 📋 **Release Strategy**

### CPA Package Releases
```
packages/cpa/package.json
{
  "name": "@cpa-agent/gemini-cli-cpa",
  "version": "1.0.0",
  "peerDependencies": {
    "@google/gemini-cli": "^0.1.5"
  }
}
```

### Versioning Strategy
- **Major:** Breaking changes to CPA functionality
- **Minor:** New CPA features, compatible upstream sync
- **Patch:** Bug fixes, small improvements

### Release Checklist
- [ ] All tests passing
- [ ] Compatible with current Gemini CLI version
- [ ] Documentation updated
- [ ] Breaking changes documented
- [ ] Migration guide provided (if needed)

---

## 🔒 **Security Considerations**

### Code Review Process
- All CPA code must be reviewed before merge
- Security review for financial data handling
- Upstream changes reviewed for security impact

### Dependency Management
- Keep CPA dependencies minimal
- Audit all CPA-specific dependencies
- Monitor upstream security updates

---

## 📞 **Communication Channels**

### Internal Team
- **GitHub Issues:** For CPA feature requests and bugs
- **Discussions:** For architectural decisions
- **Pull Requests:** For code reviews

### Upstream Relationship
- **Monitor:** Upstream releases and changes
- **Contribute:** Bug fixes and improvements back to upstream
- **Report:** Issues found during CPA development

---

## 🎯 **Success Metrics**

### Fork Health Metrics
- **Sync Frequency:** Monthly upstream syncs maintained
- **Conflict Rate:** <5% of upstream changes cause conflicts
- **Test Coverage:** 90%+ for CPA-specific code
- **Compatibility:** 100% with supported Gemini CLI versions

### Development Efficiency
- **Feature Velocity:** New CPA features delivered regularly
- **Bug Resolution:** CPA bugs resolved within 1 week
- **Documentation:** 100% of CPA features documented

---

## 🚨 **Emergency Procedures**

### Upstream Breaking Changes
1. **Immediate Response:**
   - Stop all CPA development
   - Assess impact on CPA functionality
   - Create compatibility plan

2. **Recovery Actions:**
   - Fix critical CPA functionality
   - Update compatibility matrix
   - Communicate changes to users

### Fork Divergence
If our fork becomes too divergent:
1. **Assess Options:**
   - Major refactor to realign
   - Create independent project
   - Seek upstream collaboration

2. **Decision Criteria:**
   - Development velocity impact
   - Maintenance burden
   - User experience impact

---

This fork strategy ensures we can develop powerful CPA functionality while maintaining compatibility with the excellent Gemini CLI foundation. Our approach prioritizes sustainability and collaboration while delivering specialized accounting workflows.