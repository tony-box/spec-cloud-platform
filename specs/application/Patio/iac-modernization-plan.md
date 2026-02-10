# IaC Modernization Plan: Patio - Unlimited Performance Strategy

**Date**: February 10, 2026  
**Application**: Patio  
**Scope**: Update all IaC modules to comply with unlimited performance strategy (business/cost v3.0.0, infrastructure v3.0.0)  
**Branch**: `patio-unlimited-performance` (create new)  

---

## Executive Summary

The platform has shifted from cost-optimized to **unlimited performance strategy**. This plan updates Patio's Infrastructure-as-Code to leverage:

- **Premium-only VM SKUs**: D32ds_v5+ (96+ vCPU), M192idms_v2 (192 vCPU, 4TB RAM), GPU-accelerated (8x NVIDIA A100)
- **Premium Storage**: Premium SSD P30+ minimum, Ultra Disk for maximum throughput
- **On-demand Pricing**: Cost optimization removed; unlimited Azure spending authorized
- **Multi-region**: For latency optimization (not HA/DR cost-saving)
- **Performance Monitoring**: Real-time metrics for latency, throughput, GPU utilization

**Expected Outcome**: Patio applications achieve 60%+ latency reduction and 300%+ throughput improvement for GPU workloads vs. cost-optimized baseline.

---

## Key Changes From Cost v2.0.0 → Cost v3.0.0

| Aspect | Before (v2.0.0) | After (v3.0.0) | Impact |
|--------|-----------------|-----------------|--------|
| **VM SKU Strategy** | Tiered (B2s, B4ms, D4s per criticality) | Premium-only (D32+, M192+, GPU) | 10-20x more vCPU per workload |
| **Cost Approach** | Cost baselines within budgets | Unlimited spending for performance | No cost constraints on monthly bills |
| **Storage Tier** | Standard SSD (E10/E15), LRS | Premium ZRS (P30+), Ultra Disk option | 20-100x IOPS improvement |
| **Replication** | LRS for non-critical | ZRS for all (with Ultra Disk) | Data availability + performance |
| **Reserved Instances** | 3-year critical, 1-year non-critical | On-demand (cost not applicable) | Flexibility over savings |
| **HA/DR** | Multi-zone for critical | Multi-region for latency only | Global performance optimization |
| **GPU Support** | Not available | H100/A100 acceleration standard | AI/ML workloads enabled |

---

## Phase 1: Spec Dependency Updates

**Goal**: Update plan.md to reference v3.0.0 specs and establish new constraints.

### 1.1 Update Depends-On Field

Update the `Depends-On` section in this plan to reference v3.0.0 infrastructure specs:

```markdown
**Depends-On** (Updated):
- business/cost (cost-001) v3.0.0  ← UPDATED (was v2.0.0)
- infrastructure/compute (compute-001) v3.0.0  ← UPDATED (was v2.0.0)
- infrastructure/storage (stor-001) v3.0.0  ← UPDATED (was v2.0.0)
- infrastructure/networking (net-001) v3.0.0  ← UPDATED (was v2.0.0)
- infrastructure/iac-modules (iac-001) v2.0.0  ← UPDATED (was v1.0.0-draft)
```

### 1.2 Update Constitution Check

Verify Patio's IaC plan aligns with new unlimited performance constraints:

- [x] **Platform tier specs**: ✅ No changes (spec-system, iac-linting, artifact-org remain v1.0.0)
- [x] **Business tier specs**: ⚠️ **UPDATED** cost-001 now mandates premium-only SKUs globally
- [x] **Security tier specs**: ✅ No changes (dp-001, ac-001 constraints enforced)
- [x] **Infrastructure tier specs**: ⚠️ **UPDATED** compute/storage/networking all v3.0.0 with premium-tier defaults
- [x] **No conflicts**: Patio may use full unlimited performance capability

---

## Phase 2: IaC Module Migration (Main Deliverable)

**Goal**: Migrate Patio's 10 Bicep files from cost-optimized to unlimited performance.

### 2.1 Files to Update

**Location**: `artifacts/applications/Patio/iac/`

