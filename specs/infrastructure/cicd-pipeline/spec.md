---
# YAML Frontmatter - Category-Based Spec System
tier: infrastructure
category: cicd-pipeline
spec-id: cicd-001
version: 2.0.0
status: published
created: 2026-02-07
last-updated: 2026-02-09
description: "CI/CD pipeline standards with cost governance gates, workload criticality validation, and approval workflows"

# Dependencies
depends-on:
  - tier: business
    category: cost
    spec-id: cost-001
    version: 2.0.0
    reason: "Deployment pipelines must enforce cost baselines and validate workload criticality"
  - tier: business
    category: governance
    spec-id: gov-001
    reason: "Production deployments require approval gates per business governance"
  - tier: infrastructure
    category: compute
    spec-id: compute-001
    reason: "Deployment targets must exist per compute specifications"

# Precedence rules
precedence:
  loses-to:
    - tier: platform
      category: "*"
      spec-id: "*"
      reason: "Platform tier (technical standards, code quality, spec system) is foundational and cannot be overridden"
    - tier: business
      category: governance
      spec-id: gov-001
      reason: "Governance approval gates override automation for production"

# Relationships
adhered-by: []
---

# Specification: CI/CD Pipeline Standards with Cost Governance

**Tier**: infrastructure  
**Category**: cicd-pipeline  
**Spec ID**: cicd-001  
**Created**: 2026-02-07  
**Updated**: 2026-02-09  
**Status**: Published  
**Derived From**: business/cost-001 v2.0.0 (cost baselines) + business/governance (approval gates)  

## Executive Summary

**Problem**: Without cost-aware CI/CD pipelines:
- Workload criticality not declared (no cost baseline enforcement)
- No cost estimate validation before deployment
- Deployments exceeding cost baselines not flagged
- No automated cost variance monitoring
- Manual deployments bypass governance

**Solution**: Enhance GitHub Actions pipelines with:
1. Mandatory workload criticality declaration (critical/non-critical/dev-test)
2. Automated cost estimate validation against baselines
3. Approval gates for >20% cost variance
4. Reserved instance deployment templates
5. Cost variance monitoring integration

**Impact**: All deployments validate against cost baselines; exceeding baseline by >20% requires approval; cost variance tracked monthly.

## Requirements

### Functional Requirements

- **REQ-001**: All deployments MUST use GitHub Actions workflows (no manual deployments)
- **REQ-002**: All deployments MUST declare workload criticality (critical/non-critical/dev-test) via pipeline parameter
- **REQ-003**: All deployments MUST validate cost estimate against baseline for declared workload tier
- **REQ-004**: Deployments exceeding cost baseline by >20% MUST require approval with business justification
- **REQ-005**: Production deployments MUST require approval from designated approvers (governance)
- **REQ-006**: All deployments MUST include automated validation tests
- **REQ-007**: All pipelines MUST support rollback to previous version
- **REQ-008**: All deployment results MUST be logged and auditable
- **REQ-009**: Cost variance monitoring alerts MUST be created automatically post-deployment

### Pipeline Stages (Enhanced with Cost Governance)

**Stage 1: Validate & Cost Estimate** (runs on every commit):
- **NEW**: Validate workload criticality parameter is set (critical/non-critical/dev-test)
- **NEW**: Calculate estimated monthly cost based on declared SKUs, storage tiers, networking
- **NEW**: Compare estimate against cost baseline for workload tier:
  - Critical: $150-250/month per VM
  - Non-Critical: $50-100/month per VM
  - Dev/Test: $20-50/month per VM
- **NEW**: Flag if estimate exceeds baseline by >20% (requires approval in Stage 2)
- Lint IaC code (Bicep, Terraform, PowerShell)
- Validate prerequisites (Azure CLI, resource providers)
- Run unit tests (if applicable)
- Check Azure Policy compliance

**Stage 2: Deploy** (runs on approval):
- **Cost Variance Gate**: If cost estimate >20% over baseline, require approval from:
  - Infrastructure Lead (mandatory)
  - Business Owner (mandatory for >50% variance)
  - Provide: Business justification for cost variance
- **Production Gate**: Requires manual approval from infrastructure lead (existing)
- Non-production: Auto-deploy (no approval required)
- Build Bicep templates (use reserved instance templates for production)
- Create resource group (if not exists)
- Deploy infrastructure via `az deployment`
- Tag resources (environment, owner, cost-center, **criticality**, **baseline-cost**)

