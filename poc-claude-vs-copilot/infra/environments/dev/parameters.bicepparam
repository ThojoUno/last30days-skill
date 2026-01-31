// Development Environment Parameters
// Used as a template for POC tasks

using '../../../modules/starter/spoke-vnet/main.bicep'

param environment = 'dev'
param location = 'eastus2'
param addressPrefix = '10.1.0.0/16'
param workloadSubnetPrefix = '10.1.1.0/24'
param privateEndpointSubnetPrefix = '10.1.2.0/24'

// Replace with actual values from your hub deployment
param hubVnetId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-connectivity/providers/Microsoft.Network/virtualNetworks/vnet-hub-eastus2'
param hubVnetName = 'vnet-hub-eastus2'
param hubVnetResourceGroup = 'rg-hub-connectivity'
param firewallPrivateIp = '10.0.1.4'
param useRemoteGateway = false // No gateway in dev

param tags = {
  environment: 'dev'
  owner: 'platform-team'
  costCenter: 'IT-001'
  project: 'alz-poc'
}
