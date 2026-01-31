# Training Data Currency Analysis: Claude Code vs GitHub Copilot CLI

> Last updated: January 2026

## Training Data Cutoffs

| Tool | Model | Training Cutoff | Reliable Knowledge |
|------|-------|-----------------|-------------------|
| **Claude Code** | Opus 4.5 | August 2025 | March 2025 |
| **Claude Code** | Sonnet 4 | May 2025 | March 2025 |
| **Copilot CLI** | GPT-4.1 Codex | ~August 2025 | March 2025 |
| **Copilot CLI** | GPT-5.2 (preview) | ~October 2025 | June 2025 |

### What This Means for Azure IaC

Training data from March-August 2025 means:
- ✅ Knows about Azure API versions up to `2024-01-01` reliably
- ⚠️ May not know `2025-xx-xx` API versions without web search
- ⚠️ May suggest deprecated APIs if not prompted carefully
- ❌ Won't know about features released after cutoff (without tools)

---

## How Each Tool Stays Current

### Claude Code

| Mechanism | Description |
|-----------|-------------|
| **WebSearch tool** | Real-time web search via Brave Search API |
| **WebFetch tool** | Fetches specific URLs (docs, release notes) |
| **MCP servers** | Can connect to Azure MCP for live resource info |
| **User context** | Reads AGENTS.md, CLAUDE.md for project rules |

**Strengths:**
- Proactively uses WebSearch when detecting knowledge gaps
- Can fetch Azure REST API specs directly
- MCP integration for live Azure queries

**Weaknesses:**
- Web search adds latency
- Brave Search ≠ Google (may miss some docs)
- Requires explicit prompting for very new APIs

### GitHub Copilot CLI

| Mechanism | Description |
|-----------|-------------|
| **Azure MCP server** | Official Microsoft MCP for Azure |
| **Bing Search** | Enterprise search integration |
| **Azure Verified Modules tool** | Searches AVM registry for latest modules |
| **GitHub context** | Reads .github/copilot-instructions.md |

**Strengths:**
- Native Azure MCP server from Microsoft
- AVM search tool finds latest verified modules
- Bing integration (better Microsoft docs coverage)

**Weaknesses:**
- Known to suggest deprecated API versions from training
- Less proactive about searching (must be prompted)
- AVM tool is relatively new (may have gaps)

---

## The Deprecated API Problem

### Why It Happens

Both tools can generate Bicep with outdated API versions because:
1. Training data has a cutoff date
2. Tools don't always verify API currency automatically
3. Many code examples online use old versions

### Example of the Problem

**Prompt:** "Create a storage account with private endpoint"

**Bad output (from stale training):**
```bicep
resource storage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  // 2021 API - missing many current features
}
```

**Good output (current):**
```bicep
resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  // 2023+ API - has all current features
}
```

### Current API Versions (January 2026)

| Resource Type | Outdated Versions | Current Version |
|---------------|-------------------|-----------------|
| Storage Accounts | 2021-02-01, 2022-09-01 | **2023-05-01** |
| Key Vault | 2021-10-01, 2022-07-01 | **2023-07-01** |
| Virtual Networks | 2021-05-01, 2022-01-01 | **2023-09-01** |
| Private Endpoints | 2021-05-01 | **2023-09-01** |
| App Service | 2021-03-01, 2022-03-01 | **2023-12-01** |
| AKS | 2022-01-01 | **2024-01-01** |
| Azure Firewall | 2022-01-01 | **2023-09-01** |
| Bastion | 2022-01-01 | **2023-09-01** |

---

## Comparison Matrix

| Aspect | Claude Code | Copilot CLI |
|--------|-------------|-------------|
| **Training cutoff** | Aug 2025 | Aug-Oct 2025 |
| **Default behavior** | Often searches proactively | Usually uses training data |
| **Azure docs coverage** | Brave (less MS-specific) | Bing (better MS docs) |
| **AVM awareness** | Must be prompted | Has dedicated search tool |
| **Self-correction** | Acknowledges cutoff readily | Less transparent |
| **MCP for Azure** | Community/3rd party | Official Microsoft |

---

## Mitigation Strategies

### 1. AGENTS.md (Works in Both Tools)

Add API version requirements to your repo:

```markdown
## API Version Policy

- Always use API versions from 2023 or newer
- Before generating Bicep, verify the current API version for each resource type
- Flag any API versions older than 2023-01-01 for review
- Prefer Azure Verified Modules (AVM) which are kept current

## Current Minimum API Versions

| Resource | Minimum Version |
|----------|-----------------|
| Microsoft.Storage/storageAccounts | 2023-05-01 |
| Microsoft.KeyVault/vaults | 2023-07-01 |
| Microsoft.Network/virtualNetworks | 2023-09-01 |
| Microsoft.Network/privateEndpoints | 2023-09-01 |
| Microsoft.Web/sites | 2023-12-01 |
```

### 2. Claude Code Skills

Add verification step to custom skills:

```yaml
---
name: azure-bicep
description: Azure Bicep with current API versions
---

Before generating Bicep:
1. Use WebSearch to verify current API versions for resources being created
2. Never use API versions older than 2023-01-01
3. Prefer Azure Verified Modules which are kept current
4. If unsure about an API version, search Azure REST API docs
```

### 3. Copilot CLI Instructions

Enable Azure Verified Modules search:

```markdown
# .github/copilot-instructions.md

When generating Azure Bicep:
1. First search Azure Verified Modules (AVM) registry
2. If AVM module exists, use it instead of raw resources
3. Verify API versions are 2023+ before completing
4. Use the Azure MCP server to check resource capabilities
```

### 4. Prompt Engineering

Always include currency requirements in prompts:

```
Create a Bicep module for an Azure Storage Account.
- Use the latest stable API version (2023 or newer)
- Check Azure documentation if unsure about current API version
- Include all current features for enterprise security
```

---

## Recommendations

### For Azure Landing Zone Projects

1. **Add API version rules to AGENTS.md** - both tools read it automatically
2. **Always prompt for "latest API version"** - triggers verification behavior
3. **Use Azure Verified Modules** - Copilot has edge here with built-in AVM search
4. **Review generated code** - check API versions in PR review process
5. **Enable MCP servers** - both tools support Azure MCP for live queries

### Tool Selection by Use Case

| Use Case | Better Tool | Reason |
|----------|-------------|--------|
| Quick Bicep generation | Copilot CLI | AVM search tool |
| Complex multi-file refactoring | Claude Code | Better context handling |
| Verifying latest features | Claude Code | More proactive searching |
| Microsoft-specific docs | Copilot CLI | Bing integration |
| Custom workflow automation | Either | Both support agents/skills |

---

## Sources

- [Claude training data cutoffs](https://support.claude.com/en/articles/8114494-how-up-to-date-is-claude-s-training-data)
- [LLM knowledge cutoff dates repository](https://github.com/HaoooWang/llm-knowledge-cutoff-dates)
- [Copilot GPT-4.1 announcement (Aug 2025)](https://github.blog/changelog/2025-08-27-copilot-code-completion-now-uses-the-gpt-4-1-copilot-model/)
- [Copilot December 2025 roundup](https://github.com/orgs/community/discussions/183537)
- [Bicep Copilot extension for current APIs](https://github.com/aymenfurter/bicep-copilot)
- [Keeping Bicep up-to-date with Copilot Agents](https://danielscottraynsford.com/blog/keeping-azure-bicep-up-to-date-the-easy-way-with-github-copilot-agents/)
- [Azure Bicep API version discussions](https://github.com/Azure/bicep/discussions/10306)
