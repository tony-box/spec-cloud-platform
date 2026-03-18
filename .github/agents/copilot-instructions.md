---
artifact-type: agent-context
---

# spec-cloud-platform-template Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-03-17

## Active Technologies
- PowerShell 7 (scripts — unchanged), Markdown (agent definition) + Existing `.specify/` toolkit scripts (`register-category.ps1`, `write-spec.ps1`), `transcript-analysis-template.md` — no new dependencies (003-transcript-to-spec)
- File system only (`_categories.yaml`, `specs.yaml`, `spec.md` — unchanged) (003-transcript-to-spec)

- PowerShell 7+ (pwsh) — consistent with all existing toolkit scripts + `common.ps1` (shared helpers: repo root, branch, paths), `specs.yaml` reader (regex/string parsing, no external YAML library), PSScriptAnalyzer (CI validation) (001-transcript-to-spec)

## Project Structure

```text
src/
tests/
```

## Commands

# Add commands for PowerShell 7+ (pwsh) — consistent with all existing toolkit scripts

## Code Style

PowerShell 7+ (pwsh) — consistent with all existing toolkit scripts: Follow standard conventions

## Recent Changes
- 003-transcript-to-spec: Added PowerShell 7 (scripts — unchanged), Markdown (agent definition) + Existing `.specify/` toolkit scripts (`register-category.ps1`, `write-spec.ps1`), `transcript-analysis-template.md` — no new dependencies

- 001-transcript-to-spec: Added PowerShell 7+ (pwsh) — consistent with all existing toolkit scripts + `common.ps1` (shared helpers: repo root, branch, paths), `specs.yaml` reader (regex/string parsing, no external YAML library), PSScriptAnalyzer (CI validation)

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
