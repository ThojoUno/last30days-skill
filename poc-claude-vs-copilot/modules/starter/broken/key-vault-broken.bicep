// BROKEN: This module has an issue with role assignment naming
// Used for Task 3.1 debugging exercise

targetScope = 'resourceGroup'

param keyVaultName string
param location string = resourceGroup().location
param managedIdentityName string

// Create managed identity
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
}

// Create Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
  }
}

// BUG: Non-deterministic GUID causes "RoleAssignmentUpdateNotPermitted" on redeployment
// The GUID changes each time because it only uses resourceGroup().id
resource keyVaultSecretsOfficer 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id) // BUG: This should include principalId and roleDefinitionId
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7') // Key Vault Secrets Officer
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

output keyVaultId string = keyVault.id
output keyVaultUri string = keyVault.properties.vaultUri
output managedIdentityId string = managedIdentity.id
output managedIdentityPrincipalId string = managedIdentity.properties.principalId
