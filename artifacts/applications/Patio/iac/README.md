# Patio IaC - Unlimited Performance Strategy (v3.0.0)

**Purpose**: Infrastructure-as-Code files (Bicep, ARM templates) for Patio application deployment  
**Version**: v3.0.0 (Unlimited Performance Strategy - cost-001 v3.0.0)  
**Date**: February 10, 2026  
**Branch**: `patio-unlimited-performance`  
**Success Metrics**: 60%+ latency reduction vs v2.0.0, 3-10x throughput improvement (Premium storage), GPU availability ready

## Overview

Patio IaC enforces premium-only SKUs across all environments per cost-001 v3.0.0:
- **Compute**: D32ds_v5 (dev), D48ds_v5 (test), D96ds_v5 (prod) minimum
- **Storage**: Premium_ZRS all environments, UltraSSD option for prod (160k IOPS, 4000 MB/s)
- **Encryption**: AES-256 all environments, CMK for production
- **Networking**: Accelerated networking enabled, multi-region ready
- **GPU**: Optional ND96amsr_A100_v4 with 8x NVIDIA A100 GPUs (AI/ML workloads)

## Specifications

**Upstream Tier Constraints**:
- business/cost-001 v3.0.0 (unlimited performance, premium-only)
- infrastructure/compute-001 v3.0.0 (D32-D96ds_v5, M192, GPU)
- infrastructure/storage-001 v3.0.0 (Premium ZRS/Ultra)
- infrastructure/networking-001 v3.0.0 (multi-region, 50ms latency target)
- infrastructure/iac-modules-001 v2.0.0 (v3.0.0 defaults)

## File Organization

```
iac/
├── main.bicep              # Root template (orchestrates all modules)
├── config.bicep            # Configuration & shared parameters (v3.0.0 specs)
├── automation.bicep        # Optimization: GPU monitoring, network/disk I/O tuning
├── monitoring.bicep        # Application Insights, Log Analytics, performance alerts
├── security.bicep          # RBAC, CMK, Key Vault Premium
├── dev.bicepparam          # Dev parameters: D32ds_v5, Premium_ZRS
├── test.bicepparam         # Test parameters: D48ds_v5, Premium_ZRS
├── prod.bicepparam         # Production parameters: D96ds_v5, Premium_ZRS/Ultra, CMK enabled
├── README.md               # This file
└── CHANGELOG.md            # Version history
```

## Deployment Steps

### Validation

```powershell
# Dev environment
az deployment group validate \
  --resource-group rg-patio-dev \
  --template-file ./main.bicep \
  --parameters dev.bicepparam

# Test environment
az deployment group validate \
  --resource-group rg-patio-test \
  --template-file ./main.bicep \
  --parameters test.bicepparam

# Production environment
az deployment group validate \
  --resource-group rg-patio-prod \
  --template-file ./main.bicep \
  --parameters prod.bicepparam
```

### Deployment with Preview

```powershell
# Dev what-if
az deployment group create --what-if \
  --resource-group rg-patio-dev \
  --template-file ./main.bicep \
  --parameters dev.bicepparam

# Deploy dev
az deployment group create \
  --resource-group rg-patio-dev \
  --template-file ./main.bicep \
  --parameters dev.bicepparam
```

## Performance Optimization (v3.0.0)

### Network Acceleration
- Enabled globally on all VMs (Premium SKUs support SRIOV)
- Ring buffer optimization via `network-tuning.sh`
- Target: 10Gbps+ throughput for Premium storage

### Disk I/O Tuning
- Premium storage P30-P80 IOPS: 500-7500 baseline
- Ultra Disk (prod): 160,000 IOPS, 4000 MB/s
- Extension: `DiskIoTuning` applies `/etc/sysctl.conf` optimizations

### GPU Monitoring (Optional)
- Parameter: `enableGpuAcceleration = true` (ND96amsr_A100_v4 only)
- Extensions: `GpuMonitoring` + custom performance telemetry
- Use Case: AI/ML inference acceleration

### Performance Baselines

| Environment | VM SKU | Storage | Latency Target | Throughput Target |
|---|---|---|---|---|
| Dev | D32ds_v5 | Premium_ZRS | < 100ms | 500MB/s |
| Test | D48ds_v5 | Premium_ZRS | < 75ms | 1000MB/s |
| Prod | D96ds_v5 | Premium_ZRS/Ultra | < 50ms | 3000+ MB/s |

## GPU Workload Deployment Example

```bicep
// In to parameters: enableGpuAcceleration = true
// VM SKU must be: Standard_ND96amsr_A100_v4

// Deployment with GPU:
param vmSku = 'Standard_ND96amsr_A100_v4'
param enableGpuAcceleration = true
param enableGpuMonitoring = true

// Expected: 8x NVIDIA A100 GPUs, 300%+ speedup for GPU workloads
```

## Monitoring & Alerts

Application Insights dashboards track:
- **Latency**: p50/p95/p99 response times (target: 60%+ reduction vs v2.0.0)
- **Throughput**: Requests/sec, MB/s (target: 3-10x improvement)
- **GPU Utilization**: (if enabled) - per-GPU metrics
- **Storage I/O**: Disk read/write latency, IOPS

Alert thresholds (v3.0.0):
- Latency > 100ms → Severity 2
- Throughput < 1000MB/s → Severity 2
- GPU util > 90% → Severity 3

## Troubleshooting

### Bicep Validation Failures

```powershell
# Build & validate
bicep build ./main.bicep --output-format json

# Check for errors
$output = bicep build ./main.bicep --output-format json 2>&1
if ($LASTEXITCODE -ne 0) { Write-Error "Bicep build failed"; $output }
```

### Module Resolution Issues

Ensure paths are correct:
```bicep
module example '../../../infrastructure/iac-modules/avm-wrapper-linux-vm/main.bicep' = { ... }
```

### Parameter Mismatch

Verify parameter files match config.bicep allowed values:
- vmSku: Must be D32ds_v5 or higher
- storageSku: Must be Premium_ZRS or PremiumV2_ZRS
- enableCmk: Only true for prod

## See Also

- **Specs**: [../../../specs/application/Patio/](../../../specs/application/Patio)
- **Cost Spec**: [../../../specs/business/cost/spec.md](../../../specs/business/cost/spec.md)
- **Compute Spec**: [../../../specs/infrastructure/compute/spec.md](../../../specs/infrastructure/compute/spec.md)
- **Storage Spec**: [../../../specs/infrastructure/storage/spec.md](../../../specs/infrastructure/storage/spec.md)
- **Modules**: [../../../artifacts/infrastructure/iac-modules/](../../../artifacts/infrastructure/iac-modules)
- **Modernization Plan**: [../iac-modernization-plan.md](../iac-modernization-plan.md)
- **Parent Directory**: [../README.md](../README.md)

- **Specification**: `/specs/platform/001-application-artifact-organization/spec.md`

---

**Created**: 2026-02-05  
**Version**: v1.0.0