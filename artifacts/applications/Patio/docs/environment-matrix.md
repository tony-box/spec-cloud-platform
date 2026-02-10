# Patio Environment Matrix

## Environment Summary

| Environment | Purpose | Workload Criticality | Region Policy | Approval Requirements |
| --- | --- | --- | --- | --- |
| dev | Developer integration and validation | dev-test | US-only | None |
| test | QA validation and pre-production checks | non-critical | US-only | None |
| prod | Production workloads | non-critical (confirm with product owner) | US-only | Infrastructure and security approval |

## Notes

- Workload criticality for production is assumed non-critical until confirmed.
- Production approvals follow business/governance requirements for infrastructure changes.
- Update this matrix if staging or sandbox environments are added.
