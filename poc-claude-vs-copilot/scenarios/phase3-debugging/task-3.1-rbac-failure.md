# Task 3.1: Fix RBAC Deployment Failure (Easy)

## Objective
Test basic debugging and error interpretation skills.

## Setup
The broken module is in `modules/starter/broken/key-vault-broken.bicep`

## The Problem
Deployment fails with:
```
"code": "RoleAssignmentUpdateNotPermitted"
"message": "Tenant ID, application ID, principal ID, and scope are not allowed to be updated."
```

## Prompt

```
My Key Vault deployment is failing with a role assignment error.
The error message is:
"Tenant ID, application ID, principal ID, and scope are not allowed to be updated."

Look at modules/starter/broken/key-vault-broken.bicep and fix the issue.

Explain:
1. What's causing the error
2. Why this pattern causes problems
3. The correct way to handle role assignment naming in Bicep
```

## Root Cause
The role assignment uses a non-deterministic name (`guid(resourceGroup().id)`), causing Azure to try to "update" an existing assignment with a different principal, which is not allowed.

## Expected Fix
Use a deterministic GUID based on principal ID + role definition + scope:
```bicep
name: guid(keyVault.id, managedIdentity.id, roleDefinitionId)
```

## Scoring Focus
- **Accuracy**: Correctly identifies the naming issue
- **Explanation Quality**: Explains why role assignments need deterministic names
- **Best Practices**: Shows the correct pattern
