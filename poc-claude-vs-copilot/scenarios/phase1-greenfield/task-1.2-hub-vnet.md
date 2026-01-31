# Task 1.2: Hub Virtual Network (Medium)

## Objective
Test complex networking module with multiple interdependent resources.

## Prompt

```
Create a Bicep module for an Azure Hub Virtual Network with full connectivity services:

Requirements:

1. Virtual Network:
   - Address space: 10.0.0.0/16
   - Subnets:
     - AzureFirewallSubnet (/26)
     - AzureBastionSubnet (/26)
     - GatewaySubnet (/27)
     - SharedServicesSubnet (/24)
   - DNS servers parameter (default to Azure-provided)

2. Azure Firewall (Standard SKU):
   - Threat intelligence mode: Alert
   - Create public IP with Standard SKU, static allocation
   - Enable all diagnostic logs

3. Azure Bastion (Standard SKU):
   - Create public IP
   - Enable native client support
   - Enable IP-based connection
   - Enable shareable link

4. VPN Gateway:
   - SKU: VpnGw1 for dev, VpnGw2 for prod
   - Type: RouteBased
   - Generation: Generation2
   - Create public IP
   - Enable BGP with ASN 65515

5. Route Table for SharedServicesSubnet:
   - Default route (0.0.0.0/0) to Azure Firewall private IP
   - Disable BGP route propagation

6. Diagnostic settings for all resources -> Log Analytics

7. Parameters:
   - environment (dev/prod) - affects SKUs
   - location
   - addressSpace (default 10.0.0.0/16)
   - logAnalyticsWorkspaceId
   - tags object

8. Outputs:
   - vnetId
   - firewallPrivateIp (for spoke route tables)
   - firewallPublicIp
   - bastionId
   - gatewayId
   - gatewayPublicIp

Follow Azure Verified Modules patterns where applicable.
Use proper resource dependencies to ensure correct deployment order.
```

## Expected Deliverables
- `main.bicep` - Module file with all resources
- Clear resource dependencies

## Validation Commands

```bash
# Syntax validation
az bicep build --file main.bicep

# What-if (long deployment - Firewall + Gateway take 20-30 min)
az deployment group what-if \
  --resource-group rg-hub-connectivity \
  --template-file main.bicep \
  --parameters environment=dev location=eastus2 logAnalyticsWorkspaceId=/subscriptions/.../...
```

## Scoring Focus
- **Accuracy**: Subnet sizing, correct SKU per environment, proper dependencies
- **Completeness**: All 5 major resources + route table + diagnostics
- **Best Practices**: Firewall as next hop, BGP configuration, dependency chain
