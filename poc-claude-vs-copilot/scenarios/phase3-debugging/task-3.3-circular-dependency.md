# Task 3.3: Circular Dependency Resolution (Hard)

## Objective
Test advanced debugging with complex multi-resource dependencies.

## Setup
The broken deployment is in `modules/starter/broken/app-service-broken.bicep`

## The Problem
Deployment fails with:
```
"code": "InvalidTemplate"
"message": "Deployment template validation failed: 'Circular dependency detected on resource..."
```

## Prompt

```
I have a Bicep deployment that's failing with a circular dependency error.

The setup is:
- App Service needs to reference Key Vault for secrets
- Key Vault needs to allow the App Service's managed identity
- Private endpoints for both need to be in the same DNS zone
- App Service needs the storage account connection string from Key Vault
- Storage account needs to allow the App Service's managed identity

Look at modules/starter/broken/app-service-broken.bicep and:

1. Identify all the circular dependencies
2. Explain why they occur
3. Refactor the deployment to break the cycles while maintaining security

The solution should:
- Still use managed identity (no connection strings with secrets)
- Still use private endpoints
- Still use Key Vault for secret management
- Deploy successfully in a single deployment (no manual steps)
```

## Root Causes
1. App Service -> Key Vault reference -> Key Vault RBAC -> App Service identity (circular)
2. App config references Key Vault secret which needs RBAC which needs the App identity
3. Resource ordering issues with private endpoints

## Expected Solutions
- Use `existing` keyword strategically
- Split deployment into modules with explicit dependencies
- Use `dependsOn` to control ordering
- Consider post-deployment configuration for some settings

## Scoring Focus
- **Accuracy**: All circular dependencies identified and resolved
- **Completeness**: Solution deploys successfully with all security intact
- **Best Practices**: Clean resolution without workarounds (no CLI scripts, no manual steps)