1. **main.bicep** - Orchestration entry point
2. **config.bicep** - Parameter definitions and SKU validation 
3. **automation.bicep** - VM automation, Desired State Config
4. **monitoring.bicep** - Log Analytics, Application Insights (performance metrics)
5. **security.bicep** - Key Vault, encryption, RBAC
6. **dev.bicepparam** - Development environment parameters
7. **test.bicepparam** - Test environment parameters
8. **prod.bicepparam** - Production environment parameters

### 2.2 Migration Tasks

#### Task 2.2.1: Update config.bicep (VM SKU Parameters)

**Current State** (v2.0.0):
```bicep
@allowed(['Standard_B2s', 'Standard_B4ms', 'Standard_D2s_v5', 'Standard_D4s_v5'])
param vmSku string
```

**Target State** (v3.0.0):
```bicep
@allowed([
  'Standard_D32ds_v5', 'Standard_D48ds_v5', 'Standard_D64ds_v5', 'Standard_D96ds_v5',
  'Standard_M128ms', 'Standard_M192idms_v2',
  'Standard_ND96amsr_A100_v4', 'Standard_ND120rs_v2'
])
param vmSku string = 'Standard_D32ds_v5'

@description('Enable GPU acceleration (for AI/ML workloads) - new in v3.0.0')
param enableGpuAcceleration bool = false
param gpuSku string = 'Standard_ND96amsr_A100_v4'  // 8x NVIDIA A100
```

**Actions**:
- [ ] Add GPU SKU parameters (enableGpuAcceleration, gpuSku)
- [ ] Change vmSku default from B2s/B4ms to D32ds_v5
- [ ] Document in config.bicep header: "Unlimited Performance v3.0.0"
- [ ] Update version tag to '3.0.0'

#### Task 2.2.2: Update config.bicep (Storage Parameters)

**Current State** (v2.0.0):
```bicep
@allowed(['Standard_LRS', 'Standard_ZRS'])
param storageSku string
```

**Target State** (v3.0.0):
```bicep
@allowed(['Premium_LRS', 'Premium_ZRS', 'PremiumV2_LRS', 'UltraSSD_LRS'])
param storageSku string = 'Premium_ZRS'

@description('Enable Ultra Disk for maximum IOPS/throughput (IOPS: 160k, Throughput: 4000 MB/s)')
param enableUltraDisk bool = false
param ultraDiskIops int = 160000
param ultraDiskThroughput int = 4000
```

**Actions**:
- [ ] Change storageSku default from Standard_LRS to Premium_ZRS
- [ ] Add Ultra Disk parameters for maximum throughput workloads
- [ ] Enforce all disks use Premium tier minimum (no Standard tier)
- [ ] Update version tag

#### Task 2.2.3: Update config.bicep (Encryption & Security)

**Current State** (v2.0.0):
```bicep
param enableDiskEncryption bool = (environment == 'prod')
```

**Target State** (v3.0.0):
```bicep
param enableDiskEncryption bool = true  // Enabled for ALL environments
param customerManagedEncryption bool = (environment == 'prod')  // HSM-backed for prod
```

**Actions**:
- [ ] Enable disk encryption for dev/test/prod (not conditional)
- [ ] Add customer-managed encryption option for production
- [ ] Enforce Key Vault Premium SKU (HSM-backed) for prod
- [ ] Update security settings in security.bicep

#### Task 2.2.4: Update dev.bicepparam, test.bicepparam, prod.bicepparam

**Example Changes** (all three files):

```json
// BEFORE (v2.0.0)
{
  "vmSku": { "value": "Standard_B2s" },  // dev example
  "storageSku": { "value": "Standard_LRS" },
  "enableDiskEncryption": { "value": false }
}

// AFTER (v3.0.0)
{
  "vmSku": { "value": "Standard_D32ds_v5" },  // minimum premium tier
  "storageSku": { "value": "Premium_ZRS" },
  "enableDiskEncryption": { "value": true },
  "enableGpuAcceleration": { "value": false },  // enable for ML workloads
  "costProfile": { "value": "unlimited-performance" }
}
```

