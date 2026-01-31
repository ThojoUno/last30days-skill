// BROKEN: Private endpoint with DNS configuration issues
// Used for Task 3.2 debugging exercise

targetScope = 'resourceGroup'

param storageAccountName string
param location string = resourceGroup().location
param subnetId string
param hubVnetId string
// BUG: spokeVnetId parameter exists but isn't used for DNS zone link
param spokeVnetId string

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: 'Disabled'
  }
}

// Private DNS Zone for blob
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.${environment().suffixes.storage}'
  location: 'global'
}

// BUG 1: Only linking to hub VNet, not spoke VNet
// Applications in spoke VNet won't be able to resolve private DNS
resource hubVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: 'link-hub'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: hubVnetId
    }
  }
}

// BUG 2: Spoke VNet link is commented out / missing
// resource spokeVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
//   parent: privateDnsZone
//   name: 'link-spoke'
//   location: 'global'
//   properties: {
//     registrationEnabled: false
//     virtualNetwork: {
//       id: spokeVnetId
//     }
//   }
// }

// Private Endpoint
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: 'pep-${storageAccountName}-blob'
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'plsc-${storageAccountName}-blob'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

// BUG 3: Private DNS Zone Group is missing entirely
// Without this, the A record won't be auto-created in the Private DNS Zone
// The following resource should exist but doesn't:
//
// resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = {
//   parent: privateEndpoint
//   name: 'default'
//   properties: {
//     privateDnsZoneConfigs: [
//       {
//         name: 'config1'
//         properties: {
//           privateDnsZoneId: privateDnsZone.id
//         }
//       }
//     ]
//   }
// }

output storageAccountId string = storageAccount.id
output privateEndpointId string = privateEndpoint.id
output privateDnsZoneId string = privateDnsZone.id
// BUG: This output suggests the config is complete, but DNS won't work
output privateEndpointIp string = privateEndpoint.properties.customDnsConfigs[0].ipAddresses[0]
