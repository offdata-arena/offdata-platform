# OFFDATA & CompanyOS — Antigravity Execution Playbook (v2.0 · Sprints 0–3)

This playbook sequences the OFFDATA Living Institution build into bounded, non-overlapping missions engineered for **Antigravity Planning Mode**, **Agent Manager (Parallel Threads)**, and **Browser Agent Visual Verification**.

---

## 0. Mandatory Antigravity Operating Rules

1. **Run Mission 0.1 Single-Threaded First:** Do NOT open parallel Agent Manager threads until **Mission 0.1** passes `pnpm turbo run typecheck` and `pnpm turbo run test` 100% green.
2. **Enforce Parallel `Owned Paths` Locks:** When running concurrent waves (`1A + 1B`, `2A + 2B`, `3A + 3B + 3C`), each thread may create or edit files ONLY inside its listed **Owned Paths**. Any shared schema tweak requires pausing parallel threads and updating `@offdata/contracts` first.
3. **Planning Mode + Browser Gate:** Start every mission in **Planning Mode** to confirm file paths match `@ARCHITECTURE.md`. Every `apps/*` mission MUST run the **Antigravity Browser Agent** at `1440x900` and `390x844` against `@DESIGN.md` (`Critiquito` score at least `90/100`) before completion.

---

## SPRINT 0: Constitutional & Kernel Lock (Single Thread — Days 1–2)

### Mission 0.1 — Monorepo, `@offdata/contracts`, 31-Table RLS Suite, Vault URI Check & Base Sandbox Image
- **Execution Mode:** Single Agent Thread
- **Owned Paths:** `/package.json`, `/pnpm-workspace.yaml`, `/turbo.json`, `/tsconfig.base.json`, `/contracts/**`, `/database/**`, `/packages/vault/**`, `/docker/sandbox-base.Dockerfile`
- **Read-Only Seed Inputs:** `/GEMINI.md`, `/DESIGN.md`, `/ARCHITECTURE.md`, `/.env.example`, `/docker/sandbox-base.Dockerfile`, `/agents/**`, `/vault/skills/**`

#### Prompt to Paste into Antigravity (Planning Mode):
```text
Read @GEMINI.md, @ARCHITECTURE.md, @.env.example, @contracts/src/core-schemas.ts, @contracts/src/ipc-contracts.ts, and @database/migrations/0001_companyos_kernel.sql.

Execute Mission 0.1 — Foundational Monorepo, 31-Table RLS Proof & Seed Verification:
1. Initialize the pnpm 9 + Turborepo 2 + strict TypeScript 5.7 workspace (`pnpm-workspace.yaml`, `turbo.json`, `tsconfig.base.json`) matching the directory map in @ARCHITECTURE.md.
2. Wire `@offdata/contracts` (`contracts/package.json`, `contracts/tsconfig.json`) and implement `@offdata/vault` URI resolution (`packages/vault/src/uri-resolver`) mapping `vault://skills/<domain>/<slug>@v<semver>` to `/vault/skills/<domain>/<slug>/SKILL.md` with YAML frontmatter version checks.
3. Write `contracts/src/__tests__/seed-integrity.test.ts` (Vitest) proving:
   - All `.agent.yaml` manifests under `/agents/**` parse cleanly through `AgentManifestSchema`.
   - Every `vault://skills/...` URI referenced across those manifests resolves to an existing `/vault/skills/**/SKILL.md` file with matching `version` frontmatter.