**Actions**:
- [ ] Update dev.bicepparam: D32ds_v5, Premium_ZRS, enable encryption
- [ ] Update test.bicepparam: D48ds_v5 or D64ds_v5, Premium_ZRS, enable encryption
- [ ] Update prod.bicepparam: D96ds_v5+, Premium_ZRS or Ultra Disk, customer-managed encryption
- [ ] Add `costProfile: "unlimited-performance"` tag to all parameter files

#### Task 2.2.5: Update monitoring.bicep (Performance Metrics)

**New Requirements** (v3.0.0):

```bicep
@description('Enable premium monitoring for latency/throughput optimization')
param enablePremiumMetrics bool = true

@description('Performance baselines for validation')
param targetLatencyMs int = 50        // <50ms latency target
param targetThroughputMbps int = 500  // >500 Mbps throughput target
```

**Actions**:
- [ ] Add real-time performance metric collection (latency, throughput, CPU utilization, GPU utilization)
- [ ] Create custom dashboards for:
  - Application latency (p50, p95, p99)
  - Storage throughput (MB/s, IOPS)
  - GPU utilization (if enabled)
  - Network bandwidth utilization
- [ ] Add performance-based alerts (e.g., latency > 100ms)
- [ ] Document success criteria per cost-001 v3.0.0

#### Task 2.2.6: Update automation.bicep (VM Extensions)

**New in v3.0.0**:

```bicep
@description('Enable GPU monitoring extensions (if GPU VM)')
param installGpuMonitoring bool = (contains(vmSku, 'Standard_ND') || contains(vmSku, 'Standard_NC'))

@description('Enable network acceleration (ANF, Accelerated Networking)')
param enableNetworkAcceleration bool = true

@description('Enable accelerated disk I/O')
param enableDiskAcceleration bool = true
```

**Actions**:
- [ ] Add GPU monitoring extension for ND/NC SKUs (NVIDIA GPU monitoring)
- [ ] Enable accelerated networking for all VMs (VMXNet3 equivalent for Azure)
- [ ] Configure disk I/O acceleration (if supported)
- [ ] Update cloud-init script for performance optimization (network tuning, disk I/O optimization)

#### Task 2.2.7: Update security.bicep (Key Vault & Encryption)

**Changes**:

```bicep
@description('Key Vault SKU (Premium with HSM backing for prod)')
@allowed(['standard', 'premium'])
param keyVaultSku string = (environment == 'prod') ? 'premium' : 'standard'

@description('Enable CMK (Customer-Managed Keys) for all data at rest')
param enableCMK bool = true

@description('Key rotation policy (90 days for prod, 180 days for dev)')
param keyRotationDays int = (environment == 'prod') ? 90 : 180
```

**Actions**:
- [ ] Enforce Premium Key Vault for prod (HSM-backed keys)
- [ ] Enable customer-managed encryption keys for all storage/disks
- [ ] Add key rotation policy (90-day cycle for prod)
- [ ] Update version to reflect v3.0.0 compliance

#### Task 2.2.8: Update main.bicep (Orchestration)

**Add Dependency Tracking**:

```bicep
@description('Cost spec version compliance')
param costSpecVersion string = 'business/cost-001 v3.0.0'

@description('Infrastructure spec versions')
param infrastructureSpecVersions object = {
  compute: 'v3.0.0'
  storage: 'v3.0.0'
  networking: 'v3.0.0'
}

var deploymentMetadata = {
  performanceStrategy: 'unlimited'
  costConstraints: 'none'  // Cost not a constraint per cost-001 v3.0.0
  specsCompliance: infrastructureSpecVersions
}
```

**Actions**:
- [ ] Update main.bicep header to reference cost-001 v3.0.0 + compute/storage/networking v3.0.0
- [ ] Add deployment metadata tags
- [ ] Document breaking changes (Bicep version 0.21+, AVM module updates)

#### Task 2.2.9: Update README.md (Documentation)

**Changes**:

