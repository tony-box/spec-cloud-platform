# Data Model: AI Transcript Ingestion

**Branch**: `003-transcript-to-spec` | **Date**: 2026-03-17 (updated 2026-03-19) | **Phase**: 1 | **Location**: `specs/platform/003-transcript-to-spec/`

---

## Entities

### TranscriptDocument

The input artifact provided by the user.

| Field | Type | Description |
|---|---|---|
| `FilePath` | string (file path) | Absolute path to transcript file on disk |
| `Content` | string | Raw text content of the transcript |
| `InferredDate` | string (ISO date) \| null | Meeting date extracted from transcript header or filename |
| `Participants` | string[] | Participant names/roles extracted from transcript |
| `Purpose` | string \| null | One-sentence meeting purpose extracted from transcript |

**Validation rules**:
- `FilePath` must exist and be readable
- `Content` must be non-empty
- `Content` length ≤ 500,000 characters (practical AI context limit)
- If `FilePath` does not exist, is unreadable, or `Content` is empty → agent aborts immediately (Phase 1 error, see Decision 10)

---

### CategoryCatalog

In-memory snapshot of the current spec registry, built from `specs.yaml` + all `*/_categories.yaml` files before any writes occur.

| Field | Type | Description |
|---|---|---|
| `Tiers` | TierEntry[] | All known tiers from `specs.yaml` |
| `Categories` | CategoryEntry[] | All known categories across all tiers |
| `SpecIds` | string[] | Flat list of all registered `spec-id` values (for uniqueness check) |

#### TierEntry

| Field | Type | Description |
|---|---|---|
| `Name` | string | Tier name (e.g., `business`, `security`) |
| `Priority` | int | Tier precedence (0 = highest) |
| `AuthorityScope` | string | `platform-meta-governance`, `platform-content-standards`, or `content` |

#### CategoryEntry

| Field | Type | Description |
|---|---|---|
| `Tier` | string | Parent tier name |
| `Category` | string | Category directory name (e.g., `cost`, `data-protection`) |
| `SpecId` | string | Short spec identifier (e.g., `cost`, `dp`) |
| `SpecFilePath` | string | Absolute path to `spec.md` |
| `Exists` | bool | Whether `spec.md` exists on disk |
| `Version` | string \| null | Current version from frontmatter if file exists |

---

### PhaseContext

Tracks execution state across the three processing phases. Held in agent session memory; never written to disk.

| Field | Type | Description |
|---|---|---|
| `CurrentPhase` | enum: `ContextBuild` \| `PlanClarify` \| `WriteExecution` \| `Complete` \| `Aborted` | Current execution phase |
| `TranscriptWordCount` | int | Word count of the loaded transcript (shown in context banner) |
| `UpdateCandidates` | string[] | Category paths flagged as potential UPDATE targets during Phase 1 |
| `GroupCount` | int | Number of confirmed groups entering Phase 3 |
| `ProgressMarkers` | PhaseProgressMarker[] | Per-group write progress records |
| `PhaseError` | string \| null | Non-null if Phase 1 aborted (unreadable file, zero-signal, etc.) |

#### PhaseProgressMarker

One record per tier-category group processed during Phase 3.

| Field | Type | Description |
|---|---|---|
| `GroupKey` | string | `"<tier>/<category>"` (e.g. `"business/cost"`) |
| `Action` | enum: `create` \| `update` \| `skip` | Intended action for this group |
| `Status` | enum: `pending` \| `started` \| `success` \| `error` | Current write status |
| `Marker` | string | Chat symbol: `"▶"` (started), `"✓"` (success), `"✗"` (error) |
| `ErrorMessage` | string \| null | Non-null on error |

---

### IngestionManifest

The structured JSON output produced by AI using the analysis template. This is the handoff point between the spec-interpreted analysis and the script-enforced file writing.

| Field | Type | Description |
|---|---|---|
| `transcript_file` | string | Source transcript file path |
| `meeting_date` | string | Inferred or explicit meeting date |
| `participants` | string[] | Meeting participants |
| `purpose` | string | One-sentence meeting purpose |
| `spec_entries` | SpecEntry[] | Proposed spec files to create or update |
| `new_categories` | NewCategoryProposal[] | New categories to register (subset of spec_entries where `is_new_category: true`) |

**Validation rules**:
- Must be valid JSON (parseable by `ConvertFrom-Json`)
- `spec_entries` must be non-empty to constitute a successful ingestion
- All `tier` values must match known tiers in `CategoryCatalog`

---

### SpecEntry

One proposed spec file within the `IngestionManifest`.

| Field | Type | Description |
|---|---|---|
| `tier` | string | Target tier (`business`, `security`, `infrastructure`, `devops`, `application`, `platform`) |
| `category` | string | Target category directory name |
| `spec_id` | string | Spec identifier (2–8 chars, lowercase alphanumeric + hyphen) |
| `is_new_category` | bool | True if this category does not exist in `CategoryCatalog` |
| `title` | string | Human-readable title for the spec (used in `# Specification:` heading) |
| `summary` | string | One-sentence summary (used in dry-run display and frontmatter `description`) |
| `decisions` | string[] | Verbatim or paraphrased decisions from transcript backing this spec |
| `requirements` | string[] | Extracted requirements formatted as `REQ-NNN: ...` |
| `constraints` | string[] | Constraints and non-negotiables extracted from transcript |

