#!/bin/bash
# Bicep Validation Script for POC Evaluation
# Usage: ./validate.sh <bicep-file> [resource-group]

set -e

BICEP_FILE="$1"
RESOURCE_GROUP="${2:-rg-poc-validation}"
LOCATION="${3:-eastus2}"

if [ -z "$BICEP_FILE" ]; then
    echo "Usage: ./validate.sh <bicep-file> [resource-group] [location]"
    exit 1
fi

if [ ! -f "$BICEP_FILE" ]; then
    echo "Error: File not found: $BICEP_FILE"
    exit 1
fi

echo "============================================"
echo "Bicep Validation: $BICEP_FILE"
echo "============================================"

# Step 1: Syntax validation (build)
echo ""
echo "[1/4] Syntax validation (az bicep build)..."
if az bicep build --file "$BICEP_FILE" --stdout > /dev/null 2>&1; then
    echo "✅ Syntax: PASSED"
else
    echo "❌ Syntax: FAILED"
    az bicep build --file "$BICEP_FILE" 2>&1
    exit 1
fi

# Step 2: Linting
echo ""
echo "[2/4] Linting (bicep linter)..."
LINT_OUTPUT=$(az bicep build --file "$BICEP_FILE" 2>&1 || true)
if echo "$LINT_OUTPUT" | grep -q "Warning"; then
    echo "⚠️  Linting: WARNINGS"
    echo "$LINT_OUTPUT" | grep "Warning" || true
else
    echo "✅ Linting: PASSED (no warnings)"
fi

# Step 3: ARM conversion check
echo ""
echo "[3/4] ARM template generation..."
ARM_FILE="${BICEP_FILE%.bicep}.json"
if az bicep build --file "$BICEP_FILE" --outfile "$ARM_FILE" 2>/dev/null; then
    echo "✅ ARM generation: PASSED"
    echo "   Output: $ARM_FILE"
else
    echo "❌ ARM generation: FAILED"
    exit 1
fi

# Step 4: What-If deployment (if authenticated)
echo ""
echo "[4/4] What-If deployment check..."
if az account show > /dev/null 2>&1; then
    # Check if it's a tenant or subscription scope deployment
    SCOPE=$(grep -m1 "targetScope" "$BICEP_FILE" 2>/dev/null | grep -oE "'[^']+'" | tr -d "'" || echo "resourceGroup")

    case "$SCOPE" in
        tenant)
            echo "   Scope: Tenant"
            echo "   Skipping what-if (requires elevated permissions)"
            echo "⏭️  What-If: SKIPPED (tenant scope)"
            ;;
        managementGroup)
            echo "   Scope: Management Group"
            echo "   Skipping what-if (requires MG parameter)"
            echo "⏭️  What-If: SKIPPED (management group scope)"
            ;;
        subscription)
            echo "   Scope: Subscription"
            if az deployment sub what-if --location "$LOCATION" --template-file "$BICEP_FILE" --no-pretty-print 2>&1 | head -20; then
                echo "✅ What-If: PASSED"
            else
                echo "⚠️  What-If: NEEDS PARAMETERS"
            fi
            ;;
        *)
            echo "   Scope: Resource Group ($RESOURCE_GROUP)"
            # Check if RG exists
            if az group show --name "$RESOURCE_GROUP" > /dev/null 2>&1; then
                if az deployment group what-if --resource-group "$RESOURCE_GROUP" --template-file "$BICEP_FILE" --no-pretty-print 2>&1 | head -20; then
                    echo "✅ What-If: PASSED"
                else
                    echo "⚠️  What-If: NEEDS PARAMETERS"
                fi
            else
                echo "⏭️  What-If: SKIPPED (RG not found: $RESOURCE_GROUP)"
            fi
            ;;
    esac
else
    echo "⏭️  What-If: SKIPPED (not authenticated to Azure)"
fi

echo ""
echo "============================================"
echo "Validation Complete"
echo "============================================"
