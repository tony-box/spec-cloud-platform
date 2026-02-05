# Implementation Plan: Application Artifact Organization Standard

**Branch**: `platform-001-app-artifact-org` | **Date**: 2026-02-05 | **Spec**: [platform-001-application-artifact-organization](spec.md)  
**Input**: Platform specification from `/specs/platform/001-application-artifact-organization/spec.md`

---

## 🎯 IMPORTANT: Role Declaration Protocol (Per Constitution §II)

This plan was created via:
- **Role Declared**: Platform
- **Application Target**: N/A (Platform tier)
- **Source Tier Specs**: Constitution §I (Spec-Driven Development), Constitution §II (Role Declaration)

> Constitution §II requires ALL spec updates (and derived plans) to maintain role declaration context. This plan implements the Platform spec for standardized application artifact organization.

---

## Summary

This plan implements a standardized artifact directory structure for applications across the platform. Instead of scattered artifacts in `/artifacts/`, all application artifacts will be organized under `/artifacts/applications/<appname>/` with consistent subdirectories for different artifact types (IaC, modules, scripts, pipelines, documentation).

**Key Outcome**: Multi-application platform with clean, consistent, governance-friendly artifact organization.

**Timeline**: 12 weeks (by 2026-05-05)
- Phase 1: Define & Create Templates (Week 1)
- Phase 2: Migrate Existing Artifacts (Weeks 2-4)
- Phase 3: Enforce & Automate (Weeks 5-12)

---

## Technical Context

**Language/Approach**: Platform governance + tooling
- Core: PowerShell/Bash scripts for automation
- Validation: JSON schema for directory structure validation
- Documentation: Markdown guides and examples

**Primary Dependencies**:
- Git/GitHub (for artifact storage)
- Azure CLI (for deployment)
- GitHub Actions (for automation)

**Target Platforms**: All applications managed by this platform
- New applications (created post-2026-02-05)
- Existing applications (cost-optimized-demo, payment-service, etc.)

**Project Type**: Platform governance framework

**Performance Goals**: Directory structure validation must complete in <1 second

**Constraints**: 
- Backward compatibility required during 90-day migration period
- Must not break existing deployments
- Quality gates must validate structure without false failures

**Scale/Scope**: 
- Support 5-50+ applications
- Support 1000+ artifact files per application
- Support parallel deployments by multiple teams

---

## Constitution Check: Tier Alignment & Spec Cascading

### Tier Alignment ✅
- **This Plan is**: Platform tier implementation plan
- **Parent Specs**: Constitution §I (Spec-Driven Development), Constitution §II (Role Declaration)
- **Downstream Impact**: All Application-tier specs will reference artifacts in `/artifacts/applications/<appname>/`
- **Cascade Direction**: Platform → Infrastructure (IaC generation) → Application (artifact usage)

### Spec Compliance ✅
- **Principle I (Spec-Driven)**: ✅ Artifacts will originate from application-tier specs, organized in app-specific directories
- **Principle II (Role Declaration)**: ✅ This plan created via explicit Platform role declaration
- **Principle III (Cascading)**: ✅ When infrastructure specs are updated, new IaC artifacts automatically go to app-specific directory
- **Principle IV (Human-in-Loop)**: ✅ All generated directory templates reviewed before distribution
- **Principle V (Traceability)**: ✅ Each application artifact directory includes README.md linking to source spec

---

## Phase 1: Define Standard & Create Templates (Week 1)

### Goal
Ratify the specification and create reusable templates that application teams can use to create standardized directory structures.

### Artifacts to Generate

#### 1. Directory Structure Template
**Output**: `/artifacts/.templates/application-artifact-template/`

```
application-artifact-template/
├── README.md (explaining structure)
├── iac/
│   └── README.md (IaC-specific guidance)
├── modules/
│   └── README.md (Modules guidance)
├── scripts/
│   └── README.md (Scripts guidance)
├── pipelines/
│   └── README.md (Pipelines guidance)
└── docs/
    └── README.md (Documentation guidance)
```

**Deliverable**: Template directory with README.md files explaining:
- Purpose of each subdirectory
- Naming conventions (e.g., `<appname>-<component>.bicep`)
- Example files
- Links to specification

#### 2. Directory Creation Script
**Output**: `artifacts/.templates/scripts/create-app-directory.ps1`

```powershell
# Usage: ./create-app-directory.ps1 -AppName "payment-service"
# Creates: /artifacts/applications/payment-service/ with full structure
```

