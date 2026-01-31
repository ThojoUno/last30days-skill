# Evaluation Criteria & Scoring Rubric

## Scoring Scale

Each criterion is scored 1-5:

| Score | Meaning |
|-------|---------|
| 1 | Failed / Major issues / Unusable |
| 2 | Poor / Multiple significant issues |
| 3 | Acceptable / Works with notable gaps |
| 4 | Good / Minor issues only |
| 5 | Excellent / Production-ready |

---

## Criteria Definitions

### 1. Accuracy (Weight: 25%)

Does the generated code deploy successfully and follow Azure best practices?

| Score | Definition |
|-------|------------|
| 5 | Deploys first try, follows all Azure best practices, no anti-patterns |
| 4 | Deploys with minor warnings, follows most best practices |
| 3 | Deploys after 1-2 small fixes, some best practices missed |
| 2 | Requires significant fixes, multiple anti-patterns |
| 1 | Does not deploy, fundamentally incorrect approach |

**Check for:**
- Valid Bicep syntax
- Correct API versions (not deprecated)
- Proper resource dependencies
- No hardcoded secrets
- Appropriate SKU/tier selections
- Correct networking (subnets, NSGs, private endpoints)

---

### 2. Completeness (Weight: 20%)

Are all requested components included with appropriate configuration?

| Score | Definition |
|-------|------------|
| 5 | All requirements met, plus sensible additions (diagnostics, tags) |
| 4 | All explicit requirements met |
| 3 | Most requirements met, 1-2 minor omissions |
| 2 | Multiple requirements missing |
| 1 | Majority of requirements missing |

**Check for:**
- All resources requested
- RBAC assignments if needed
- Diagnostic settings
- Tagging strategy
- Outputs for downstream consumption
- Parameter validation (allowed values, min/max)

---

### 3. Speed (Weight: 15%)

Time from prompt submission to working, deployable code.

| Score | Definition |
|-------|------------|
| 5 | < 2 minutes to working code |
| 4 | 2-5 minutes to working code |
| 3 | 5-10 minutes to working code |
| 2 | 10-20 minutes to working code |
| 1 | > 20 minutes or never achieved working code |

**Note:** Include iteration time. Clock stops when `az deployment what-if` succeeds.

---

### 4. Iteration Efficiency (Weight: 15%)

How many follow-up prompts/corrections needed to reach working solution?

| Score | Definition |
|-------|------------|
| 5 | Works first try, no iterations needed |
| 4 | 1 iteration (minor clarification or fix) |
| 3 | 2-3 iterations |
| 2 | 4-5 iterations |
| 1 | 6+ iterations or never converged |

**Track:**
- Number of follow-up prompts
- Whether tool self-corrected after seeing errors
- Quality of error interpretation

---

### 5. Context Understanding (Weight: 15%)

Does the tool understand existing code, project structure, and conventions?

| Score | Definition |
|-------|------------|
| 5 | Perfectly understands existing patterns, extends consistently |
| 4 | Good understanding, minor style inconsistencies |
| 3 | Understands basics, some inconsistent patterns |
| 2 | Poor understanding, ignores existing conventions |
| 1 | Does not read/understand existing code |

**Relevant for Phase 2 & 3. Check:**
- Matches existing naming conventions
- Uses existing shared modules/types
- Understands variable/parameter patterns
- Recognizes project structure

---

### 6. Explanation Quality (Weight: 10%)

Can the tool explain what it built and why decisions were made?

| Score | Definition |
|-------|------------|
| 5 | Clear explanation of architecture, trade-offs, and alternatives |
| 4 | Good explanation of what was built and key decisions |
| 3 | Basic explanation, lacks depth |
| 2 | Minimal or confusing explanation |
| 1 | No explanation or incorrect explanation |

**Ask each tool:** "Explain the architecture and any trade-offs in your solution"

---

## Weighted Score Calculation

```
Final Score = (Accuracy × 0.25) + (Completeness × 0.20) + (Speed × 0.15)
            + (Iteration × 0.15) + (Context × 0.15) + (Explanation × 0.10)
```

Maximum possible: 5.0

---

## Additional Observations to Record

Beyond scoring, note these qualitative factors:

### Positive Patterns
- [ ] Proactively added security controls not requested
- [ ] Suggested improvements or alternatives
- [ ] Correctly handled Azure-specific nuances (resource naming limits, region availability)
- [ ] Generated reusable, modular code
- [ ] Included helpful comments

### Negative Patterns
- [ ] Hallucinated non-existent Bicep functions or properties
- [ ] Used deprecated API versions
- [ ] Hardcoded values that should be parameters
- [ ] Ignored Azure naming conventions
- [ ] Generated overly complex solutions
- [ ] Failed to read existing code when asked

### Tool-Specific Behaviors
- [ ] Did the tool run validation commands automatically?
- [ ] Did the tool offer to deploy or just generate code?
- [ ] How did it handle errors from Azure CLI?
- [ ] Did it suggest using Azure Verified Modules?

---

## Scorecard Template

Copy this for each task:

```markdown
## Task [X.X]: [Task Name]

**Date:** YYYY-MM-DD
**Tester:** [Name]

### Claude Code

| Criterion | Score (1-5) | Notes |
|-----------|-------------|-------|
| Accuracy | | |
| Completeness | | |
| Speed | | |
| Iteration Efficiency | | |
| Context Understanding | | |
| Explanation Quality | | |
| **Weighted Total** | | |

**Time to working code:** X min
**Iterations required:** X
**Notable observations:**
-

### GitHub Copilot CLI

| Criterion | Score (1-5) | Notes |
|-----------|-------------|-------|
| Accuracy | | |
| Completeness | | |
| Speed | | |
| Iteration Efficiency | | |
| Context Understanding | | |
| Explanation Quality | | |
| **Weighted Total** | | |

**Time to working code:** X min
**Iterations required:** X
**Notable observations:**
-

### Task Winner: [Claude Code / Copilot CLI / Tie]
```