4. Apply `database/migrations/0001_companyos_kernel.sql` to local Supabase/Postgres and write `database/__tests__/rls-isolation.test.ts` proving deterministically across `founder_admin`, `agent_worker` (Tenant A vs. Tenant B), and `client_portal_user`:
   - All 31 public tables have `relrowsecurity = true` and `relforcerowsecurity = true`.
   - Tenant A's `agent_worker` CANNOT read or write Tenant B's `workspaces`, `artifacts`, `evidence_ledger`, `tenant_memories`, `crm_opportunities`, or `advisory_engagements`.
   - `agent_worker` CANNOT self-approve (`decision_packets.status = 'approved'`, `learning_proposals.status = 'approved'`, `artifacts.editorial_signed_off = true`), CANNOT insert `behavioral_rule` into `agent_memories`, CANNOT insert positive revenue into `true_cost_ledger`, and CANNOT mutate `firm_memories` or `autonomy_policies`.
   - Inserting a row into `workspace_focus_sessions` atomically populates `true_cost_ledger` (`founder_shadow_time`) and updates `v_workspace_true_margins`.
   - `client_portal_user` can read `evidence_ledger` ONLY for UUIDs explicitly cited in `client_portal_visible = true` artifacts of their own `tenant_id`.
5. Build and smoke-test `docker/sandbox-base.Dockerfile` (`offdata/sandbox-base:local`), verifying `ps` (`procps`), `rea-agents`, `craft-anything-cli`, and `playwright` binaries execute cleanly inside the container.

Definition of Done: `pnpm install`, `pnpm turbo run typecheck`, `pnpm turbo run test`, and the Docker smoke check pass 100% green.
```

---

## SPRINT 1: Agent OS Core & 3-Zone Institutional Studio (Parallel Wave A — Days 3–10)

Run **Mission 1A** and **Mission 1B** concurrently in Antigravity's **Agent Manager**, then run **Mission 1C** to verify the integrated loop.

### Mission 1A — Upgraded Grok-Style Agent OS Runtime (`packages/agent-os`)
- **Execution Mode:** Parallel Agent Thread #1
- **Owned Paths:** `packages/agent-os/**`
- **Read-Only Paths:** `contracts/**`, `packages/vault/src/uri-resolver/**`, `database/**`, `agents/**`, `docker/**`

#### Prompt to Paste into Antigravity (Agent Manager Thread 1):
```text
Read @GEMINI.md, @ARCHITECTURE.md (Section 4), @contracts/src/core-schemas.ts, and @contracts/src/ipc-contracts.ts.

Build Subsystem 1 (`@offdata/agent-os` in `packages/agent-os`) with real PostgreSQL persistence and zero mock placeholders:
1. `src/registry`: Parse `/agents/**/*.agent.yaml` (`camelCase` validated by `AgentManifestSchema`) and upsert `snake_case` rows idempotently into `agent_profiles` and `agent_routines`.
2. `src/gateway`: Implement `ToolGateway` + `EmbeddingGateway`:
   - Deterministically block any tool not in `mcpTools` or matching an `antiJobs` rule (updating `agent_runs.status = 'halted_anti_job'`).
   - Enforce `maxBudgetUsdPerRun` circuit breakers and record negative compute burn into `true_cost_ledger`.
   - Implement `createEmbedding1536()` honoring `CreateEmbeddingRequestSchema` (`outputDimensionality: 1536`) and asserting exact length `1536` prior to `pgvector` writes.
3. `src/memory`: Implement 3-Tier Memory (`firm_memories`, `agent_memories`, `tenant_memories`) using JWT-scoped RLS clients (`ScopedJwtClaimsSchema`), HNSW cosine retrieval, `expires_at` filtering, automatic `work_log` append, and `proposeLearning()` writing `pending` rows to `learning_proposals`.
4. `src/secret-vault`: Implement the Zero-Knowledge Outbound HTTP/Header Proxy substituting `{{VAULT:SECRET_REF}}` placeholders from `VAULT_SECRET_*` env vars at the network edge while scrubbing secret strings from logs and responses.
5. `src/sandbox-pool`: Implement `ComputerProvider` supporting all three `SandboxDriverSchema` modes:
   - `docker_local`: Runs `offdata/sandbox-base:local` with dynamic host port mapping (`127.0.0.1:0:6080`), inspects the assigned port, exposes `novnc_ws` stream URLs, and handles `take_over`, `resume_agent`, `start_teach`, and `stop_teach` (`SandboxControlRequestSchema`).
   - `e2b_cloud`: Production microVM driver (`webrtc`).
   - `headless_ci`: Launches container with `SANDBOX_HEADLESS=1` (`headless_none` stream) for automated CI suites.
6. `src/routines`: Trigger.dev v3 durable task wrappers for `cron:*` and `event:*` routines plus `pause`, `resume`, and `test_run` (`RoutineControlRequestSchema`).

Definition of Done: `pnpm --filter @offdata/agent-os typecheck` and `pnpm --filter @offdata/agent-os test` pass 100% green, including parallel `docker_local` dynamic-port allocation, 1536-dim vector validation, and `antiJobs` blocking.
```

