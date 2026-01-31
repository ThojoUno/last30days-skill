// Spoke VNet Module - For POC Evaluation
// This module creates a spoke VNet with peering to a hub

targetScope = 'resourceGroup'

@description('Environment name')
@allowed(['dev', 'prod'])
param environment string

@description('Azure region for deployment')
param location string = resourceGroup().location

@description('Spoke VNet address space')
param addressPrefix string = '10.1.0.0/16'

@description('Workload subnet address prefix')
param workloadSubnetPrefix string = '10.1.1.0/24'

@description('Private endpoints subnet address prefix')
param privateEndpointSubnetPrefix string = '10.1.2.0/24'

@description('Hub VNet resource ID for peering')
param hubVnetId string

@description('Hub VNet name (for peering resource naming)')
param hubVnetName string

@description('Hub VNet resource group (for reverse peering)')
param hubVnetResourceGroup string

@description('Azure Firewall private IP for route table')
param firewallPrivateIp string

@description('Enable gateway transit from hub')
param useRemoteGateway bool = true

@description('Tags to apply to all resources')
param tags object = {}

var spokeVnetName = 'vnet-spoke-${environment}-${location}'
var workloadSubnetName = 'snet-workload'
var privateEndpointSubnetName = 'snet-privateendpoints'
var routeTableName = 'rt-spoke-${environment}'
var nsgName = 'nsg-workload-${environment}'

// Network Security Group for workload subnet
resource workloadNsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          priority: 4096
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

// Route table to force traffic through hub firewall
resource routeTable 'Microsoft.Network/routeTables@2023-09-01' = {
  name: routeTableName
  location: location
  tags: tags
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'default-to-firewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIp
        }
      }
      {
        name: 'hub-to-firewall'
        properties: {
          addressPrefix: '10.0.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIp
        }
      }
    ]
  }
}

// Spoke Virtual Network
resource spokeVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: spokeVnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: workloadSubnetName
        properties: {
          addressPrefix: workloadSubnetPrefix
          networkSecurityGroup: {
            id: workloadNsg.id
          }
          routeTable: {
            id: routeTable.id
          }
        }
      }
      {
        name: privateEndpointSubnetName
        properties: {
          addressPrefix: privateEndpointSubnetPrefix
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

// Peering from spoke to hub
resource spokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  parent: spokeVnet
  name: 'peer-to-${hubVnetName}'
  properties: {
    remoteVirtualNetwork: {
      id: hubVnetId
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: useRemoteGateway
  }
}

// Peering from hub to spoke (deployed to hub resource group)
module hubToSpokePeering 'hub-peering.bicep' = {
  name: 'hubToSpokePeering-${uniqueString(spokeVnet.id)}'
  scope: resourceGroup(hubVnetResourceGroup)
  params: {
    hubVnetName: hubVnetName
    spokeVnetId: spokeVnet.id
    spokeVnetName: spokeVnetName
  }
}

// Outputs
output vnetId string = spokeVnet.id
output vnetName string = spokeVnet.name
output workloadSubnetId string = spokeVnet.properties.subnets[0].id
output privateEndpointSubnetId string = spokeVnet.properties.subnets[1].id
output addressPrefix string = addressPrefix