**Deliverable**: PowerShell script that:
- Creates `/artifacts/applications/<appname>/` directory
- Creates all 5 subdirectories (iac, modules, scripts, pipelines, docs)
- Populates each with README.md from template
- Generates app-specific .gitignore files
- Outputs confirmation message

#### 3. Artifact Organization Guide
**Output**: `/ARTIFACT_ORGANIZATION_GUIDE.md`

**Deliverable**: Comprehensive documentation including:
- Standard directory structure diagram
- Naming conventions per artifact type
- Examples (payment-service, web-app-001, etc.)
- How to create a new app artifact directory
- How to reference artifacts in GitHub Actions
- Migration path for existing artifacts

#### 4. Validation Schema
**Output**: `/artifacts/.templates/schemas/artifact-structure.json`

**Deliverable**: JSON schema that validates:
- Directory structure exists
- Required subdirectories present (or documented as optional)
- README.md files exist in each directory
- Naming conventions respected
- Required files (.gitignore, etc.) in place

### Acceptance Criteria
- ✅ Directory template created and can be cloned by teams
- ✅ Directory creation script tested successfully
- ✅ ARTIFACT_ORGANIZATION_GUIDE.md published and clear
- ✅ Validation schema tested against examples

---

## Phase 2: Migrate Existing Artifacts (Weeks 2-4)

### Goal
Move existing application artifacts (cost-optimized-demo) to new structure while maintaining backward compatibility.

### Tasks

#### 1. Audit Existing Artifacts
**Output**: Migration plan document

**Steps**:
1. Inventory all artifacts in `/artifacts/`
2. Categorize by artifact type (Bicep, Python, PowerShell, etc.)
3. Map to applications (cost-optimized-demo, etc.)
4. Identify dependencies/cross-references
5. Document migration steps needed

**Deliverable**: `MIGRATION_PLAN.md` documenting what moves where

#### 2. Create New Application Directory
**Run**: `./create-app-directory.ps1 -AppName "cost-optimized-demo"`

**Creates**: `/artifacts/applications/cost-optimized-demo/` with structure

#### 3. Migrate Artifacts
**Move**:
- `artifacts/bicep/compute-reserved-instance.bicep` → `artifacts/applications/cost-optimized-demo/iac/`
- `artifacts/scripts/cost-calculator.py` → `artifacts/applications/cost-optimized-demo/scripts/`
- `artifacts/scripts/demo-cascade.ps1` → `artifacts/applications/cost-optimized-demo/scripts/`
- `DEMO_WALKTHROUGH.md` → `artifacts/applications/cost-optimized-demo/docs/`
- `DEMO_IMPLEMENTATION.md` → `artifacts/applications/cost-optimized-demo/docs/`

#### 4. Create Backward Compatibility Layer
**Option A**: Symlinks
```powershell
# /artifacts/bicep → /artifacts/applications/cost-optimized-demo/iac (symlink)
# /artifacts/scripts → /artifacts/applications/cost-optimized-demo/scripts (symlink)
```

**Option B**: Documentation redirect
```
# /artifacts/README.md explains old structure is deprecated
# Points teams to new structure
```

**Decision**: Use Option B (documentation) + Remove symlinks by 2026-03-31

#### 5. Update References
**Update files that reference old paths**:
- `demo-cascade.ps1` - Update to reference new paths
- Any GitHub Actions workflows - Update artifact paths
- Platform documentation - Update examples

**Acceptance Criteria**:
- ✅ All artifacts moved to app-specific directories
- ✅ Old paths have deprecation notices (if symlinks used)
- ✅ All references updated
- ✅ Deployments still work from new locations
- ✅ No broken links or missing files

---

## Phase 3: Enforce & Automate (Weeks 5-12)

### Goal
Implement automated validation and quality gates to enforce the standard going forward.

### 1. Quality Gate: Directory Structure Validation

**Trigger**: When artifacts are committed or during CI/CD pipeline

**Validation Script**: `artifacts/.templates/scripts/validate-artifact-structure.ps1`

```powershell
# Validates:
# - Directory exists: /artifacts/applications/<appname>/
# - Subdirectories exist (or documented as optional)
# - README.md files present
# - Naming conventions followed
# - No artifacts in /artifacts/ root (except .templates/)
```

**Integration**: Add to GitHub Actions as pre-deployment quality gate

**Failure Behavior**: Block deployment if structure invalid; suggest fixes

#### 2. GitHub Actions Template Update

**Create**: `/artifacts/applications/.templates/workflows/deploy-application.yml`

