# Compliance Checklist: mycoolapp LAMP Deployment

**Application**: mycoolapp  
**Deployment Date**: 2026-02-07  
**Compliance Framework**: NIST 800-171 (Controlled Unclassified Information)  
**Review Status**: Pending

---

## NIST 800-171 Control Mapping

### AC-2: Account Management

- [ ] **AC-2.1**: Cloud: Account identities and subscriptions are managed in Azure AD
- [ ] **AC-2.2**: Local VM admin account disabled (SSH key-based only)
- [ ] **AC-2.3**: SSH key rotated and stored securely
- [ ] **AC-2.4**: Service accounts for applications use managed identities
- [ ] **AC-2.5**: Inactive accounts reviewed quarterly

**Status**: ◯ Pending Verification

---

### AU-2: Audit Events

- [ ] **AU-2.1**: Azure activity logging enabled for resource group
- [ ] **AU-2.2**: Application logs collected (Apache, PHP, MySQL)
- [ ] **AU-2.3**: Log retention: Minimum 12 months
- [ ] **AU-2.4**: Log integrity protection configured
- [ ] **AU-2.5**: OS kernel audit enabled via auditd

**Status**: ◯ Pending Verification

---

### AU-3: Content of Audit Records

- [ ] **AU-3.1**: All audit records include: date, time, user, event type, success/failure
- [ ] **AU-3.2**: Apache access logs include: source IP, timestamp, method, URL, status code
- [ ] **AU-3.3**: MySQL query logs capture DML/DDL statements
- [ ] **AU-3.4**: SSH connection logs captured
- [ ] **AU-3.5**: Failed authentication attempts logged

**Status**: ◯ Pending Verification

---

### SC-7: Boundary Protection

- [ ] **SC-7.1**: Network Security Group (NSG) restricts inbound to 22 (SSH), 80 (HTTP), 443 (HTTPS)
- [ ] **SC-7.2**: Outbound traffic: Default deny, exceptions documented
- [ ] **SC-7.3**: No direct RDP (port 3389) access
- [ ] **SC-7.4**: Load balancer (if multi-VM) operates in firewall mode
- [ ] **SC-7.5**: VNet isolation from other applications

**Status**: ◯ Pending Verification

---

### SC-8: Transmission Confidentiality

- [ ] **SC-8.1**: HTTPS (TLS 1.2+) enforced for all web traffic
- [ ] **SC-8.2**: HTTP-to-HTTPS redirect configured
- [ ] **SC-8.3**: TLS certificates signed by trusted CA (not self-signed for production)
- [ ] **SC-8.4**: Database connections use TLS/SSL
- [ ] **SC-8.5**: SSH key exchange uses strong algorithms (Ed25519 recommended)

**Status**: ◯ Pending Verification

---

### SC-13: Cryptographic Protection

- [ ] **SC-13.1**: Storage encryption at-rest enabled (Azure Disk Encryption)
- [ ] **SC-13.2**: Encryption algorithm: AES-256
- [ ] **SC-13.3**: Master keys stored in Azure Key Vault
- [ ] **SC-13.4**: MySQL database encryption enabled (transparent data encryption)
- [ ] **SC-13.5**: Encryption keys rotated annually

**Status**: ◯ Pending Verification

---

### IA-2: Authentication

- [ ] **IA-2.1**: SSH public key authentication (no password login)
- [ ] **IA-2.2**: Multi-factor authentication for Azure AD accounts
- [ ] **IA-2.3**: Service principals use managed identities
- [ ] **IA-2.4**: Session timeout configured (15-30 minutes)
- [ ] **IA-2.5**: Privileged operations require explicit authentication

**Status**: ◯ Pending Verification

---

### IA-5: Authentication Mechanisms

- [ ] **IA-5.1**: Passwords (MySQL root) stored securely (16+ chars, complex)
- [ ] **IA-5.2**: SSH keys: Minimum 2048-bit RSA or Ed25519
- [ ] **IA-5.3**: Key material protected from unauthorized disclosure
- [ ] **IA-5.4**: SSH keys rotated annually or upon compromise suspicion
- [ ] **IA-5.5**: No hardcoded credentials in code/config