```markdown
# Patio IaC - Unlimited Performance (v3.0.0)

## Performance Strategy

As of February 10, 2026, Patio infrastructure uses **unlimited performance strategy**:
- **VM SKUs**: Premium-tier only (D32+, M192+, GPU options)
- **Storage**: Premium ZRS minimum, Ultra Disk for maximum throughput
- **Cost Model**: Unlimited spending authorized; on-demand pricing
- **Regional Design**: Multi-region for latency optimization
- **GPU Support**: 8x NVIDIA A100 acceleration available

## Success Metrics

- Application latency: <50ms p99 (target 60%+ reduction vs v2.0.0)
- Storage throughput: >500 MB/s baseline
- GPU workload speedup: 300%+ for model training (if enabled)
- Cost variance: Informational only (not used for constraint)

## Spec Compliance

- business/cost-001: v3.0.0 (unlimited performance)
- infrastructure/compute-001: v3.0.0
- infrastructure/storage-001: v3.0.0
- infrastructure/networking-001: v3.0.0
- infrastructure/iac-modules-001: v2.0.0
```

**Actions**:
- [ ] Update README.md with new performance strategy
- [ ] Document GPU workload deployment patterns
- [ ] Add examples for multi-region deployment
- [ ] Link to cost-001 v3.0.0 for context

### 2.3 Validation Tasks

After completing 2.2.1-2.2.9:

```bash
# Task 2.3.1: Bicep Validation
bicep build artifacts/applications/Patio/iac/main.bicep
bicep build artifacts/applications/Patio/iac/config.bicep
bicep build artifacts/applications/Patio/iac/automation.bicep
bicep build artifacts/applications/Patio/iac/monitoring.bicep
bicep build artifacts/applications/Patio/iac/security.bicep

# Task 2.3.2: Parameter Validation
bicep build artifacts/applications/Patio/iac/main.bicep -p dev.bicepparam
bicep build artifacts/applications/Patio/iac/main.bicep -p test.bicepparam
bicep build artifacts/applications/Patio/iac/main.bicep -p prod.bicepparam

# Task 2.3.3: Lint Check
bicep lint artifacts/applications/Patio/iac/main.bicep
```

**Actions**:
- [ ] Run `bicep build` on all .bicep files → validate syntax
- [ ] Resolve any parameter type mismatches
- [ ] Verify all SKUs are valid Azure resource types
- [ ] Check parameter format (.bicepparam) compliance

---

## Phase 3: Testing & Deployment Strategy

**Goal**: Validate updated IaC before deploying to real environments.

### 3.1 Dev Environment Dry-Run

```bash
# Deploy to dev (preview-only, no actual resources)
az deployment group create \
  --resource-group rg-patio-dev \
  --template-file artifacts/applications/Patio/iac/main.bicep \
  --parameters dev.bicepparam \
  --what-if  # Preview changes without deploying

# Actions
- [ ] Verify all resource SKUs are available in dev region
- [ ] Check cost estimation (informational)
- [ ] Validate RBAC/Key Vault access
```

### 3.2 Test Environment Deployment

```bash
# Deploy to test environment (validate performance improvements)
az deployment group create \
  --resource-group rg-patio-test \
  --template-file artifacts/applications/Patio/iac/main.bicep \
 --parameters test.bicepparam

# Actions
- [ ] Deploy updated IaC to test environment
- [ ] Run smoke tests (validate connectivity, storage access)
- [ ] Baseline performance metrics (latency, throughput)
- [ ] Verify GPU acceleration (if enabled)
- [ ] Monitor Azure Monitor dashboards for anomalies
```

### 3.3 Production Approval & Deployment

```bash
# Production deployment requires approval
# (Per business/governance spec and CI/CD orchestration)

# Once approved:
az deployment group create \
  --resource-group rg-patio-prod \
  --template-file artifacts/applications/Patio/iac/main.bicep \
  --parameters prod.bicepparam

# Actions
- [ ] Obtain governance approval (per governance spec)
- [ ] Deploy to prod with change windows
- [ ] Monitor performance improvements
- [ ] Document success metrics (latency reduction, throughput gains)
```

---

## Phase 4: Documentation & Handoff

