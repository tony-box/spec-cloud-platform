---
# YAML Frontmatter - Category-Based Spec System
tier: security
category: access-control
spec-id: ac-001
version: 1.0.0-draft
status: draft
created: 2026-02-07
description: "Authentication, authorization, RBAC, SSH keys only (no passwords), MFA"

# Dependencies
depends-on: []

# Precedence rules
precedence:
  overrides:
    - tier: business
      category: governance
      spec-id: gov-001
      reason: "Access control is foundational; governance includes break-glass exceptions for security incidents"

# Relationships
adhered-by:
  - app-id: mycoolapp
    version: "1.0.0"
    compliance: "SSH keys only, Azure RBAC, MFA for privileged access"
---

# Specification: Access Control

**Tier**: security  
**Category**: access-control  
**Spec ID**: ac-001  
**Created**: 2026-02-07  
**Status**: Draft  

## Executive Summary

**Problem**: Without proper access control:
- Unauthorized users can access sensitive systems
- Password-based authentication is vulnerable to brute force
- No MFA leads to credential theft
- Overprivileged users violate least privilege

**Solution**: Enforce SSH key authentication, Azure RBAC, MFA for privileged access, and least privilege principle.

**Impact**: All access is authenticated, authorized, and audited; no password authentication permitted.

## Requirements

### Functional Requirements

- **REQ-001**: SSH access MUST use key-based authentication only (no passwords)
- **REQ-002**: All Azure resources MUST use Azure RBAC for authorization
- **REQ-003**: Privileged access MUST require MFA (multi-factor authentication)
- **REQ-004**: All access MUST follow least privilege principle
- **REQ-005**: All authentication attempts MUST be logged and auditable

### Authentication Methods

**SSH Access**:
- SSH keys only (RSA 4096-bit or Ed25519)
- Password authentication disabled globally
- Key rotation: Every 180 days
- Key storage: Azure Key Vault or secure key management system

**Azure Access**:
- Azure AD authentication required
- Service principals: Managed identities preferred over secrets
- MFA required for: Admin roles, production access, sensitive operations
- Conditional access policies: Require device compliance, network location

**Break-Glass Accounts**:
- Emergency access accounts: 2 accounts maintained
- Storage: Physical safe, not electronic
- Usage: Security incidents only
- Audit: Immediate review within 24 hours of use

### Authorization (RBAC)

**Azure RBAC Roles**:
- Reader: View-only access (all users by default)
- Contributor: Deploy/modify resources (infrastructure team)
- Owner: Full control including RBAC (platform team only)
- Custom roles: Least privilege (application-specific)

**Linux VM Access**:
- Standard user: Non-privileged access
- Sudo access: Requires approval and MFA
- Root access: Prohibited (use sudo instead)

**Least Privilege**:
- Users granted minimum permissions needed
- Periodic access reviews: Quarterly
- Unused permissions revoked automatically: 90 days inactivity

### Multi-Factor Authentication (MFA)

**MFA Required For**:
- All admin roles (Global Admin, Security Admin, etc.)
- Production environment access
- Sensitive operations (delete, modify RBAC, etc.)
- VPN access to corporate network

**MFA Methods**:
- Preferred: Microsoft Authenticator app, FIDO2 security keys
- Acceptable: SMS (with risk awareness)
- Prohibited: Email-based OTP (phishable)

## Success Criteria

- **SC-001**: 100% SSH access uses key-based authentication (zero password auth)
- **SC-002**: 100% Azure RBAC enforced (no shared accounts)
- **SC-003**: 100% privileged access requires MFA
- **SC-004**: All access attempts logged and auditable
- **SC-005**: Quarterly access reviews completed

## Change Log

| Version | Date | Change | Approved By |
|---------|------|--------|------------|
| 1.0.0-draft | 2026-02-07 | Initial access control spec | Security Team Lead |

---

**Spec Version**: 1.0.0-draft  
**Created**: 2026-02-07
