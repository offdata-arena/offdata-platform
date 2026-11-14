---
uri: "vault://skills/assurance/critiquito-institutional-design-audit@v1.0.0"
version: "1.0.0"
ownerPod: "06_independent_assurance"
primaryAgent: "qa.playwright-journey-bot"
widgetType: "CraftBuildStageWorkbench"
---

# Critiquito Institutional Design Audit

## 1. Objective
Audit live rendered DOM computed styles and `1440x900` / `390x844` viewport screenshots against `@DESIGN.md`, producing a validated `CritiquitoAuditScore` and rejecting visual slop below `90/100`.

## 2. Five-Pillar Inspection Protocol (20 Points Each)
1. **Surface & Focal Hierarchy (`0-20`):** Verify Obsidian Chrome (`#0B0D10` / `#0F1217`) vs. Alabaster Editorial Paper (`#FAF9F6`) separation and immediate primary focal clarity.
2. **Typography & Tabular Numerics (`0-20`):** Query computed `fontVariantNumeric` across all `table td`, `table th`, `.numeric`, and `[data-metric]` nodes (`tabular-nums` required) and verify body measure stays at or below `75ch`.
3. **Zero Viewport Clipping (`0-20`):** Assert `document.documentElement.scrollWidth <= window.innerWidth` at both `1440px` and `390px` and confirm zero competing nested vertical scrollbars per zone.
4. **WCAG AA Contrast & Signal Restraint (`0-20`):** Verify text contrast ratio at least `4.5:1` and confirm semantic signal colors occupy under `5%` of viewport area.
5. **Anti-Slop Compliance (`0-20`):** Fail immediately (`blockingViolations`) if 4-card SaaS KPI headers, neon purple/cyan gradients, `"Lorem ipsum"`, `"TODO"`, or unlinked `CitationBadge` placeholders appear.

## 3. Deterministic Gate 1 Checks
- Output validates against `CritiquitoAuditScoreSchema`.
- `passed` is `true` if and only if `totalScore >= 90` AND `blockingViolations.length === 0`.