**Goal**: Document changes and update Patio team with new capabilities.

### 4.1 Update IaC Artifacts

**Files to update**:
- [ ] `artifacts/applications/Patio/iac/README.md` - Add performance strategy section
- [ ] `artifacts/applications/Patio/iac/main.bicep` - Update header comments with v3.0.0 spec references
- [ ] `artifacts/applications/Patio/iac/CHANGELOG.md` - Document breaking changes from v2.0.0 → v3.0.0

### 4.2 Update Patio Spec Documents

**Files to update**:
- [ ] `specs/application/Patio/quickstart.md` - Add unlimited performance examples
- [ ] `specs/application/Patio/plan.md` - Version bump to reflect cost-001 v3.0.0 dependencies

### 4.3 Training & Communication

- [ ] Notify Patio team of performance improvements (60%+ latency reduction potential)
- [ ] Document new GPU acceleration capability (for ML/AI workloads)
- [ ] Explain multi-region deployment benefits (global latency optimization)
- [ ] Share cost modeling update (no longer cost-constrained, on-demand pricing)

---

## Migration Checklist

### Phase 1: Spec Dependencies
- [ ] 1.1 Update Depends-On field in plan.md to reference v3.0.0 specs
- [ ] 1.2 Update Constitution Check for unlimited performance constraints

### Phase 2: IaC Module Migration
- [ ] 2.2.1 Update config.bicep VM SKU parameters and add GPU support
- [ ] 2.2.2 Update config.bicep storage parameters and add Ultra Disk option
- [ ] 2.2.3 Update config.bicep encryption settings (enable for all environments)
- [ ] 2.2.4 Update dev/test/prod.bicepparam files with premium-tier defaults
- [ ] 2.2.5 Update monitoring.bicep for performance metric collection
- [ ] 2.2.6 Update automation.bicep for GPU/network acceleration extensions
- [ ] 2.2.7 Update security.bicep for HSM-backed Key Vault and CMK
- [ ] 2.2.8 Update main.bicep with spec version metadata
- [ ] 2.2.9 Update README.md with performance strategy documentation
- [ ] 2.3 Run Bicep validation and parameter checks

### Phase 3: Testing & Deployment
- [ ] 3.1 Dev environment dry-run with `--what-if`
- [ ] 3.2 Test environment deployment and performance baseline
- [ ] 3.3 Production deployment with CTO approval

### Phase 4: Documentation & Handoff
- [ ] 4.1 Update IaC artifact documentation
- [ ] 4.2 Update Patio spec documents
- [ ] 4.3 Team training and communication

---

## Success Criteria

By completion of all phases:

✅ **Bicep Compilation**: All .bicep files compile without errors (bicep build)  
✅ **Parameter Validation**: All .bicepparam files validate against Bicep schemas  
✅ **Spec Compliance**: IaC explicitly references cost-001 v3.0.0 + infrastructure v3.0.0  
✅ **Performance Gains**:
  - Latency reduction: 60%+ vs cost-optimized baseline
  - Throughput improvement: 3-10x for Premium storage
  - GPU availability: Ready for AI/ML workloads
✅ **Cost Transparency**: Monthly cost reports generated (for information, not constraint)  
✅ **Documentation**: README and comments explain unlimited performance strategy  
✅ **Team Readiness**: Patio team trained on new capabilities and limitations  

---

## Timeline Estimate

- **Phase 1** (Spec Updates): 30 minutes
- **Phase 2** (IaC Migration): 2-3 hours
- **Phase 3** (Testing & Validation): 1-2 hours
- **Phase 4** (Documentation): 30 minutes

**Total**: ~4-6 hours to full deployment readiness

---

## Next Steps

1. **Review & Approval**: Have Patio team and infrastructure lead review this plan
2. **Create Branch**: `git checkout -b patio-unlimited-performance`
3. **Execute Phase 1**: Update spec dependencies
4. **Execute Phase 2**: Migrate IaC modules (tasks 2.2.1-2.2.9)
5. **Execute Phase 3**: Run validation and deployment tests
6. **Merge & Deploy**: Once approved, merge to main and deploy

