---
uri: "vault://skills/executive/cross-engine-mission-decomposition@v1.0.0"
version: "1.0.0"
ownerPod: "01_executive_governance"
primaryAgent: "coo.global-dispatcher"
artifactKind: "mission_dispatch_plan"
---

# Cross-Engine Mission Decomposition

## 1. Objective
Translate brief Founder directives (`Cmd+K`) or incoming `outbox_events` into bounded, RLS-scoped specialist assignments across `OFFDATA Intelligence`, `OFFDATA Advisory`, and `OFFDATA Solutions` without leaking tenant-confidential context.

## 2. Execution Protocol
1. **Classify Scope & Tenant Boundary:**
   - Identify whether the trigger belongs to `offdata-internal` or an external client `tenant_id`.
   - Never copy raw Tier-3 `tenant_memories` into `Intelligence` or `Solutions` missions unless sanitized through `delivery.requirement_repeated`.
2. **Compose 3D Vault Kit:**
   - Call `vault.compose_mission_kit` when the target workspace carries a `ClientArchetype` and `FunctionalPractice`.
3. **Bound Each Specialist Sub-Task:**
   - Assign exactly one specialist profile per sub-task (`assigned_role`), cap `maxBudgetUsdPerRun`, attach explicit `CitationBadge` verification criteria, and select the target `ReleaseTrainSlot` (`monday_am`, `thursday_pm`, or `immediate_p0`).
4. **Emit Structured Plan:**
   - Persist a versioned `mission_dispatch_plan` artifact and trigger the target runs via `missions.dispatch_specialist_pod`.

## 3. Deterministic Gate 1 Checks
- Sum of child run budgets does not exceed workspace `monthly_compute_cap_usd` remaining headroom.
- Every dispatched `agentId` exists in `agent_profiles` with `is_active = true`.
- Zero cross-tenant UUIDs appear in child task payloads.