---

### Mission 1B — Shared Chassis, All 9 Generative Widgets & 3-Zone Studio (`packages/chassis` + `apps/companyos`)
- **Execution Mode:** Parallel Agent Thread #2 (Concurrent with 1A)
- **Owned Paths:** `packages/chassis/**`, `apps/companyos/**`
- **Read-Only Paths:** `DESIGN.md`, `contracts/**`, `database/**`

#### Prompt to Paste into Antigravity (Agent Manager Thread 2):
```text
Read @GEMINI.md, @DESIGN.md (all 6 sections), @contracts/src/core-schemas.ts, and @contracts/src/ipc-contracts.ts.

Build `@offdata/chassis` and `apps/companyos` (`app.offdata.com`):
1. `packages/chassis/src/auth-rls`: Implement JWT-scoped Supabase client factories for `founder_admin`, `agent_worker`, and `client_portal_user` strictly typed to `ScopedJwtClaimsSchema` (never exposing `service_role` to workers).
2. `packages/chassis/src/ui`: Configure the `@DESIGN.md` Dual-Surface CSS system (Obsidian Chrome `#0B0D10`/`#0F1217`/`#141820` + Warm Alabaster Editorial Paper `#FAF9F6` + Institutional Navy `#0F2537`), typography (`Newsreader`, `Geist`, `JetBrains Mono`), and mandatory `tabular-nums` alignment.
3. `packages/chassis/src/widgets`: Build all **9 Canonical Generative UI Widgets** strictly validated by `GenerativeWidgetSchema`:
   - `ExecutiveCooBriefing` (`Today` home with symmetric 3-Engine Operating Cards)
   - `IntelligencePublicationWorkbench` (`OFFDATA Intelligence` claim verifier + multi-channel & AEO previews)
   - `ExecutiveDealRoomMemo` (`OFFDATA Advisory` sensitivity sliders + `[SHA-256]` citation drawer)
   - `ScopeAndMarginSentinelCard` (SOW diff + True-Margin impact + 1-click Change Order)
   - `ReaSystemXrayGraph` (interactive runtime architecture & clean-core blocker explorer)
   - `VentureInvestmentDealMemo` (`OFFDATA Solutions` 70/20/10 100-point underwriting tear sheet)
   - `CraftBuildStageWorkbench` (`01 Study -> 02 Build -> 03 Check -> 04 Ready` + multi-viewport preview + `Critiquito` scorecard)
   - `ReviewLearningsDiffCard` (before/after `SKILL.md` or rule diff + `Approve` / `Discard`)
   - `ReleaseTrainDecisionPacket` (Gate 1/2 badges + 3-Speed Iteration header)
4. `packages/chassis/src/telemetry-economics`: Build `useWorkspaceFocusTimer` tracking active Founder seconds per workspace and posting to `/api/studio/telemetry/focus`.
5. `apps/companyos`:
   - Build the locked `100dvh x 100vw` 3-Zone Institutional Studio (`Top Command Bar` giving equal prominence to `Today | Intelligence | Advisory | Solutions` + `Cmd+K` COO bar + Live VM pill; `Zone 1` Presence & Pod Roster via Supabase Realtime; `Zone 2` `Workbench | Review | Operate` stage with inline override editing + **Spatial Pin + Hold-Space-to-Speak** `MediaRecorder` capture; `Zone 3` Live Computer `novnc_ws`/`webrtc` viewer with `Take Over`, `Teach a Task`, and 3-Speed Decision Console).
   - Implement all **7 typed Route Handlers** under `src/app/api/studio/*` matching `@contracts/src/ipc-contracts.ts` (`missions/dispatch`, `decisions/resolve`, `learnings/resolve`, `sandbox/control`, `routines/control`, `voice-transcribe`, and `telemetry/focus`).

