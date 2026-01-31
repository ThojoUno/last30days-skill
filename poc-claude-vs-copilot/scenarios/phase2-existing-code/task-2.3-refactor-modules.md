# Task 2.3: Refactor Modules for Consistency (Hard)

## Objective
Test advanced codebase understanding and refactoring capabilities.

## Setup
Ensure the tool has access to all files in `modules/starter/`.

## Prompt

```
Review all the Bicep modules in modules/starter/ directory.

Refactor them to improve consistency and reusability:

1. Create a shared types file (infra/shared/types.bicep):
   - Define a user-defined type for standard tags
   - Define a user-defined type for diagnostic settings configuration
   - Define a type for subnet configuration objects

2. Create a shared variables file (infra/shared/naming.bicep):
   - Function to generate resource names following pattern: {resourceType}-{workload}-{environment}-{region}-{instance}
   - Include abbreviations for common resource types (vnet, snet, pip, fw, bas, etc.)

3. Update all modules to:
   - Import and use the shared types
   - Use consistent parameter naming (environment not env, location not region)
   - Add proper parameter decorators (@description, @allowed, @minLength, etc.)
   - Include module metadata (description, owner)

4. Ensure backwards compatibility:
   - Existing deployments using these modules should not break
   - Parameters should have sensible defaults where new ones are added

5. Add a new shared diagnostic settings module (infra/shared/diagnostics.bicep):
   - Reusable module for configuring diagnostic settings on any resource
   - Parameters for log categories, metric categories, workspace ID
   - Support for storage account and event hub destinations (optional)

Provide a summary of all changes made and why.
```

## Expected Deliverables
- `infra/shared/types.bicep`
- `infra/shared/naming.bicep`
- `infra/shared/diagnostics.bicep`
- Updated modules in `modules/starter/`
- Summary of changes

## Scoring Focus
- **Context Understanding**: Reads and understands all existing modules
- **Accuracy**: Valid Bicep user-defined types, working module imports
- **Completeness**: All requested shared resources created, all modules updated
- **Best Practices**: Proper use of Bicep features (user-defined types, decorators)
