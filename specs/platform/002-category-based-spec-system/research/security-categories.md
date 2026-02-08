# Phase 0 Research: Security Tier Categories

**Task**: T002 - Define security tier categories  
**Created**: 2026-02-07  
**Status**: Research Document

---

## Overview

Security tier categories represent security domains and protective measures. These are the decisions security and compliance teams make to protect systems, data, and infrastructure.

---

## Proposed Categories

### 1. Access-Control (`access-control`)

**Spec ID**: `access-control-001`  
**Purpose**: Authentication, authorization, identity management, RBAC policies

**Independent Decisions**:
- Authentication methods (SSH keys only, no passwords; MFA required; OAuth)
- Authorization models (RBAC, ABAC, role definitions)
- Identity provider strategy (Azure AD, custom, federated)
- Service account policies (service account creation rules, secret rotation)
- Privileged access management (PAM, sudo rules, break-glass procedures)
- Session management (idle timeout, max concurrent sessions)
- API authentication (bearer tokens, API keys, client certificates)
- Resource ownership and permission inheritance models

**Examples**:
- "SSH keys only; no password authentication"
- "All human users require MFA"
- "Service accounts rotated every 90 days"
- "Role-based access: readers, writers, admins per resource"
- "Azure AD is the identity provider for all users"

**Conflicts**:
- With security/audit-logging (access control grants; audit logs what was done)
- With infrastructure/cicd-pipeline (access controls limit who can deploy)

**Reason for Independence**:
- Access control is distinct from data protection or audit logging
- Can be changed independently (e.g., add MFA without changing encryption)

**Current Spec**: None (new category)

---

### 2. Data-Protection (`data-protection`)

**Spec ID**: `data-protection-001`  
**Purpose**: Encryption, data at-rest, data in-transit, key management

**Independent Decisions**:
- Encryption at-rest (algorithm, key management, key rotation)
- Encryption in-transit (TLS version, cipher suites, certificate management)
- Data classification (public, internal, confidential, restricted)
- Encryption key storage and access (Azure Key Vault, HSM, etc.)
- Data masking for logs and backups
- Tokenization requirements
- Disk encryption (full disk vs volume encryption)
- Database encryption (TDE, column encryption)

**Examples**:
- "All data at-rest encrypted with AES-256"
- "TLS 1.2+ for all in-transit communication"
- "Encryption keys managed in Azure Key Vault"
- "Database encryption enabled with Transparent Data Encryption (TDE)"
- "Customer PII masked in logs and backups"

**Conflicts**:
- With cost (encryption key management infrastructure may increase costs)
- With infrastructure/storage (storage replication affects encryption scope)

**Reason for Independence**:
- Data protection is focused on confidentiality
- Distinct from access control (who can access) and audit logging (what happened)

**Current Spec**: security/001-cost-constrained-policies (partially; will extract data protection portions)

---

### 3. Audit-Logging (`audit-logging`)

**Spec ID**: `audit-logging-001`  
**Purpose**: Audit trails, logging, monitoring, compliance evidence, incident response

**Independent Decisions**:
- Audit log retention policies (how long to keep logs)
- Log aggregation and centralization (where logs go)
- Logging scope (what events are logged)
- Log integrity protection (immutable logs, log sealing)
- Real-time alerting (on what events)
- Backup and archival of audit logs
- Log access control (who can view logs)
- Log analysis and correlation tooling

**Examples**:
- "All authentication attempts logged (success and failure)"
- "Audit logs retained for 7 years"
- "Logs centralized in Azure Log Analytics"
- "Real-time alert on failed authentication >5x per user"
- "Audit logs archived to Azure Archive Storage after 1 year"

**Conflicts**:
- With cost (logging and retention are expensive)
- With infrastructure/cicd-pipeline (logging adds latency)

**Reason for Independence**:
- Audit-logging is about detecting and investigating incidents
- Distinct from data protection (encryption) and access control (who can do what)

**Current Spec**: None (new category; related to compliance but operational)

---

## Summary Table

| Category | Spec ID | Focus | Examples |
|----------|---------|-------|----------|
| Access-Control | access-control-001 | Who can access what | MFA, RBAC, key rotation |
| Data-Protection | data-protection-001 | Confidentiality of data | Encryption, key mgmt, Tls |
| Audit-Logging | audit-logging-001 | Detection and investigation | Log retention, alerts |

---

## Validation

- [X] 3+ categories defined
- [X] Each focuses on distinct security domain
- [X] Examples provided
- [X] Conflicts identified
- [X] Spec IDs assigned

---

## Next Steps

1. Peer review with CISO: Agree these categories decompose security domain correctly?
2. Integration with T005: Map existing security/001 to these categories
3. Integration with T006: Document security conflicts with other tiers
