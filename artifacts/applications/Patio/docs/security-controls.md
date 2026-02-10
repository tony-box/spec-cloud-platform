# Patio Security and Audit Controls

## Access Control

- SSH access uses key-based authentication only.
- Azure RBAC is enforced for resource access.
- VM managed identity is granted Key Vault Secrets User access.

## Data Protection

- AES-256 encryption at rest is required for storage and disks.
- TLS 1.2+ is required for in-transit traffic.
- Key Vault uses HSM-backed keys in production.

## Audit Logging

- Log Analytics workspace retains logs for 3 years.
- Key Vault diagnostic settings forward audit events and metrics.

## References

- specs/security/access-control/spec.md
- specs/security/data-protection/spec.md
- specs/security/audit-logging/spec.md
