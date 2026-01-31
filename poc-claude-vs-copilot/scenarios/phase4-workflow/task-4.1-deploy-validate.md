# Task 4.1: Generate, Deploy, and Validate (Medium)

## Objective
Test end-to-end agentic workflow: generate code, deploy to Azure, handle errors.

## Prerequisites
- Authenticated Azure CLI session
- Resource group created: `rg-poc-validation`
- Log Analytics workspace available

## Prompt

```
I need you to create and deploy a simple web application infrastructure:

1. Generate Bicep for:
   - App Service Plan (Linux, B1 SKU)
   - App Service (Node.js 20 LTS)
   - Application Insights connected to existing Log Analytics
   - System-assigned managed identity enabled

2. Deploy to Azure:
   - Resource group: rg-poc-validation
   - Location: eastus2
   - Use az deployment group create

3. Validate the deployment:
   - Run az deployment group show to confirm success
   - Verify the App Service is running with az webapp show
   - Test the default endpoint responds with curl

4. If any step fails:
   - Diagnose the error
   - Fix the Bicep
   - Redeploy

Parameters to use:
- appName: webapp-poc-test
- logAnalyticsWorkspaceId: /subscriptions/{sub}/resourceGroups/rg-shared/providers/Microsoft.OperationalInsights/workspaces/law-shared

Continue until the deployment succeeds and the app responds.
```

## Expected Behavior
- Tool generates valid Bicep
- Tool runs deployment commands
- Tool interprets Azure CLI output
- Tool self-corrects on errors
- Tool validates success

## Scoring Focus
- **Accuracy**: Generated code deploys successfully
- **Iteration Efficiency**: How many tries to get working deployment?
- **Agentic Capability**: Does it automatically run commands and interpret results?

## Notes
- This task requires the tool to execute shell commands
- Track whether tool asks permission or runs autonomously
- Note how it handles Azure CLI errors
