# Research: mycoolapp LAMP Stack

**Date**: 2026-02-05  
**Scope**: Application runtime, deployment model, criticality, and region selection

## Decisions

### Decision 1: LAMP stack on Ubuntu 22.04 LTS
- **Decision**: Use Ubuntu 22.04 LTS with Apache 2.4, PHP 8.2, and MySQL 8.0
- **Rationale**: Simple application with low operational complexity; widely supported stack; aligns with cost-optimized single VM deployment
- **Alternatives considered**: Node.js + Nginx, Python + Gunicorn, Java + Tomcat

### Decision 2: Single VM deployment (all LAMP components)
- **Decision**: Run Apache, PHP, and MySQL on a single VM for both production and dev/test
- **Rationale**: Lowest cost and simplest operational footprint; meets non-critical SLA requirements
- **Alternatives considered**: Web VM + Azure Database for MySQL Flexible Server, containerized deployment

### Decision 3: Non-critical workload (99% SLA)
- **Decision**: Non-critical workload using a single-zone VM
- **Rationale**: Acceptable availability trade-off to meet cost reduction targets
- **Alternatives considered**: Critical tier (99.95% SLA with zone redundancy)

### Decision 4: Region
- **Decision**: Deploy in `centralus`
- **Rationale**: User-selected region; central region coverage for initial rollout
- **Alternatives considered**: `eastus`, `westeurope`

### Decision 5: Testing approach
- **Decision**: PHPUnit for application tests and basic deployment smoke tests
- **Rationale**: Standard for PHP applications; minimal setup overhead
- **Alternatives considered**: PestPHP, Behat
