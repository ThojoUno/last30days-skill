# Task 1.3: ALZ Management Group Hierarchy (Hard)

## Objective
Test enterprise-scale architecture understanding and policy-as-code capabilities.

## Prompt

```
Create Bicep templates for an Azure Landing Zone management group hierarchy with policy assignments:

Requirements:

1. Management Group Hierarchy (following ALZ reference architecture):
   ```
   Tenant Root Group
   └── Contoso (intermediate root)
       ├── Platform
       │   ├── Management
       │   ├── Connectivity
       │   └── Identity
       ├── Landing Zones
       │   ├── Corp (corporate connected)
       │   └── Online (internet facing)
       ├── Sandbox
       └── Decommissioned
   ```

2. Custom Policy Definitions (at Contoso MG level):
   a. "Require TLS 1.2 for Storage Accounts"
      - Deny storage accounts without minimumTlsVersion = TLS1_2

   b. "Require private endpoints for PaaS"
      - Audit resources that support private endpoints but don't have one
      - Target: Storage, Key Vault, SQL, Cosmos DB

   c. "Allowed VM SKUs"
      - Restrict to specified VM SKU list (parameterized)

3. Policy Assignments:
   - Assign "Require TLS 1.2" to Landing Zones MG (Deny mode)
   - Assign "Require private endpoints" to Corp MG (Audit mode)
   - Assign "Allowed VM SKUs" to Sandbox MG (Deny mode, limited SKUs)
   - Assign built-in "Allowed Locations" to Contoso MG (eastus, eastus2, westus2)

4. RBAC Assignments (at Contoso MG level):
   - Platform Admins group -> Owner on Platform MG
   - Landing Zone Contributors group -> Contributor on Landing Zones MG
   - Security Readers group -> Security Reader on Contoso MG
   (Use parameter for group object IDs)

5. Structure as:
   - managementGroups.bicep - Hierarchy creation
   - policyDefinitions.bicep - Custom policies
   - policyAssignments.bicep - Policy assignments
   - roleAssignments.bicep - RBAC assignments
   - main.bicep - Orchestrator that deploys all at subscription/tenant scope

6. Parameters:
   - prefix (for MG naming, e.g., "contoso")
   - allowedLocations array
   - allowedVmSkus array
   - platformAdminsGroupId
   - lzContributorsGroupId
   - securityReadersGroupId

7. Outputs:
   - Management group IDs for all created MGs
   - Policy definition IDs
   - Policy assignment IDs

Deploy at tenant scope using targetScope = 'tenant' where appropriate.
Handle the management group hierarchy dependencies correctly.
```

## Expected Deliverables
- `managementGroups.bicep`
- `policyDefinitions.bicep`
- `policyAssignments.bicep`
- `roleAssignments.bicep`
- `main.bicep` (orchestrator)

## Validation Commands

```bash
# Syntax validation for all files
az bicep build --file main.bicep
az bicep build --file managementGroups.bicep

# What-if at tenant scope (requires elevated permissions)
az deployment tenant what-if \
  --location eastus2 \
  --template-file main.bicep \
  --parameters prefix=contoso allowedLocations='["eastus","eastus2"]' ...
```

## Scoring Focus
- **Accuracy**: Correct scope targeting (tenant vs managementGroup), valid policy rules
- **Completeness**: Full hierarchy, all 3 custom policies, correct assignments
- **Best Practices**: Proper MG parent/child dependencies, policy definition before assignment
- **Complexity Handling**: Multi-file orchestration, cross-resource references
