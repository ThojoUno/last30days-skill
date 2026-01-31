// Hub-to-Spoke Peering Module
// Deployed to the hub VNet's resource group to create the reverse peering

targetScope = 'resourceGroup'

@description('Name of the hub VNet')
param hubVnetName string

@description('Resource ID of the spoke VNet')
param spokeVnetId string

@description('Name of the spoke VNet (for peering naming)')
param spokeVnetName string

// Reference existing hub VNet
resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: hubVnetName
}

// Create peering from hub to spoke
resource hubToSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  parent: hubVnet
  name: 'peer-to-${spokeVnetName}'
  properties: {
    remoteVirtualNetwork: {
      id: spokeVnetId
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
  }
}
