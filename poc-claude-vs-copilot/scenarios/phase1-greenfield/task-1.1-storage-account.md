# Task 1.1: Storage Account Module (Easy)

## Objective
Test basic Bicep module generation with security best practices.

## Prompt

```
Create a Bicep module for an Azure Storage Account with enterprise security:

Requirements:
1. Storage Account with:
   - Hierarchical namespace enabled (Data Lake Gen2)
   - TLS 1.2 minimum
   - HTTPS only
   - Blob soft delete (30 days)
   - Container soft delete (30 days)

2. Private Endpoint for blob service:
   - Integrate with provided subnet ID parameter
   - Create private DNS zone group

3. Customer-Managed Key encryption:
   - Use provided Key Vault and key name parameters
   - Create user-assigned managed identity for CMK access

4. Diagnostic settings:
   - Send all logs and metrics to Log Analytics workspace

5. Parameters for:
   - environment (dev/prod)
   - location
   - subnetId (for private endpoint)
   - keyVaultId and keyName (for CMK)
   - logAnalyticsWorkspaceId

6. Tags: environment, owner, costCenter (as parameters)

7. Outputs:
   - storageAccountId
   - storageAccountName
   - primaryBlobEndpoint
   - managedIdentityPrincipalId

Use standard Azure naming conventions (st<app><env><region><instance>).
```

## Expected Deliverables
- `main.bicep` - Module file
- `main.bicepparam` or sample parameter values

## Validation Commands

```bash
# Syntax validation
az bicep build --file main.bicep

# What-if deployment (requires actual parameter values)
az deployment group what-if \
  --resource-group <rg-name> \
  --template-file main.bicep \
  --parameters environment=dev location=eastus2 ...
```

## Scoring Focus
- **Accuracy**: Correct CMK setup, private endpoint configuration
- **Completeness**: All 7 requirements addressed
- **Best Practices**: Proper identity handling for CMK, DNS zone linking