**Validation rules**:
- `tier` must be one of the 6 known tiers
- `spec_id` must match `^[a-z][a-z0-9-]{1,7}$`
- `spec_id` must not conflict with an existing spec-id in `CategoryCatalog` (if `is_new_category: true`)
- `category` must match `^[a-z][a-z0-9-]+$`
- `title` must be non-empty

---

### NewCategoryProposal

Registration data for a new category that does not yet exist in the spec tree.

| Field | Type | Description |
|---|---|---|
| `tier` | string | Target tier |
| `category` | string | Category directory name to create |
| `spec_id` | string | Spec-id to register |
| `description` | string | One-sentence category description for `_categories.yaml` |
| `justification` | string | Why this category is necessary (from transcript context) |

---

### GeneratedSpec

The in-memory representation of a spec file before it is written to disk. Produced by the script from a `SpecEntry`.

| Field | Type | Description |
|---|---|---|
| `TargetPath` | string (file path) | Absolute path where `spec.md` will be written |
| `Tier` | string | Tier |
| `Category` | string | Category |
| `SpecId` | string | Spec-id |
| `Version` | string | Always `"1.0.0-draft"` for new specs |
| `FrontmatterYaml` | string | Rendered YAML frontmatter block (including all required fields) |
| `BodyMarkdown` | string | Rendered spec body (executive summary, decisions, requirements, constraints) |
| `IsNewCategory` | bool | Whether this requires a new category registration |
| `SkipReason` | string \| null | Non-null if this spec will be skipped (e.g., file exists and no `-Force`) |

---

### IngestionResult

Final output reported by the agent after all Phase 3 writes complete.

| Field | Type | Description |
|---|---|---|
| `TranscriptFile` | string | Source transcript path |
| `SpecsCreated` | int | Count of spec files written |
| `SpecsUpdated` | int | Count of existing spec files updated (via `-Force`) |
| `SpecsSkipped` | int | Count of spec files skipped (existing, no `-Force`) |
| `SpecsFailed` | int | Count of spec files that failed validation or write |
| `CategoriesCreated` | int | Count of new categories registered |
| `ConflictsFlagged` | int | Count of Write-with-flag resolutions |
| `AmendmentProposalsWritten` | int | Count of upstream amendment proposals generated |
| `Errors` | string[] | Error messages for failed groups (from ✗ markers) |
| `Warnings` | string[] | Warnings for skipped entries |
| `PromotionReminder` | string | Fixed text: `"All output specs are status: draft and require human review before promotion"` |
| `Success` | bool | True if `SpecsFailed == 0` |

**JSON output shape** (when `-Json`):
```json
{
  "success": true,
  "dry_run": false,
  "transcript_file": "meetings/q2-planning-2026.md",
  "specs_created": 3,
  "specs_skipped": 0,
  "specs_failed": 0,
  "categories_created": 1,
  "errors": [],
  "warnings": [],
  "specs": [
    { "tier": "business", "category": "cost", "spec_id": "cost", "path": "specs/business/cost/spec.md", "action": "created" },
    { "tier": "business", "category": "compliance-framework", "spec_id": "comp", "path": "specs/business/compliance-framework/spec.md", "action": "created" },
    { "tier": "infrastructure", "category": "compute", "spec_id": "compute", "path": "specs/infrastructure/compute/spec.md", "action": "created" }
  ]
}
```

---

## State Transitions

```
TranscriptDocument (user input)
        │
        ▼
  [Phase 1: Context Build]
  (all file reads issued as single parallel batch)
        │
        ├── [unreadable/empty] ──→ PhaseContext.PhaseError set → abort with chat error
        │
        ▼
  CategoryCatalog + UpdateCandidates loaded
  "Context loaded" banner posted to chat:
  "<N> words · <T> tiers · <S> existing specs · UPDATE candidates: ..."
        │
        ▼
  [Phase 2: Plan & Clarification]
  (no file writes in this phase)
        │
        ├── [zero tier-signal extracted] ──→ warn user → ask for confirmation
        │                                     ├── user confirms end → session ends, no writes
        │                                     └── user provides correction → restart Phase 1
        │
        ▼
  GroupingPlan proposed in chat → user confirms
  Clarifying Q&A (max 5 questions)
  Conflict detection + per-conflict resolution (Block │ Write-with-flag │ Propose amendment)
        │
        ▼
  [Phase 3: Parallel Write Execution]
  "▶ Processing N groups" header posted
        │
        ▼
  For each group (batching non-overlapping groups as parallel tool calls):
    ▶ [tier/category] — new | update | skip  (start marker)
    │
    ├── [new category] ──→ register-category.ps1 ──→ wait if same-tier write pending
    ├── [write spec]   ──→ write-spec.ps1 [-Force]
    │
    ├── [success] ──→ ✓ [tier/category] — created | updated | skipped
    └── [error]   ──→ ✗ [tier/category] — error: <reason> → continue to next group
        │
        ▼
  IngestionResult assembled
  Session summary posted (all ✓/✗, conflicts, categories, PromotionReminder)
```

---

## Entities Excluded from Scope (v1)

- `MeetingRecording` (audio) — transcription is out of scope
- `SpecDiff` — merging AI content into an existing spec — deferred to v2
- `ApprovalWorkflow` — auto-promoting drafts — out of scope by design (always `status: draft`)
