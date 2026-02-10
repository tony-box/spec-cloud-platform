# Patio Rollout and Approval Gates

## Approval Gates

- Production deployments require infrastructure lead approval.
- Cost variance greater than 20% requires business owner approval.
- Security-related changes require security lead approval.

## Rollback Expectations

- Use deployment history to revert to the previous successful release.
- Validate health checks and critical paths after rollback.
- Record rollback outcomes in the validation log.

## Notes

- Workload criticality determines approval requirements and cost baselines.
- Update this document if governance rules change.
