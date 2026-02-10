# Patio IaC Changelog

## [3.0.0] - 2026-02-10

### Changed (Breaking Changes - v2.0.0 → v3.0.0: Unlimited Performance Strategy)

#### Cost Strategy Migration
- **OLD**: Cost-optimized with conditional SKUs based on workload criticality
- **NEW**: Unlimited performance with premium-only SKUs (cost-001 v3.0.0)
- **Impact**: Cost baselines removed; all environments now use premium tiers

#### Compute Resources
- **OLD**: Standard_B2s (dev), Standard_B4ms (non-critical), Standard_D4s (critical)
- **NEW**: Standard_D32ds_v5 (dev min), Standard_D48ds_v5 (test), Standard_D96ds_v5+ (prod)
- **Impact**: 2-8x performance improvement; requires D-series VM quotas
- **GPU Option**: NEW Standard_ND96amsr_A100_v4 with 8x NVIDIA A100 GPUs for AI/ML

#### Storage Resources
- **OLD**: Standard_LRS (dev), Standard_ZRS (prod)
- **NEW**: Premium_ZRS minimum (all), UltraSSD_LRS optional (prod): 160k IOPS, 4000 MB/s
- **Impact**: 3-10x throughput improvement; higher storage costs now acceptable
- **Replication**: Multi-region ZRS required for high availability (networking-001 v3.0.0)

#### Encryption
- **OLD**: Conditional - enabled for prod only
- **NEW**: Mandatory AES-256 for all environments
- **Production**: NEW Customer-managed keys (CMK) with HSM backing via Key Vault Premium
- **Impact**: Additional complexity; key rotation required (28-day policy)

#### Networking
- **OLD**: Single-zone deployments (dev/test), optional multi-zone (prod)
- **NEW**: Accelerated networking mandatory (SRIOV); multi-region for < 50ms latency
- **Impact**: New ExpressRoute Direct circuits recommended (networking-001 v3.0.0)

#### Infrastructure Modules
- **Module Updates**: avm-wrapper-* modules updated to enforce v3.0.0 defaults
  - avm-wrapper-linux-vm: GPU parameter support, Premium VM SKU constraints
  - avm-wrapper-storage-account: Premium storage types only
  - avm-wrapper-managed-disk: Premium_ZRS default, UltraSSD support
  - avm-wrapper-mysql-flexibleserver: GeneralPurpose_D4ds_v4+ only

#### Monitoring & Performance
- **NEW**: Application Insights integration for latency/throughput tracking
- **NEW**: GPU utilization metrics (if ND96amsr_A100_v4 enabled)
- **NEW**: Performance alert thresholds (latency > 100ms, throughput baseline)
- **Success Criteria**: 60%+ latency reduction vs v2.0.0, 300%+ GPU speedup (if enabled)

#### Automation & Optimization
- **NEW**: Network tuning extension (ring buffer optimization)
- **NEW**: Disk I/O tuning extension (sysctl queue settings)
- **NEW**: GPU driver installation (if GPU enabled)

#### Bicep Modules
- **config.bicep**: Added vmSku, storageSku, enableGpuAcceleration, enableCmk parameters
- **automation.bicep**: Added GPU monitoring, network/disk I/O tuning extensions
- **monitoring.bicep**: Added Application Insights, performance alerts
- **security.bicep**: Added CMK key generation, 28-day rotation policy
- **main.bicep**: Added cost-001 v3.0.0 metadata tags, module parameter wiring

#### Parameter Files
- **dev.bicepparam**: vmSku=D32ds_v5, storageSku=Premium_ZRS, cmk=false
- **test.bicepparam**: vmSku=D48ds_v5, storageSku=Premium_ZRS, cmk=false
- **prod.bicepparam**: vmSku=D96ds_v5, storageSku=Premium_ZRS/Ultra, cmk=true

### Added

- `config.bicep`: Centralized configuration with v3.0.0 spec parameters
- `automation.bicep`: GPU monitoring, network/disk I/O tuning (v3.0.0 feature)
- `monitoring.bicep`: Application Insights integration with performance dashboards
- `security.bicep`: Enhanced with CMK, Key Vault Premium, key rotation
- `main.bicep`: Comprehensive Bicep header with v3.0.0 spec references
- `README.md`: Updated with unlimited performance strategy, deployment examples
- `CHANGELOG.md`: This file

### Removed

- Cost-based conditional logic (e.g., `environment == 'prod' ? 'Premium' : 'Standard'`)
- Spot VM support (deprecated per cost-001 v3.0.0)
- Cost baseline metadata tags (no longer applicable)

### Deprecated

- Standard SKU storage (all instances must migrate to Premium)
- B-series VMs (all must migrate to D-series or M-series)
- Cost optimization pipeline gates (replaced with performance gates)

### Migration Path (v2.0.0 → v3.0.0)

1. **Prerequisite**: Obtain CTO approval per governance-001 spec
2. **Update Specs**: Place on branch `patio-unlimited-performance`
3. **Dev Testing**: Deploy to dev with D32ds_v5, validate bicep build
4. **Test Validation**: Deploy to test with D48ds_v5, baseline metrics for 24+ hours
5. **Production Approval**: CTO approves v3.0.0 deployment
6. **Production Rollout**: Deploy to prod with D96ds_v5, monitor 48+ hours
7. **Validation**: Confirm 60%+ latency reduction vs v2.0.0

### Known Issues

None (initial v3.0.0 release)

### Dependencies

- **business/cost-001**: v3.0.0 (required)
- **infrastructure/compute-001**: v3.0.0 (required)
- **infrastructure/storage-001**: v3.0.0 (required)
- **infrastructure/networking-001**: v3.0.0 (required)
- **infrastructure/iac-modules-001**: v2.0.0 (required)

---

## [2.0.0] - 2026-01-15

### Added
- Initial Patio IaC template structure
- config.bicep with cost-based conditionals
- automation.bicep with basic auto-shutdown
- monitoring.bicep with Log Analytics
- security.bicep with RBAC assignments
- main.bicep orchestration template
- Parameter files (dev, test, prod)

### Infrastructure Modules
- Used avm-wrapper-* modules (v1.0.0-draft)
- Cost-optimized SKU defaults