Mandatory Browser Verification: Launch the Antigravity Browser Agent at `1440x900` and `390x844`, exercise `Today` and all 3 Engine Studios, verify keyboard shortcuts (`Cmd+K`, `Cmd+\`), Spatial Voice Pin UI, Zone 3 drawer toggle, zero horizontal scrollbars, and confirm `Critiquito` compliance (`>= 90/100`).
```

---

### Mission 1C — End-to-End Integration of First 3 Production Bots & Live Takeover Proof
- **Execution Mode:** Single Integration Thread (After 1A & 1B merge)
- **Owned Paths:** `packages/agent-os/src/connector-forge/**`, `apps/companyos/src/app/api/studio/**`, `tests/e2e/sprint1-live-workbench.spec.ts`

#### Prompt to Paste into Antigravity:
```text
Read @GEMINI.md, @ARCHITECTURE.md, and the three manifests in `/agents/**` (`coo.global-dispatcher`, `eng.connector-forge`, `qa.playwright-journey-bot`) alongside their 9 `/vault/skills/**` playbooks.

Wire `@offdata/agent-os` live into `apps/companyos` `/api/studio/*` handlers and implement the end-to-end Sprint 1 reference loop:
1. Connect `coo.global-dispatcher` to `POST /api/studio/missions/dispatch` and render live `ExecutiveCooBriefing` data from `v_workspace_true_margins`.
2. Implement `eng.connector-forge` (`openapi-to-typed-mcp-server`, `teach-trace-to-playwright-skill`, and `zero-knowledge-vault-auth-wiring`) inside `DockerLocalComputer`.
3. Implement `qa.playwright-journey-bot` (`multi-viewport-playwright-walkthrough`, `holdout-scenario-blackbox-runner`, and `critiquito-institutional-design-audit`) writing real `.webm` video + SHA-256 screenshot evidence into `evidence_ledger`.
4. Run Playwright E2E + Antigravity Browser Verification proving:
   - Dispatching a connector build from `Cmd+K` lights up Zone 1 Realtime Presence and streams the live container desktop in Zone 3.
   - Clicking `Take Over`, interacting in Zone 3, and clicking `Teach a Task` emits `sandbox.teach_trace_saved` and stages a `ReviewLearningsDiffCard`.
   - `qa.playwright-journey-bot` verifies the output and stages a `ReleaseTrainDecisionPacket` resolved cleanly via `POST /api/studio/decisions/resolve`.
```

---

## SPRINT 2: `REA`, `Craft Anything` & 3D Institutional Vault (Parallel Wave B — Days 11–24)

Launch **Mission 2A** and **Mission 2B** concurrently in Agent Manager.

### Mission 2A — Containerized `REA` & `Craft Anything` Bridges + `Critiquito` Gate (`packages/engines-bridge`)
- **Execution Mode:** Parallel Agent Thread #1
- **Owned Paths:** `packages/engines-bridge/**`, `agents/04-advisory-discovery/**`, `agents/05-implementation-factory/eng.craft-cleanroom-specialist.agent.yaml`, `agents/06-independent-assurance/qa.critiquito-design-auditor.agent.yaml`

#### Prompt to Paste into Antigravity (Agent Manager Thread 1):
```text
Read @GEMINI.md (Section 4), @DESIGN.md (Section 6), @ARCHITECTURE.md (Section 6), and @contracts/src/core-schemas.ts.

Build Subsystem 3 (`@offdata/engines-bridge` in `packages/engines-bridge`) executing inside `offdata/sandbox-base:local`:
1. `src/rea-worker` (`morluto/rea` MCP bridge):
   - Validate tasks with `ReaInspectionTaskSchema`; configure `REA_MCP_TOOL_FAMILIES` (max 3 families) and `REA_MCP_TOOL_CATALOG_PROFILE=hot-cold`, asserting exposed MCP tool count never exceeds `15`.
   - Enforce legal/tenant security: when `isExternalClientTarget === true`, query `engagement_authorizations` via the scoped `agent_worker` RLS client for an active, unrevoked `rea_deep_inspection` record matching `tenant_id` and `workspace_id` BEFORE container start; return `UNAUTHORIZED_INSPECTION` otherwise.
   - Persist runtime traces to `evidence_ledger` and emit `ReaSystemXrayGraphWidgetSchema`.
2. `src/craft-worker` (`storytold/craft-anything` Rust MCP bridge):
   - Invoke `/usr/local/bin/craft-anything-cli mcp` inside the isolated sandbox, enforcing `mode: "clean-room"` by default (blocking `deep` mode without `craft_deep_mode` authorization).
   - Drive `01_study` (`web_site_capture`, `web_page_states_capture`) -> `02_build` (on `@offdata/chassis`) -> `03_check` (`web_pixels_compare`, `web_walkthrough_check`, `app_coverage_evaluate` + `Critiquito` `>= 90/100`) -> `04_ready` (archiving `investigation.cany` SHA-256 digest to `evidence_ledger` and emitting `CraftBuildStageWorkbenchWidgetSchema`).
3. Author `.agent.yaml` manifests (strict `camelCase`, validated against `AgentManifestSchema`) for `advisory.rea-system-xray`, `eng.craft-cleanroom-specialist`, and `qa.critiquito-design-auditor`.

Definition of Done: Automated Vitest + container tests prove REA authorization blocking, REA `<= 15` tool budget enforcement, Craft clean-room execution, and `Critiquito` scoring `apps/companyos` at `>= 90/100`.
```

---

### Mission 2B — 3D Matrix Vault Composer, `ReferenceCheckAuditor` & Vault Cell #01 (`packages/vault` + `vault/cells/`)
- **Execution Mode:** Parallel Agent Thread #2 (Concurrent with 2A)
- **Owned Paths:** `packages/vault/**`, `vault/archetypes/**`, `vault/practices/**`, `vault/cells/**`, `agents/06-independent-assurance/qa.reference-check-auditor.agent.yaml`

#### Prompt to Paste into Antigravity (Agent Manager Thread 2):
```text
Read @GEMINI.md (Section 3.5), @ARCHITECTURE.md (Section 5), and @contracts/src/core-schemas.ts.

Complete Subsystem 2 (`@offdata/vault` in `packages/vault`) and author Production Vault Cell #01:
1. `src/evidence-ledger`: Content-addressed SHA-256 ingestion pipeline storing PDFs, JSON OAuth snapshots, web captures, and deterministic model outputs with exact page/line/JSONPath locators in `evidence_ledger`.
2. `src/composer`: 3D Matrix Composer resolving `(ClientArchetype, FunctionalPractice, industryTags)` into validated `VaultCellManifest` Mission Kits and syncing `/vault/cells/**` into PostgreSQL `vault_cells`.
3. `src/skill-runner` & `ReferenceCheckAuditor` (`qa.reference-check-auditor.agent.yaml`):
   - Run deterministic TypeScript calculation models in `models/*.ts` and store signed outputs in `evidence_ledger`.
   - Verify every `CitationBadge` across `ExecutiveDealRoomMemo`, `IntelligencePublicationWorkbench`, and `VentureInvestmentDealMemo` against `evidence_ledger` hashes and excerpts—failing Gate 1 (`REFERENCE_CHECK_FAILED`) on any unverified or mutated number.
4. Author complete **Vault Cell #01** at `vault/cells/a-b2b-services-client-delivery-ops/` (`A_b2b_services` x `process_operating_model`, version `1.0.0`):
   - `intake.yaml` (`scoped_oauth_snapshot`, `cc_the_vault`, `silent_work_along_capture`)
   - `models/utilization-and-margin-leakage.ts` (deterministic model computing billable utilization uplift from 66.4% SPI benchmark baseline, scope-leakage recovery, and EBITDA expansion)
   - `SKILL.md` (complete OFFDATA AI Client Delivery Operations playbook)
   - `templates/deal-room-memo.template.ts` (emitting `ExecutiveDealRoomMemoWidgetSchema`)
   - `EVALS.yaml` (Gate 1 assertions, Gate 2 adversarial rubric, and 3 regression failure fixtures).

Definition of Done: `pnpm --filter @offdata/vault test` executes Vault Cell #01 end-to-end on a 65-person B2B consultancy fixture, emits a Reference-Checked `ExecutiveDealRoomMemo`, and proves `ReferenceCheckAuditor` rejects a 1-cent tampered metric.
```

---

## SPRINT 3: Branded-House Web, Living Deal Rooms & Autonomous Engines (Parallel Wave C — Days 25–45)

Launch **Missions 3A, 3B, and 3C** concurrently across three Agent Manager threads.

### Mission 3A — Public `offdata.com`, `clients.offdata.com` Deal Rooms & `demo.offdata.com`
- **Execution Mode:** Parallel Agent Thread #1
- **Owned Paths:** `apps/corporate-site/**`, `apps/client-portal/**`, `apps/demo-sandbox/**`

#### Prompt to Paste into Antigravity (Agent Manager Thread 1):
```text
Read @GEMINI.md, @DESIGN.md (Surface Tier B: `#FAF9F6` Alabaster Paper + `#0F2537` Institutional Navy + Section 5 Article 50 Provenance), and @contracts/src/core-schemas.ts.

Build OFFDATA's three external applications sharing `@offdata/chassis`:
1. `apps/corporate-site` (`offdata.com`):
   - Branded-house institutional architecture: Home ("From AI ambition to operating advantage."), `/advisory` (Diagnose -> Design -> Implement -> Operate -> Expand), `/intelligence` (Intelligence Briefs, Field Notes, Operating Benchmarks displaying Named Principal Editorial Bylines per EU AI Act Article 50(4)), `/solutions`, `/industries` (B2B Professional Services beachhead), and `/company` (Client Assurance Standard, security & transparent AI-native governance).
   - Qualifying intake form creating `crm_opportunities` and `outbox_events`.
2. `apps/client-portal` (`clients.offdata.com`):
   - Strictly authenticated under `client_portal_user` RLS claims.
   - Renders `ExecutiveDealRoomMemo` (interactive ROI sliders + `[SHA-256]` cited evidence drawer), Deliverable & SOW Scope Tracker, UAT staging preview, 1-Click Client Acceptance + Stripe Deposit/Subscription Checkout, and Managed Operations SLA telemetry.
3. `apps/demo-sandbox` (`demo.offdata.com`):
   - Zero-login, `$0.05`-capped interactive Delivery & Scope Leakage Diagnostic converting prospects directly into paid Assessments or self-serve subscriptions.

Mandatory Browser Verification: Run Browser Agent + `Critiquito` (`>= 90/100`) at `1440x900` and `390x844` across all 3 apps and verify cross-tenant RLS isolation in Playwright.
```

---

### Mission 3B — Intelligence, GTM & Advisory Delivery State Machines
- **Execution Mode:** Parallel Agent Thread #2 (Concurrent with 3A & 3C)
- **Owned Paths:** `engines/intelligence/**`, `engines/gtm/**`, `engines/advisory/**`, `agents/02-intelligence-editorial/**`, `agents/03-gtm-revenue/**`, `vault/skills/intelligence/**`, `vault/skills/advisory/**`

#### Prompt to Paste into Antigravity (Agent Manager Thread 2):
```text
Read @GEMINI.md, @ARCHITECTURE.md (Section 3), and @contracts/src/core-schemas.ts.

Build the durable Trigger.dev lifecycles and `.agent.yaml` manifests for `engines/intelligence`, `engines/gtm`, and `engines/advisory`:
1. `engines/intelligence` (`editorial_publications` + `IntelligencePublicationWorkbench`):
   - Signal Harvester -> Empirical Benchmark Runner -> Editorial Principal -> `ReferenceCheckAuditor` + Article 50 provenance check -> Monday Release Train sign-off -> multi-channel publisher -> `content.lead_attributed` outbox event.
2. `engines/gtm`:
   - `gtm.signal-prospector` (runs `outside_in_recon` diagnostics prior to outreach) + `gtm.loop-closer` monitoring Resend inbound threads and `crm_opportunities.next_loop_closer_at`.
3. `engines/advisory`:
   - Low-friction ingestion endpoints (`CC-the-Vault` Resend webhook, Nango `scoped_oauth_snapshot` with auto-revoke, and `local_zero_exfil_collector` bundle verifier).
   - **Hard Deposit Gate:** Block implementation sandbox provisioning until Stripe `invoice.paid` flips `advisory_engagements.stripe_deposit_paid = true`.
   - `advisory.scope-sentinel` (`ScopeAndMarginSentinelCard`) reconciling inbound client messages against `locked_sow_sha256` and staging Stripe Change Orders, plus sanitized `delivery.requirement_repeated` handoffs.

Definition of Done: Integration tests pass end-to-end for **Journey A** (Research to Published Benchmark & Attributed Lead) and **Journey B** (Enquiry -> Paid Deposit -> Vault Cell #01 Delivery -> Client Acceptance -> Scope Sentinel Change Order).
```

---

### Mission 3C — 70/20/10 Venture Office, 6-Object Registry & 10-Step Idempotent Launch (`engines/solutions`)
- **Execution Mode:** Parallel Agent Thread #3 (Concurrent with 3A & 3B)
- **Owned Paths:** `engines/solutions/**`, `packages/chassis/src/billing-meters/**`, `agents/07-managed-ops-venture/**`, `vault/skills/solutions/**`

#### Prompt to Paste into Antigravity (Agent Manager Thread 3):
```text
Read @GEMINI.md, @ARCHITECTURE.md (Sections 3 & 6), and @contracts/src/core-schemas.ts.

Build `engines/solutions` and `@offdata/chassis/billing-meters`:
1. **3-Agent Venture Investment Office (`VentureInvestmentDealMemo`):**
   - Consume `research.opportunity_qualified` and `delivery.requirement_repeated` events across `core_70`, `adjacent_20`, and `frontier_10` tracks.
   - Run `venture.commercial-underwriter`, `venture.ops-friction-auditor`, and `venture.skeptic-kill-agent`; stage surviving Deal Memos onto Monday's Release Train and capture `learning_proposals` from both approved and killed dossiers.
2. **Idempotent 10-Step Launch & Registration Pipeline (`product_launch_runs`):**
   - Implement all 10 resumable steps in `ProductLaunchManifestSchema` (`01_register_product` through `10_activate_portfolio_steward`) populating all 6 Product Registry tables (`products`, `product_versions`, `service_offerings`, `production_deployments`, `customer_installations`, `product_owner_mandates`).
   - Guarantee idempotent resume on partial step failure without duplicating Stripe products or deployments.
3. **3-Wrapper Commercial Billing (`packages/chassis/src/billing-meters`):**
   - Support mounting any capability simultaneously as `self_serve_saas` (Stripe Subscriptions + Usage Meters), `metered_http402_mcp` (HTTP `402 Payment Required` machine-payable MCP middleware), and `managed_operations_sla`.
4. **Standing AI Product Owner & Merger Steward (`ops.standing-product-owner` & `venture.portfolio-merger-steward`):**
   - Run 6-hour health/margin checks and 14-day Portfolio Steward audits staging autonomous patches, **Product Suite Mergers** (`product.consolidation_proposed`), or free Lead-Magnet conversions onto Thursday's Release Train.

Definition of Done: Integration tests pass end-to-end for **Journey C** (Venture Approval -> 10-Step Launch with simulated Step-05 failure & clean resume -> Active `product_owner_mandates`) and **Journey D** (Repeated Advisory requirement -> Sanitized Venture Dossier -> Multi-Wrapper Offering).
```