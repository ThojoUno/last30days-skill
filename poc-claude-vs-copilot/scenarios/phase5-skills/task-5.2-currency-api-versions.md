# Task 5.2: Training Data Currency & API Version Accuracy

## Objective
Test how each tool handles knowledge currency and Azure API version selection.

---

## Training Data Cutoffs (as of January 2026)

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

### Common Issue with AI Code Generation

Both tools can generate Bicep with outdated API versions because:
1. Training data has a cutoff
2. Tools don't always verify API currency
3. Many examples online use old versions

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

### API Versions to Watch

| Resource Type | Outdated | Current (Jan 2026) |
|---------------|----------|-------------------|
| Storage Accounts | 2021-02-01, 2022-09-01 | **2023-05-01** |
| Key Vault | 2021-10-01, 2022-07-01 | **2023-07-01** |
| Virtual Networks | 2021-05-01, 2022-01-01 | **2023-09-01** |
| Private Endpoints | 2021-05-01 | **2023-09-01** |
| App Service | 2021-03-01, 2022-03-01 | **2023-12-01** |
| AKS | 2022-01-01 | **2024-01-01** |

---

## Test Prompts

### Test A: Baseline API Version Check

**Prompt (no guidance):**
```
Create a Bicep module for an Azure Storage Account with blob containers.
```

**Record:** What API version did each tool use?

| Tool | API Version Used | Is Current? |
|------|------------------|-------------|
| Claude Code | | [ ] Yes [ ] No |
| Copilot CLI | | [ ] Yes [ ] No |

---

### Test B: Explicit Currency Request

**Prompt:**
```
Create a Bicep module for an Azure Storage Account.
Use the latest stable API version available.
Check the current Azure documentation if unsure.
```

**Record:** Did the tool search/verify? What version?

| Tool | Searched Docs? | API Version | Is Current? |
|------|----------------|-------------|-------------|
| Claude Code | [ ] Yes [ ] No | | [ ] Yes [ ] No |
| Copilot CLI | [ ] Yes [ ] No | | [ ] Yes [ ] No |

---

### Test C: Knowledge Cutoff Awareness

**Prompt:**
```
What's the latest API version for Microsoft.Storage/storageAccounts?
When was your training data last updated?
```

**Expected:** Tool acknowledges cutoff and offers to search.

| Tool | Acknowledged Cutoff? | Offered to Search? | Correct Answer? |
|------|---------------------|-------------------|-----------------|
| Claude Code | [ ] Yes [ ] No | [ ] Yes [ ] No | [ ] Yes [ ] No |
| Copilot CLI | [ ] Yes [ ] No | [ ] Yes [ ] No | [ ] Yes [ ] No |

---

### Test D: Complex New Feature

Test something released AFTER training cutoff (example: a 2025 Azure feature).

**Prompt:**
```
Create a Bicep module using Azure Deployment Stacks to deploy
a management group hierarchy with deny settings for delete operations.
```

**Note:** Deployment Stacks GA'd in late 2024, some features added in 2025.

| Tool | Knew About Feature? | Used Correct API? | Searched for Info? |
|------|---------------------|-------------------|-------------------|
| Claude Code | [ ] Yes [ ] No | [ ] Yes [ ] No | [ ] Yes [ ] No |
| Copilot CLI | [ ] Yes [ ] No | [ ] Yes [ ] No | [ ] Yes [ ] No |

---

### Test E: Deprecated API Detection

Provide code with old API version, ask for review:

```bicep
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: 'vnet-test'
  location: 'eastus2'
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
  }
}
```

**Prompt:**
```
Review this Bicep code. Are there any issues?
```

**Expected:** Tool should flag the 2020 API version as outdated.

| Tool | Flagged Old API? | Suggested Current Version? |
|------|------------------|---------------------------|
| Claude Code | [ ] Yes [ ] No | [ ] Yes [ ] No |
| Copilot CLI | [ ] Yes [ ] No | [ ] Yes [ ] No |

---

## Mitigation Strategies

### For AGENTS.md (Both Tools)

Add API version requirements:
```markdown
## API Version Policy
- Always use API versions from 2023 or newer
- Before generating Bicep, verify the current API version for each resource type
- Flag any API versions older than 2023-01-01 for review
```

### For Claude Code Skills

Add verification step to skills:
```yaml
---
name: azure-bicep
description: Azure Bicep with current API versions
---
Before generating Bicep:
1. Use WebSearch to verify current API versions for resources being created
2. Never use API versions older than 2023-01-01
3. Prefer Azure Verified Modules which are kept current
```

### For Copilot CLI

Enable Azure Verified Modules search:
```markdown
# .github/copilot-instructions.md
When generating Azure Bicep:
1. First search Azure Verified Modules (AVM) registry
2. If AVM module exists, use it instead of raw resources
3. Verify API versions are 2023+ before completing
```

---

## Scoring Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Default API Currency | 25% | What version without prompting? |
| Search Behavior | 25% | Does it proactively verify? |
| Cutoff Awareness | 20% | Does it know its limitations? |
| Deprecated Detection | 20% | Can it spot old APIs in reviews? |
| Mitigation Response | 10% | Does it improve with guidance? |

---

## Summary Recording

| Metric | Claude Code | Copilot CLI |
|--------|-------------|-------------|
| Training data cutoff | | |
| Default API version behavior | | |
| Proactively searches | [ ] Yes [ ] No | [ ] Yes [ ] No |
| Acknowledges limitations | [ ] Yes [ ] No | [ ] Yes [ ] No |
| Improves with AGENTS.md | [ ] Yes [ ] No | [ ] Yes [ ] No |
| Overall currency score (/5) | | |

**Notes:**
-
