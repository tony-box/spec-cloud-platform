# Module Validation Checklist

**Purpose**: Ensure all wrapper modules satisfy platform compliance requirements before deployment.

**Usage**: Complete this checklist for each new wrapper module or version update.

---

## Module Information

- **Module Name**: _______________________
- **AVM Source**: _______________________
- **Wrapper Version**: _______________________
- **AVM Version**: _______________________
- **Date**: _______________________
- **Reviewer**: _______________________

---

## 1. Code Quality Validation (platform/iac-linting-001)

- [ ] `bicep build` passes without errors
- [ ] `bicep build` passes without warnings
- [ ] Code follows naming conventions: `<resource>-<purpose>`
- [ ] All parameters have `@description` decorators
- [ ] All outputs documented with comments
- [ ] README.md exists with usage examples
- [ ] parameters.json includes dev and prod examples

---

## 2. Cost Compliance (business/cost-001)

- [ ] SKU options restricted to cost-optimized tiers via `@allowed` decorator
- [ ] Default SKU is cost-optimized (Standard_B2s for VMs, Standard_LRS for storage)
- [ ] Production reserved instance pricing mode enabled (where applicable)
- [ ] No premium tiers exposed unless required by security/compliance
- [ ] Cost estimation documented in README.md

**Cost Validation Notes**:
- Dev default SKU: _______________________
- Prod default SKU: _______________________
- Estimated monthly cost (dev): $_______________________
- Estimated monthly cost (prod): $_______________________

---

## 3. Security Compliance (security/data-protection-001, security/access-control-001)

### Data Protection (dp-001)
- [ ] Encryption at rest enabled by default
- [ ] Encryption in transit enabled (TLS 1.2+ minimum)
- [ ] Key Vault integration for secrets (where applicable)
- [ ] Premium SKU enforced for prod Key Vault (HSM-backed)
- [ ] No plaintext secrets in parameters or outputs

### Access Control (ac-001)
- [ ] SSH key authentication enforced (no password parameter exposed)
- [ ] Managed identity enabled (where applicable)
- [ ] Azure RBAC authorization model used
- [ ] Network isolation enforced (VNet integration, firewall rules)
- [ ] Public access disabled by default (unless explicitly needed)

**Security Validation Notes**:
- Authentication method: _______________________
- Network access: _______________________
- Encryption method: _______________________

---

## 4. Compliance Requirements (business/compliance-framework-001)

- [ ] Location restricted to US regions only (`centralus`, `eastus`) via `@allowed` decorator
- [ ] Mandatory tags included: `compliance: nist-800-171`
- [ ] Backup retention meets requirements (7 days dev, 30 days prod)
- [ ] Soft delete enabled (where applicable)
- [ ] Audit logging enabled (diagnosticSettings configured)
- [ ] Data residency enforced (no cross-region replication to non-US)

**Compliance Validation Notes**:
- Allowed locations: _______________________
- Backup retention: _______________________
- Audit logging destination: _______________________

---

## 5. Parameter Validation

### Minimal Parameter Exposure
- [ ] Only application-customizable parameters exposed
- [ ] Security/compliance settings hidden (enforced via defaults)
- [ ] `@allowed` decorators restrict values to compliant options
- [ ] No `any` types used (all parameters strongly typed)

### Default Parameters
- [ ] All optional parameters have compliant defaults
- [ ] Defaults satisfy cost-001, dp-001, ac-001, comp-001
- [ ] Environment-aware defaults (dev vs prod)
- [ ] Defaults documented in README.md

**Parameter Review**:
- Total exposed parameters: _______________________
- Required parameters: _______________________
- Optional parameters with defaults: _______________________

---

## 6. Output Validation

- [ ] All outputs documented with `@description` decorators
- [ ] Resource IDs exported for downstream module references
- [ ] No sensitive data exported (secrets, keys, passwords)
- [ ] Outputs match documented API in README.md

**Output Review**:
- Total outputs: _______________________
- Resource ID outputs: _______________________
- Sensitive outputs (should be 0): _______________________

---

## 7. Documentation Validation

- [ ] README.md includes overview and purpose
- [ ] README.md documents all parameters with types and defaults
- [ ] README.md documents all outputs
- [ ] README.md includes usage examples (dev and prod)
- [ ] README.md documents upstream spec dependencies
- [ ] README.md includes compliance notes
- [ ] parameters.json includes realistic examples

---

## 8. AVM Integration Validation

- [ ] AVM module referenced via `br/public:` registry
- [ ] AVM version pinned (no `latest` tag)
- [ ] AVM module version documented in avm-versions.md
- [ ] Wrapper passes all required parameters to AVM module
- [ ] Wrapper overrides non-compliant AVM defaults
- [ ] No direct resource definitions (wrapper pattern maintained)

**AVM Integration Notes**:
- AVM module path: _______________________
- AVM version: _______________________
- Parameters passed to AVM: _______________________

---

## 9. Testing Validation (Optional - if not skipped)

- [ ] Module deploys successfully in dev subscription
- [ ] Deployed resources match expected configuration
- [ ] Cost estimates match actual deployed costs
- [ ] Security scan passes (no policy violations)
- [ ] Compliance scan passes (NIST 800-171 tags present)

**Test Results** (if performed):
- Test subscription: _______________________
- Test resource group: _______________________
- Deployment status: _______________________
- Validation errors: _______________________

---

## 10. Final Approval

- [ ] All checklist items complete
- [ ] No blockers or exceptions
- [ ] Module ready for application team consumption
- [ ] Version tagged in Git (if applicable)
- [ ] Changelog updated

**Approval**:
- Reviewer Name: _______________________
- Approval Date: _______________________
- Module Status: [ ] Approved  [ ] Needs Revisions  [ ] Rejected

**Revision Notes** (if needed):
_______________________
_______________________
_______________________

---

## Exceptions & Waivers

Document any exceptions to compliance requirements (requires governance approval):

| Requirement | Exception Reason | Approved By | Approval Date | Expiration |
|-------------|------------------|-------------|---------------|------------|
| | | | | |

---

**Document Version**: 1.0.0  
**Created**: 2026-02-07  
**Owner**: Infrastructure Engineering Team  
**Related Specs**: iac-001, cost-001, dp-001, ac-001, comp-001, lint-001
