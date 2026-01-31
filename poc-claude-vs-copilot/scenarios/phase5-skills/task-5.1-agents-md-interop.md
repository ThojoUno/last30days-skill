# Task 5.1: Skills & AGENTS.md Interoperability Test

## Objective
Test how each tool handles custom instructions files and skills for Azure IaC work.

---

## Background: File Support Matrix

| File | Claude Code | Copilot CLI |
|------|-------------|-------------|
| `CLAUDE.md` | ✅ Native (auto-loaded) | ✅ Supported (Jan 2026) |
| `AGENTS.md` | ✅ Supported | ✅ Native (auto-loaded) |
| `.github/copilot-instructions.md` | ❌ Not read | ✅ Native |
| `SKILL.md` folders | ✅ Native skills system | ⚠️ Via `.github/agents/*.agent.md` |
| Custom agents | ✅ `~/.claude/agents/` | ✅ `.github/agents/` |

---

## Test Setup

### 1. Create AGENTS.md (works in both tools)

Create `AGENTS.md` in repo root with Azure-specific instructions:

```markdown
# Azure Landing Zone Development Guidelines

## Architecture Standards
- All resources must use Azure Verified Modules (AVM) patterns when available
- Private endpoints required for all PaaS services
- All subnets must have NSGs attached (except AzureFirewallSubnet, GatewaySubnet)
- Use user-assigned managed identities over system-assigned when cross-resource access needed

## Bicep Standards
- Use `targetScope` declaration on every file
- All parameters must have `@description` decorators
- Use user-defined types for complex objects
- API versions must be 2023-01-01 or newer
- Never hardcode subscription IDs, tenant IDs, or resource IDs

## Naming Convention
Format: `{resourceType}-{workload}-{environment}-{region}-{instance}`
Examples:
- `vnet-hub-prod-eastus2-001`
- `st-data-dev-eus2-001` (storage accounts: 24 char limit, no hyphens)

## Testing Requirements
- Run `az bicep build` before committing
- All modules must have example parameter files
- Document all outputs with `@description`
```

### 2. Create Azure Bicep Skill (Claude Code)

Create `~/.claude/skills/azure-bicep/SKILL.md`:

```yaml
---
name: azure-bicep
description: Azure Bicep IaC development with ALZ patterns
argument-hint: "[task description]"
---

# Azure Bicep Development Skill

You are an Azure infrastructure expert specializing in:
- Azure Landing Zones (ALZ) reference architecture
- Hub-spoke networking with Azure Firewall
- Policy-as-code with Azure Policy
- Identity and access management with Entra ID

## When generating Bicep:
1. Always check Azure Verified Modules registry first
2. Use `@secure()` for sensitive parameters
3. Include diagnostic settings on all supported resources
4. Add resource locks for production resources
5. Output resource IDs for downstream module consumption

## Validation checklist:
- [ ] No deprecated API versions
- [ ] All secrets from Key Vault, never hardcoded
- [ ] Private endpoints for storage, SQL, Key Vault
- [ ] Tags applied consistently
```

### 3. Create Copilot Agent (Copilot CLI equivalent)

Create `.github/agents/azure-bicep.agent.md`:

```markdown
---
name: azure-bicep
description: Azure Bicep IaC development with ALZ patterns
tools:
  - Bash
  - Read
  - Write
---

# Azure Bicep Development Agent

[Same content as Claude skill above]
```

---

## Test Prompts

### Test A: Verify AGENTS.md Loading

```
What naming convention should I use for Azure resources in this project?
```

**Expected:** Both tools should cite the naming convention from AGENTS.md without you having to point them to it.

### Test B: Skill/Agent Invocation

**Claude Code:**
```
/azure-bicep Create a Key Vault module with private endpoint and RBAC
```

**Copilot CLI:**
```
@azure-bicep Create a Key Vault module with private endpoint and RBAC
```

**Expected:** Both should generate code following the skill/agent guidelines.

### Test C: Conflicting Instructions

Add to `AGENTS.md`:
```
Use Standard_LRS for all storage accounts
```

Add to skill/agent:
```
Use Standard_GRS for storage accounts in production
```

Then prompt:
```
Create a production storage account module
```

**Expected:** Observe which instruction takes precedence.

---

## Scoring Criteria (Specific to This Test)

| Criterion | What to Measure |
|-----------|-----------------|
| Auto-loading | Did it read AGENTS.md without being told? |
| Skill invocation | Did the explicit skill/agent call work? |
| Instruction adherence | Did generated code follow the guidelines? |
| Conflict resolution | Which source won? Was it consistent? |
| Cross-tool portability | Same AGENTS.md, same behavior? |

---

## Special Considerations for Copilot CLI

### Getting Copilot CLI to Use Claude Code Skills

Copilot CLI **cannot directly use** Claude Code's `SKILL.md` format. You must:

1. **Convert SKILL.md to agent.md format:**
   ```bash
   # Claude Code skill location
   ~/.claude/skills/azure-bicep/SKILL.md

   # Copilot CLI equivalent
   .github/agents/azure-bicep.agent.md
   ```

2. **Key differences in format:**
   - Claude: YAML frontmatter with `argument-hint`
   - Copilot: YAML frontmatter with `tools` array

3. **Tool permissions differ:**
   - Claude: `allowed-tools: [Bash, Read, Write]`
   - Copilot: `tools: [Bash, Read, Write]`

4. **Invocation syntax differs:**
   - Claude: `/skillname prompt` or natural language
   - Copilot: `@agentname prompt`

### Shared AGENTS.md Strategy

For teams using both tools, use `AGENTS.md` as the source of truth:
- Both tools read it automatically
- No conversion needed
- Single file to maintain
- Works in IDE extensions too (VS Code, JetBrains)

---

## How AGENTS.md Improves Accuracy

### Token Efficiency
- AGENTS.md loads into **every** conversation (always-on context)
- Skills/agents load **only when invoked** (on-demand context)
- For universal rules (naming, security), use AGENTS.md
- For specialized tasks (AKS deployment, Policy authoring), use skills

### Accuracy Improvements Observed

| Without AGENTS.md | With AGENTS.md |
|-------------------|----------------|
| Generic Azure naming | Consistent org naming convention |
| Public endpoints by default | Private endpoints enforced |
| Inconsistent API versions | Standardized to 2023+ |
| Missing diagnostic settings | Always included |
| Hardcoded values | Parameterized per guidelines |

### Best Practice: Layered Instructions

```
AGENTS.md (always loaded)
└── Universal rules: naming, security baseline, tagging

Skills/Agents (loaded on demand)
└── Specialized expertise: AKS, Firewall policies, ALZ hierarchy
```

---

## Recording Results

| Behavior | Claude Code | Copilot CLI |
|----------|-------------|-------------|
| Read AGENTS.md automatically | [ ] Yes [ ] No | [ ] Yes [ ] No |
| Followed naming convention | [ ] Yes [ ] No | [ ] Yes [ ] No |
| Skill/agent invocation worked | [ ] Yes [ ] No | [ ] Yes [ ] No |
| Generated code met guidelines | [ ] Yes [ ] No | [ ] Yes [ ] No |
| Conflict resolution (which won) | __________ | __________ |

**Notes:**
-
