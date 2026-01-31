# Task 3.2: Private DNS Resolution Not Working (Medium)

## Objective
Test networking debugging skills and understanding of Azure Private DNS.

## Setup
The broken configuration is in `modules/starter/broken/private-endpoint-broken.bicep`

## The Problem
Users report:
- Private endpoint was created successfully
- Storage account shows private endpoint connection as "Approved"
- But applications in the spoke VNet cannot resolve `stcontoso.blob.core.windows.net` to the private IP
- They still get the public IP when doing nslookup

## Prompt

```
We deployed a storage account with a private endpoint, but DNS resolution isn't working.

When running nslookup from a VM in the spoke VNet:
$ nslookup stcontoso.blob.core.windows.net
Returns: 52.x.x.x (public IP)

Expected: 10.1.2.x (private endpoint IP)

The private endpoint shows as connected and approved.

Look at modules/starter/broken/private-endpoint-broken.bicep and identify:
1. What's missing or misconfigured
2. Why DNS resolution fails despite the private endpoint working
3. Fix the issue and explain the correct Private DNS Zone configuration for hub-spoke

Consider that we have:
- Hub VNet in hub resource group
- Spoke VNet peered to hub
- VMs in spoke trying to reach the storage account
```

## Root Causes (Multiple Issues)
1. Private DNS Zone exists but not linked to spoke VNet
2. Private DNS Zone Group not created (or misconfigured)
3. VNet DNS settings might be pointing to custom DNS without forwarder

## Expected Fix
- Link Private DNS Zone to both hub and spoke VNets
- Create proper privateDnsZoneGroup in the private endpoint
- Ensure VNet uses Azure DNS or has proper forwarding

## Scoring Focus
- **Accuracy**: Identifies all DNS-related issues
- **Context Understanding**: Understands hub-spoke DNS patterns
- **Explanation Quality**: Clear explanation of Private DNS Zone flow
