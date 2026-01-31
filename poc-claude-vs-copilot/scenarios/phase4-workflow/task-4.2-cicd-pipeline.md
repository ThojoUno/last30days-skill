# Task 4.2: Create ALZ Deployment Pipeline (Hard)

## Objective
Test complex workflow generation including CI/CD for Azure Landing Zone.

## Prompt

```
Create a GitHub Actions workflow for deploying Azure Landing Zone infrastructure:

Requirements:

1. Workflow Triggers:
   - Push to main branch (paths: infra/**)
   - Pull request to main (paths: infra/**)
   - Manual workflow_dispatch with environment input

2. Jobs:

   a. validate:
      - Runs on all triggers
      - Bicep linting (az bicep build)
      - Bicep formatting check
      - PSRule for Azure (security/best practice validation)

   b. what-if (PR only):
      - Runs What-If deployment
      - Posts results as PR comment
      - Uses OIDC authentication (federated credentials)

   c. deploy-dev:
      - Runs on push to main
      - Needs: validate
      - Environment: development (with protection rules)
      - Deploys to dev subscription
      - Runs smoke tests after deployment

   d. deploy-prod:
      - Runs on push to main
      - Needs: deploy-dev
      - Environment: production (requires approval)
      - Deploys to prod subscription
      - Runs smoke tests after deployment

3. Reusable Components:
   - Create reusable workflow for Bicep deployment
   - Parameterize: environment, subscription, resource group, template

4. Security:
   - Use OIDC for Azure authentication (no secrets)
   - Separate service principals per environment
   - Least privilege RBAC (Contributor on specific RGs only)

5. Outputs:
   - Deployment outputs saved as job outputs
   - Summary written to GitHub Step Summary
   - Artifact upload for deployment logs

Create:
- .github/workflows/alz-deploy.yml (main workflow)
- .github/workflows/bicep-deploy-reusable.yml (reusable workflow)
- .github/actions/bicep-validate/action.yml (composite action for validation)
- Documentation explaining how to set up the required Azure credentials
```

## Expected Deliverables
- 3 workflow/action files
- Documentation for Azure setup

## Scoring Focus
- **Completeness**: All jobs, all requirements met
- **Accuracy**: Valid GitHub Actions syntax, correct OIDC setup
- **Best Practices**: Proper environment protection, reusable patterns
- **Security**: OIDC auth, least privilege