**Updates**:
```yaml
name: Deploy Application

on:
  push:
    paths:
      - 'artifacts/applications/${{ github.event.repository.name }}/iac/**'

env:
  APP_NAME: ${{ github.event.repository.name }}
  ARTIFACT_PATH: artifacts/applications/${{ env.APP_NAME }}

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Validate artifact structure
        run: |
          ./${{ env.ARTIFACT_PATH }}/scripts/validate-structure.ps1
          
  deploy:
    runs-on: ubuntu-latest
    needs: validate
    steps:
      - uses: actions/checkout@v3
      - name: Deploy IaC
        run: |
          az deployment group create \
            --resource-group ${{ env.APP_NAME }} \
            --template-file ${{ env.ARTIFACT_PATH }}/iac/main.bicep
```

**Key**: Pipeline is parameterized by app name; automatically targets correct artifact path

#### 3. Platform Documentation Updates

**Update**: `/ARTIFACT_ORGANIZATION_GUIDE.md`
- Add quality gate validation rules
- Add GitHub Actions examples
- Add troubleshooting section

**Create**: `/ARTIFACT_ORGANIZATION_COMPLIANCE.md`
- List quality gates
- Explain failure scenarios
- Provide remediation steps

#### 4. Team Training

**Create**: Training materials (optional, by 2026-04-30)
- Video walkthrough: "How to organize your application artifacts"
- Quick reference card: Directory structure diagram
- FAQ: Common questions and answers

### Acceptance Criteria
- ✅ Validation script works correctly
- ✅ GitHub Actions template parameterized and tested
- ✅ Quality gates block invalid structures
- ✅ Documentation updated
- ✅ 0 false-failure rate in validation

---

## Phase 4: Sunset Old Structure (by 2026-03-31)

### Goal
Remove backward compatibility and clean up old artifact locations.

### Tasks
1. Confirm all migrations complete
2. Remove symlinks (if used) or deprecation notices
3. Delete old artifact directories (/artifacts/bicep/, /artifacts/scripts/, etc.)
4. Archive old structure for audit trail (git history preserved)
5. Announce sunset completion

### Acceptance Criteria
- ✅ All artifacts in new structure
- ✅ Old directories removed (git history preserved)
- ✅ No deployments break
- ✅ Team communication sent

---

## Risks & Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|-----------|
| Teams can't find migrated artifacts | Medium | High | Clear documentation + migration guide + office hours |
| Backward compatibility symlinks break | Low | Medium | Extensive testing before removal; 90-day warning |
| CI/CD pipelines break during migration | Medium | High | Parallel testing of old & new paths; gradual cutover |
| Validation script has false failures | Medium | Medium | Thorough testing; allow override for exceptions |
| Teams resist new structure | Low | Medium | Clear benefits explanation; enforcement via quality gates |

---

## Success Metrics

- **SM-001**: 100% of new applications created after 2026-02-05 use new structure
- **SM-002**: 100% of existing applications migrated by 2026-03-31
- **SM-003**: Validation script has 0% false-failure rate in production
- **SM-004**: GitHub Actions pipelines parameterized by app name (0 hard-coded paths)
- **SM-005**: Developer onboarding time reduced by 20% (measured by survey)
- **SM-006**: Artifact organization guideline compliance: 100%

---

## Timeline & Deliverables

| Week | Phase | Deliverable | Owner | Status |
|------|-------|-------------|-------|--------|
| 1 | Phase 1 | Spec ratified, templates created, guide published | Platform | ⏳ To Do |
| 2-4 | Phase 2 | Existing artifacts migrated, backward compat active | Platform | ⏳ To Do |
| 5-6 | Phase 3 | Validation script + GitHub Actions template | Platform | ⏳ To Do |
| 7-8 | Phase 3 | Quality gates integrated, documentation updated | Platform | ⏳ To Do |
| 9-12 | Phase 3 | Team training, exceptions handling | Platform | ⏳ To Do |
| ~13 | Phase 4 | Old structure sunset | Platform | ⏳ To Do |

---

## Open Decisions

- **DECISION NEEDED**: Should we version artifacts per application or keep platform-level versioning?
- **DECISION NEEDED**: Symlinks vs documentation redirect for backward compatibility?
- **DECISION NEEDED**: Should validation be hard-block (fail deployment) or soft-block (warn only)?

---

## Sign-Off

**Specification Ratified**: Yes ✅  
**Implementation Plan Approved**: Pending  
**Ready for Phase 1**: Pending approval  

**Next Steps**:
1. ✅ Get feedback on this plan
2. ⏳ Ratify specification (Constitution compliant)
3. ⏳ Begin Phase 1 (Week 1)

---

**Plan Status**: Draft  
**Created**: 2026-02-05  
**Branch**: `platform-001-app-artifact-org`  
**Next Step**: Team review & approval