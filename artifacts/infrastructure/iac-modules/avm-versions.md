# Azure Verified Module (AVM) Version Tracking

**Purpose**: Track AVM module versions used in wrapper modules for security patching and updates.

**Last Updated**: 2026-02-07  
**Review Cadence**: Monthly (security patches within 7 days)

---

## Current AVM Module Versions

### Networking Modules

| Wrapper Module | AVM Module | Current Version | Last Updated | Next Review |
|----------------|------------|-----------------|--------------|-------------|
| avm-wrapper-vnet | `br/public:avm/res/network/virtual-network` | 0.5.1 | 2026-02-07 | 2026-03-07 |
| avm-wrapper-nsg | `br/public:avm/res/network/network-security-group` | 0.3.2 | 2026-02-07 | 2026-03-07 |
| avm-wrapper-public-ip | `br/public:avm/res/network/public-ip-address` | 0.4.0 | 2026-02-07 | 2026-03-07 |

### Compute & Storage Modules

| Wrapper Module | AVM Module | Current Version | Last Updated | Next Review |
|----------------|------------|-----------------|--------------|-------------|
| avm-wrapper-linux-vm | `br/public:avm/res/compute/virtual-machine` | 0.7.3 | 2026-02-07 | 2026-03-07 |
| avm-wrapper-managed-disk | `br/public:avm/res/compute/disk` | 0.3.1 | 2026-02-07 | 2026-03-07 |
| avm-wrapper-key-vault | `br/public:avm/res/key-vault/vault` | 0.9.0 | 2026-02-07 | 2026-03-07 |
| avm-wrapper-storage-account | `br/public:avm/res/storage/storage-account` | 0.14.3 | 2026-02-07 | 2026-03-07 |

### Database Modules

| Wrapper Module | AVM Module | Current Version | Last Updated | Next Review |
|----------------|------------|-----------------|--------------|-------------|
| avm-wrapper-mysql-flexibleserver | `br/public:avm/res/db-for-my-sql/flexible-server` | 0.4.2 | 2026-02-07 | 2026-03-07 |

---

## Version Update Process

1. **Monitor**: Check AVM repository monthly for updates
2. **Security Patches**: Apply within 7 days if security-related
3. **Test**: Deploy updated wrapper in dev subscription
4. **Validate**: Run compliance checks (cost, security, compliance specs)
5. **Update**: Increment wrapper module version (PATCH for AVM patch, MINOR for AVM minor)
6. **Document**: Update this file and CHANGELOG.md
7. **Notify**: Inform application teams of new wrapper versions

---

## Update History

| Date | AVM Module | Old Version | New Version | Reason | Breaking Changes |
|------|------------|-------------|-------------|--------|------------------|
| 2026-02-07 | *(initial)* | - | Various | Initial wrapper module creation | N/A |

---

## AVM Module Links

- **AVM Repository**: https://github.com/Azure/bicep-registry-modules/tree/main/avm/res
- **AVM Documentation**: https://azure.github.io/Azure-Verified-Modules/
- **Bicep Registry**: https://github.com/Azure/bicep-registry-modules

---

**Notes**:
- Version numbers reflect latest stable AVM releases as of 2026-02-07
- Wrapper modules pin to specific AVM versions (no `latest` tag)
- Breaking changes in AVM modules require wrapper module MAJOR version bump
- Application teams reference wrapper module versions (not AVM versions directly)
