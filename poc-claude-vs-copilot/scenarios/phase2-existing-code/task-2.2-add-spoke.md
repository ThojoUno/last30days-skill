# Task 2.2: Add New Spoke to Existing ALZ (Medium)

## Objective
Test the tool's ability to extend existing infrastructure following established patterns.

## Setup
Ensure the tool has access to:
- `modules/starter/spoke-vnet/` - Existing spoke module
- `infra/environments/` - Existing parameter files

## Prompt

```
I have an existing Azure Landing Zone with hub-spoke networking.
Look at the existing spoke VNet module in modules/starter/spoke-vnet/.

Create a new spoke for a "payments" workload that:

1. Uses the existing spoke-vnet module as a base
2. Address space: 10.5.0.0/16
3. Additional subnets needed:
   - Application Gateway subnet (/24) with proper NSG rules for App Gateway
   - AKS subnet (/22) for Kubernetes workloads
   - Database subnet (/24) for Azure SQL private endpoints

4. Additional security requirements:
   - Service endpoints for Microsoft.Sql on database subnet
   - Private endpoint policies disabled on database subnet
   - More restrictive NSG rules for database subnet (only allow from AKS subnet)

5. Create the deployment files:
   - infra/environments/dev/payments-spoke.bicepparam
   - infra/environments/prod/payments-spoke.bicepparam

Follow the existing naming conventions and patterns from the starter module.
Reuse the hub-peering submodule for the reverse peering.
```

## Expected Deliverables
- New Bicep module or extended parameters using existing module
- Dev and prod parameter files
- Additional subnet and NSG configurations

## Scoring Focus
- **Context Understanding**: Does it follow existing patterns?
- **Completeness**: All subnets, NSGs, service endpoints configured?
- **Best Practices**: App Gateway subnet requirements, AKS sizing, SQL private endpoints