**Status**: ◯ Pending Verification

---

### SI-4: System Monitoring

- [ ] **SI-4.1**: Azure Monitor agent installed on VM
- [ ] **SI-4.2**: Real-time monitoring: CPU, memory, disk, network
- [ ] **SI-4.3**: Security alerts configured for anomalies
- [ ] **SI-4.4**: Web Application Firewall (WAF) enabled (if applicable)
- [ ] **SI-4.5**: DDoS protection enabled

**Status**: ◯ Pending Verification

---

### CM-2: Baseline Configuration

- [ ] **CM-2.1**: Baseline configuration documented (OS, Apache, PHP, MySQL versions)
- [ ] **CM-2.2**: Configuration templates version-controlled in Git
- [ ] **CM-2.3**: Approved changes tracked in configuration management system
- [ ] **CM-2.4**: Deviations from baseline documented and approved
- [ ] **CM-2.5**: Rollback procedures defined

**Status**: ◯ Pending Verification

---

### CM-3: Change Control

- [ ] **CM-3.1**: Change requests reviewed and approved before deployment
- [ ] **CM-3.2**: Changes tested in NONPROD before production deployment
- [ ] **CM-3.3**: Change logs audit trail maintained
- [ ] **CM-3.4**: Emergency changes documented with post-implementation review
- [ ] **CM-3.5**: High-risk changes require Change Advisory Board (CAB) approval

**Status**: ◯ Pending Verification

---

### SI-2: Flaw Remediation

- [ ] **SI-2.1**: OS patch policy: Security patches applied within 30 days
- [ ] **SI-2.2**: Application updates monitored (Apache, PHP, MySQL)
- [ ] **SI-2.3**: Vulnerability scanning performed on VM monthly
- [ ] **SI-2.4**: Zero-day vulnerabilities tested and prioritized
- [ ] **SI-2.5**: Patch testing procedure documented

**Status**: ◯ Pending Verification

---

### PE-3: Physical Access Control

- [ ] **PE-3.1**: Data center access restricted to authorized personnel (Azure handles)
- [ ] **PE-3.2**: Visitor access logged and monitored (Azure handles)
- [ ] **PE-3.3**: Security clearance required for sensitive areas (Azure handles)
- [ ] **PE-3.4**: Asset tracking for hardware (N/A - cloud-managed)
- [ ] **PE-3.5**: Anti-theft measures (N/A - cloud-managed)

**Status**: ◯ Azure Managed - Out of Scope

---

## Cost Reduction Target Validation (business/001)

- [ ] **10% Cost Reduction** achieved through:
  - ✓ Reserved instances (3-year term) vs on-demand pricing
  - ✓ Cost-optimized SKU (Standard_B4ms for prod, Standard_B2s for dev)
  - ✓ Standard storage (not Premium)
  - ✓ Single availability zone for non-critical workload
  - [ ] Estimated monthly cost: $ _______
  - [ ] Baseline cost: $ _______
  - [ ] Reduction percentage: _____ %

**Status**: ◯ Pending Cost Verification

---

## Deployment Artifacts Compliance

- [ ] All Bicep templates stored in version control (Git)
- [ ] All scripts include audit logging and error handling
- [ ] Documentation complete: README, quickstart, runbook
- [ ] Secrets stored in Azure Key Vault (not in code)
- [ ] Deployment process automated via CI/CD pipeline
- [ ] Regular backup and disaster recovery tested

**Status**: ◯ Pending Artifacts Review

---

## Sign-Off

**Compliance Officer**: _________________________ **Date**: _____________

**Application Owner**: _________________________ **Date**: _____________

**Security Lead**: _________________________ **Date**: _____________

---

## Notes & Exceptions

*Any deviations from NIST 800-171 controls should be documented with business justification and compensating controls:*

1. _____________________________________________________________________
2. _____________________________________________________________________
3. _____________________________________________________________________

---

**Version**: 1.0.0  
**Last Updated**: 2026-02-07  
**Next Review**: 2026-08-07 (6-month cycle or upon changes)
