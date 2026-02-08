---
# YAML Frontmatter - Category-Based Spec System
tier: security
category: audit-logging
spec-id: audit-001
version: 1.0.0-draft
status: draft
created: 2026-02-07
description: "Audit trails (auditd), Azure Monitor logging, retention policies, compliance logging"

# Dependencies
depends-on:
  - tier: security
    category: access-control
    spec-id: ac-001
    reason: "Audit logging monitors access control events"

# Precedence rules
precedence:
  loses-to:
    - tier: security
      category: data-protection
      spec-id: dp-001
      reason: "Audit logging is detection; data protection is prevention (higher priority)"

# Relationships
adhered-by:
  - app-id: mycoolapp
    version: "1.0.0"
    compliance: "auditd configured, Azure Monitor enabled, 3-year retention"
---

# Specification: Audit Logging

**Tier**: security  
**Category**: audit-logging  
**Spec ID**: audit-001  
**Created**: 2026-02-07  
**Status**: Draft  

## Executive Summary

**Problem**: Without comprehensive audit logging:
- Security incidents go undetected
- Compliance violations are invisible
- Forensic investigation is impossible
- Unauthorized access is untracked

**Solution**: Implement auditd on Linux VMs, Azure Monitor for all Azure resources, centralized log aggregation, and compliance-based retention.

**Impact**: All security events logged, retained for 3 years minimum, and available for compliance audits and incident response.

## Requirements

### Functional Requirements

- **REQ-001**: All Linux VMs MUST run auditd with security audit rules
- **REQ-002**: All Azure resources MUST send logs to Azure Monitor
- **REQ-003**: All audit logs MUST be retained for 3 years minimum  
- **REQ-004**: All security events MUST trigger alerts (real-time detection)
- **REQ-005**: Audit logs MUST be immutable and tamper-proof

### Linux Audit (auditd)

**Audit Rules**:
- Authentication events: Login/logout, sudo usage, SSH connections
- File access: /etc/, /var/log/, sensitive application files
- Process execution: All commands run with elevated privileges
- Network connections: Outbound connections, listening ports
- System calls: execve, open, unlink (deletion), chmod/chown

**Audit Configuration**:
- Audit buffer: 8192 entries minimum
- Audit rate: 1000 events/second (prevent DoS)
- Audit failure mode: 1 (log but continue; don't halt system)
- Log rotation: Daily, compressed, 3-year retention

**Key Audit Events**:
- User authentication (pam)
- Sudo usage (all commands)
- SSH key usage
- File access (/etc/shadow, /etc/passwd, application secrets)
- Service start/stop (systemd)

### Azure Monitor Logging

**Log Categories**:
- Activity Log: All Azure resource operations (create, delete, modify)
- Diagnostic Logs: Resource-specific (VM metrics, NSG flow logs)
- Security Center Alerts: Security detections and recommendations
- Azure AD Sign-in Logs: All authentication events
- Azure AD Audit Logs: All authorization changes (RBAC modifications)

**Log Aggregation**:
- Destination: Log Analytics workspace (centralized)
- Retention: 3 years minimum (compliance requirement)
- Export: Optional export to Azure Storage for long-term archival
- Query: Kusto Query Language (KQL) for analysis

**Security Alerts**:
- Failed authentication attempts (>5 in 5 minutes)
- Unusual SSH source IPs
- Privilege escalation attempts
- Unauthorized RBAC changes
- Resource deletion (critical resources)

### Log Retention

**Retention Periods**:
- Security events: 3 years (NIST 800-171 requirement)
- Audit logs: 3 years (compliance requirement)
- Operational logs: 90 days (troubleshooting)
- Debug logs: 7 days (performance)

**Immutability**:
- Audit logs written to Azure Storage with immutability policy
- Log Analytics workspace: Export to immutable storage monthly
- No deletion permitted within retention period
- Tamper detection: Checksums/hashes verified

### Compliance Mapping

**NIST 800-171 Controls**:
- 3.3.1: Create/retain audit records
- 3.3.2: Audit events per organizational requirements
- 3.3.3: Review/analyze audit records
- 3.3.4: Alert on audit failure
- 3.3.8: Protect audit information from unauthorized access

## Success Criteria

- **SC-001**: 100% Linux VMs running auditd with security audit rules
- **SC-002**: 100% Azure resources logging to Azure Monitor
- **SC-003**: All audit logs retained for 3 years minimum
- **SC-004**: Security alerts configured and tested (real-time detection)
- **SC-005**: Audit logs immutable and tamper-proof

## Change Log

| Version | Date | Change | Approved By |
|---------|------|--------|------------|
| 1.0.0-draft | 2026-02-07 | Initial audit logging spec | Security Team Lead |

---

**Spec Version**: 1.0.0-draft  
**Created**: 2026-02-07
