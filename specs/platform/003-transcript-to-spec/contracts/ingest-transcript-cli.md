# Contracts: transcript-to-specs Toolkit

**Branch**: `003-transcript-to-spec` | **Date**: 2026-03-17 | **Phase**: 1 | **Location**: `specs/platform/003-transcript-to-spec/`  
**Primary interface**: `transcript-to-specs` VS Code agent mode (Copilot Chat)  
**Toolkit scripts**: `register-category.ps1` + `write-spec.ps1` (called BY the agent; also independently usable from CI)

---

## Agent Invocation

The user invokes the agent by opening Copilot Chat in VS Code and typing:

```
@transcript-to-specs Please process this transcript: <path-to-transcript.md>
```

The agent reads the transcript file, conducts the full analysis-to-write session in chat, and calls the toolkit scripts for all file operations. No terminal commands or separate script invocations are required from the user.

---

## Script 1: `register-category.ps1`

**Path**: `.specify/scripts/powershell/register-category.ps1`  
**Execution Mode**: script-enforced  
**Called by**: `transcript-to-specs` agent (after user confirms new category); also usable directly from CI

### Parameters

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `-Tier` | string | **Yes** | — | One of the 6 known tiers (`business`, `security`, `infrastructure`, `devops`, `platform`, `application`) |
| `-CategoryName` | string | **Yes** | — | Human-readable name (used in `_categories.yaml` `name:` field) |
| `-SpecId` | string | **Yes** | — | Globally unique spec-id, must match `^[a-z][a-z0-9-]{1,7}$` |
| `-Description` | string | **Yes** | — | One-sentence description of the category |

### Invocation Examples

```powershell
# Register a new category
./register-category.ps1 -Tier business -CategoryName "Disaster Recovery" -SpecId dr -Description "Business continuity and DR objectives"

# Idempotent re-run (spec-id already exists) — exits 0 silently
./register-category.ps1 -Tier business -CategoryName "Disaster Recovery" -SpecId dr -Description "Business continuity and DR objectives"
```

### Outputs

| Output | Description |
|---|---|
| `specs/<tier>/_categories.yaml` | Entry appended (or created as bootstrap skeleton); `category-count` incremented |
| `specs/specs.yaml` | `category-count` for the tier incremented |

### Exit Codes

| Code | Meaning |
|---|---|
| `0` | Category registered (or already present — idempotent) |
| `1` | Validation failure (invalid tier, invalid spec-id format, duplicate spec-id, missing parameters) |

---

## Script 2: `write-spec.ps1`

**Path**: `.specify/scripts/powershell/write-spec.ps1`  
**Execution Mode**: script-enforced  
**Called by**: `transcript-to-specs` agent (after user confirms grouping plan and any conflict resolution); also usable directly from CI

### Parameters

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `-Tier` | string | **Yes** | — | Target tier |
| `-Category` | string | **Yes** | — | Target category directory name |
| `-SpecId` | string | **Yes** | — | Spec-id for the generated spec |
| `-FrontmatterJson` | string (JSON) | **Yes** | — | JSON object with all required frontmatter fields; `status: draft` enforced regardless of input |
| `-BodyMarkdown` | string | **Yes** | — | Markdown body content (Executive Summary, Requirements, Decisions, Constraints) |
| `-Force` | switch | No | `$false` | Overwrite existing `spec.md` if present |

### Invocation Examples

```powershell
# Write a new spec (agent-generated frontmatter JSON)
$fm = '{"tier":"business","category":"cost","spec-id":"cost","version":"1.0.0-draft","status":"draft","compliance-state":"current","role-context":{"requested-by":"transcript-to-specs","decision-mode":"autonomous"}}'
./write-spec.ps1 -Tier business -Category cost -SpecId cost -FrontmatterJson $fm -BodyMarkdown $body

# Write a spec with conflict flags
$fm = '{"tier":"devops","category":"ci-cd-orchestration","spec-id":"cicd","conflict-flags":[{"conflicts-with":"security/access-control","reason":"Zero-friction deploy vs change-board approval (REQ-AC-007)"}],"version":"1.0.0-draft","status":"draft","compliance-state":"current","role-context":{"requested-by":"transcript-to-specs","decision-mode":"autonomous"}}'
./write-spec.ps1 -Tier devops -Category ci-cd-orchestration -SpecId cicd -FrontmatterJson $fm -BodyMarkdown $body

# Overwrite an existing draft (additive update confirmed by user)
./write-spec.ps1 -Tier business -Category cost -SpecId cost -FrontmatterJson $fm -BodyMarkdown $updatedBody -Force
```

### Outputs

| Output | Condition |
|---|---|
| `specs/<tier>/<category>/spec.md` written | File does not exist, or `-Force` is set |
| Exit 2 (skip), no file written | File already exists and `-Force` not set |

### Conflict-Flag Injection

If `-FrontmatterJson` includes a `conflict-flags` array, `write-spec.ps1`:
1. Adds a `conflict-flags:` block to the YAML frontmatter
2. Prepends a `## ⚠️ Conflict Flags` section to the spec body listing each flagged upstream spec and the reason

### Exit Codes

| Code | Meaning |
|---|---|
| `0` | Spec file written successfully |
| `1` | Validation failure (missing parameters, invalid frontmatter JSON, path traversal detected, write error) |
| `2` | Spec file already exists and `-Force` not set (skip, not an error) |

---

## Idempotency

| Scenario | Behaviour |
|---|---|
| `register-category.ps1` run twice with same `-SpecId` | Second run: exits 0 silently; no duplicate entry added |
| `write-spec.ps1` run twice without `-Force` | Second run: exits 2 (skip); existing file unchanged |
| `write-spec.ps1` run twice with `-Force` | Second run: file overwritten |
| `specs.yaml` `category-count` already correct | `register-category.ps1` reads before writing; no double-increment |

---

## Prerequisite Checks

`register-category.ps1` exits 1 if:
- `-Tier` not in `$script:SpecTiers`
- `-CategoryName` does not match `^[a-z][a-z0-9-]+$`
- `-SpecId` does not match `^[a-z][a-z0-9-]{1,7}$`
- `-SpecId` already exists in the global spec-id catalog (uniqueness enforced)

`write-spec.ps1` exits 1 if:
- Any required parameter is missing or empty
- `-FrontmatterJson` is not parseable via `ConvertFrom-Json`
- Required frontmatter fields are absent after parsing
- Resolved target path would escape the repo root (path traversal check)

---

## Toolkit Registration

Both scripts must be registered in `specs.yaml` toolkit-components.scripts:

```yaml
register-category.ps1:
  purpose: "Register a new category in _categories.yaml and specs.yaml"
  contracts:
    input: "tier, category-name, spec-id, description"
    output: "_categories.yaml entry added; specs.yaml category-count incremented"
    idempotent: true

write-spec.ps1:
  purpose: "Write a compliant spec.md draft from frontmatter JSON and body markdown"
  contracts:
    input: "tier, category, spec-id, frontmatter JSON, body markdown"
    output: "spec.md created at specs/<tier>/<category>/spec.md"
    idempotent: false
    exit-codes: { 0: success, 1: validation-failure, 2: file-exists-skipped }
```