**Stage 3: Validate Deployment & Cost** (post-deployment):
- Check resource provisioning status
- Validate health endpoints (HTTP 200)
- Run end-to-end tests
- Verify Azure Monitor alerts configured
- Check compliance (NSG rules, encryption, etc.)
- **NEW**: Verify deployed resources match workload criticality:
  - Critical: Multi-zone VM, Premium/Standard SSD, zone-redundant storage
  - Non-Critical: Single-zone VM, Standard SSD, LRS storage
  - Dev/Test: Single-zone VM, Standard HDD/SSD, LRS storage
- **NEW**: Create cost variance monitoring alert (Azure Monitor):
  - Alert when actual monthly cost >20% over baseline
  - Notification: Infrastructure team + cost center owner

**Stage 4: Smoke Test & Cost Tracking** (production only):
- Basic functionality test (ping, health check)
- Performance baseline (response time < SLA)
- Rollback trigger if smoke test fails
- **NEW**: Tag deployment with actual vs estimated cost (post-30-day review)

### GitHub Actions Workflow Structure (Enhanced)

```yaml
Name: Deploy Application Infrastructure with Cost Governance

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:
    inputs:
      workload_criticality:
        description: 'Workload Tier (critical/non-critical/dev-test)'
        required: true
        type: choice
        options:
          - critical
          - non-critical
          - dev-test
      environment:
        description: 'Target Environment'
        required: true
        type: choice
        options:
          - production
          - dev
          - test

jobs:
  validate:
    runs-on: ubuntu-latest
    outputs:
      cost_estimate: ${{ steps.estimate.outputs.cost }}
      baseline_cost: ${{ steps.baseline.outputs.cost }}
      variance_pct: ${{ steps.variance.outputs.pct }}
    steps:
      - Checkout code
      - Run prerequisite checks
      - Lint Bicep templates
      
      # NEW: Cost Estimation & Baseline Validation
      - id: estimate
        name: Estimate Deployment Cost
        run: |
          # Calculate estimated monthly cost from Bicep parameters
          COST=$(./scripts/cost-estimate.ps1 -ParamFile main.bicepparam)
          echo "cost=$COST" >> $GITHUB_OUTPUT
      
      - id: baseline
        name: Get Cost Baseline for Workload Tier
        run: |
         # Lookup baseline from business/cost v2.0.0
          case "${{ inputs.workload_criticality }}" in
            critical) echo "cost=200" >> $GITHUB_OUTPUT ;;  # $150-250 midpoint
            non-critical) echo "cost=75" >> $GITHUB_OUTPUT ;;  # $50-100 midpoint
            dev-test) echo "cost=35" >> $GITHUB_OUTPUT ;;  # $20-50 midpoint
          esac
      
      - id: variance
        name: Calculate Cost Variance
        run: |
          VARIANCE=$(echo "scale=2; ((${{ steps.estimate.outputs.cost }} - ${{ steps.baseline.outputs.cost }}) / ${{ steps.baseline.outputs.cost }}) * 100" | bc)
          echo "pct=$VARIANCE" >> $GITHUB_OUTPUT
          
          if (( $(echo "$VARIANCE > 20" | bc -l) )); then
            echo "::warning::Cost estimate exceeds baseline by ${VARIANCE}% (requires approval)"
          fi
      
      - Validate Azure Policy compliance
  
  deploy:
    needs: validate
    # NEW: Cost variance gate
    environment: ${{ needs.validate.outputs.variance_pct > 20 && 'production-cost-variance' || 'production' }}
    runs-on: ubuntu-latest
    steps:
      - Login to Azure
      - Deploy Bicep templates (use reserved instance template for production)
      
      # NEW: Tag resources with cost metadata
      - name: Tag Resources
        run: |
          az tag create --resource-id $RESOURCE_ID --tags \
            criticality=${{ inputs.workload_criticality }} \
            baseline-cost=${{ needs.validate.outputs.baseline_cost }} \
            estimated-cost=${{ needs.validate.outputs.cost_estimate }} \
            variance-pct=${{ needs.validate.outputs.variance_pct }}
  
  validate-deployment:
    needs: deploy
    runs-on: ubuntu-latest
    steps:
      - Check resource status
      - Validate health endpoints
      - Run E2E tests
      
      # NEW: Verify deployed resources match workload criticality
      - name: Verify Workload Tier Compliance
        run: ./scripts/verify-tier-compliance.ps1 -Criticality "${{ inputs.workload_criticality }}"
      
      # NEW: Create cost variance monitoring alert
      - name: Create Cost Monitoring Alert
        run: |
          az monitor metrics alert create \
            --name "cost-variance-${{ github.run_id }}" \
            --resource-group $RESOURCE_GROUP \
            --condition "total cost > ${{ needs.validate.outputs.baseline_cost * 1.2 }}" \
            --description "Alert when monthly cost exceeds baseline by >20%" \
            --evaluation-frequency 1d
```

