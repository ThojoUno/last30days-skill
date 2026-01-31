# Azure Landing Zone Development Guidelines

> This file is automatically loaded by both Claude Code and GitHub Copilot CLI.
> It provides universal instructions for Azure IaC development in this repository.

## Architecture Standards

- All resources must use [Azure Verified Modules (AVM)](https://aka.ms/avm) patterns when available
- Private endpoints required for all PaaS services (Storage, Key Vault, SQL, Cosmos DB)
- All subnets must have NSGs attached (except AzureFirewallSubnet, GatewaySubnet, AzureBastionSubnet)
- Use user-assigned managed identities over system-assigned when cross-resource access is needed
- Enable diagnostic settings on all resources that support them

## Bicep Coding Standards

- Use `targetScope` declaration on every file
- All parameters must have `@description()` decorators
- Use `@allowed()` for parameters with finite valid values
- Use `@minLength()` / `@maxLength()` for string parameters where applicable
- Use user-defined types for complex parameter objects
- API versions must be 2023-01-01 or newer (no deprecated APIs)
- Never hardcode subscription IDs, tenant IDs, or resource IDs - use parameters

## Naming Convention

**Format:** `{resourceType}-{workload}-{environment}-{region}-{instance}`

| Resource Type | Abbreviation | Example |
|---------------|--------------|---------|
| Resource Group | rg | `rg-hub-prod-eastus2-001` |
| Virtual Network | vnet | `vnet-hub-prod-eastus2-001` |
| Subnet | snet | `snet-workload-prod-eastus2-001` |
| Network Security Group | nsg | `nsg-workload-prod-eastus2-001` |
| Route Table | rt | `rt-spoke-prod-eastus2-001` |
| Public IP | pip | `pip-fw-prod-eastus2-001` |
| Azure Firewall | fw | `fw-hub-prod-eastus2-001` |
| Azure Bastion | bas | `bas-hub-prod-eastus2-001` |
| VPN Gateway | vgw | `vgw-hub-prod-eastus2-001` |
| Storage Account | st | `stlogsproeus2001` (24 char limit, no hyphens) |
| Key Vault | kv | `kv-app-prod-eus2-001` (24 char limit) |
| App Service | app | `app-api-prod-eastus2-001` |
| Log Analytics | law | `law-central-prod-eastus2-001` |

**Environment codes:** dev, test, staging, prod
**Region codes:** eastus2, westus2, northeurope, etc.

## Security Requirements

- TLS 1.2 minimum for all services
- HTTPS only for storage accounts
- RBAC authorization for Key Vault (not access policies)
- Customer-managed keys (CMK) for production storage accounts
- Soft delete enabled for Key Vault and Storage (30+ days)
- No public network access for PaaS in production

## Testing Requirements

Before committing:
1. Run `az bicep build --file <module>.bicep` to validate syntax
2. Run `az bicep lint --file <module>.bicep` for best practice warnings
3. Provide example `.bicepparam` files for all modules
4. Document all outputs with `@description()`

## Deployment Patterns

- Use What-If before production deployments
- Tag all resources with: `environment`, `owner`, `costCenter`, `project`
- Use deployment stacks for management group level deployments
- Enable deployment history cleanup (keep last 10)

## File Organization

```
infra/
├── modules/           # Reusable Bicep modules
├── environments/
│   ├── dev/          # Dev parameter files
│   └── prod/         # Prod parameter files
└── shared/           # Shared types and variables
```