### Approval Gates (Enhanced with Cost Governance)

**Production Approval**:
- Required approvers: Infrastructure lead (minimum 1)
- Timeout: 7 days (deployment abandoned if not approved)
- Notification: Email + Teams/Slack notification
- Review criteria: Cost impact, security compliance, SLA impact

**Cost Variance Approval** (NEW):
- **Trigger**: Estimated cost >20% over baseline for workload tier
- **Required approvers**:
  - 20-50% variance: Infrastructure Lead (mandatory)
  - >50% variance: Infrastructure Lead + Business Owner (both mandatory)
- **Required documentation**:
  - Business justification for cost variance
  - Expected duration of higher cost (temporary vs permanent)
  - Alternative solutions considered (right-sizing, tier change)
- **Timeout**: 3 days (deployment cancelled if not approved)
- **Notification**: Infrastructure team + cost center owner

**Example Variance Scenarios**:
- Dev/Test baseline $35, estimate $45 (29% over) → Requires approval
- Non-Critical baseline $75, estimate $90 (20% over) → No approval needed (exactly at threshold)
- Critical baseline $200, estimate $320 (60% over) → Requires Infrastructure + Business approval

**Non-Production Auto-Deploy**:
- Dev/test environments: No approval required (unless >20% cost variance)
- Sandbox: No approval required
- Proof-of-concept: No approval required

**Break-Glass Emergency**:
- Security incidents: Auto-approved with post-facto review (24 hours)
- Production outages: Auto-approved with incident report
- Security incidents: Auto-approved with post-facto review (24 hours)
- Production outages: Auto-approved with incident report

### Rollback Procedures

**Automatic Rollback Triggers**:
- Deployment failure (Azure error)
- Post-deployment validation failure
- Smoke test failure (production)
- Health endpoint returning errors

**Manual Rollback**:
- Command: `az deployment group create --rollback-on-error`
- Process: Redeploy previous successful deployment
- Validation: Re-run validation tests after rollback

**Rollback Testing**:
- All pipelines MUST test rollback procedure quarterly
- Rollback SLA: Within 1 hour for critical workloads

## Success Criteria

- **SC-001**: 100% of deployments use GitHub Actions (no manual deployments)
- **SC-002**: 100% of deployments declare workload criticality (mandatory parameter)
- **SC-003**: All deployments validate cost estimate against baseline
- **SC-004**: Deployments exceeding baseline by >20% require approval (100% gated)
- **SC-005**: Production deployments have approval gates (100% gated)
- **SC-006**: All deployments include automated validation tests
- **SC-007**: Rollback procedures tested quarterly (4x per year)
- **SC-008**: All deployment results logged and auditable
- **SC-009**: Cost variance monitoring alerts created for all production deployments
- **SC-010**: Monthly cost variance reviews complete for workloads >20% over baseline

## Change Log

| Version | Date | Change | Approved By |
|---------|------|--------|------------|
| 1.0.0-draft | 2026-02-07 | Initial CI/CD pipeline spec | Infrastructure Lead |
| 2.0.0 | 2026-02-09 | **BREAKING**: Added cost governance features; mandatory workload criticality declaration; cost estimate validation; approval gates for >20% variance; cost monitoring alerts; published | Infrastructure Lead (cascade from business/cost) |

---

**Spec Version**: 2.0.0  
**Approved Date**: 2026-02-09  
**Depends On**: business/cost-001 (v2.0.0), business/governance (gov-001)  
**Artifacts Location**: artifacts/infrastructure/iac-modules/, .github/workflows/
