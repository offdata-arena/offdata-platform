# OFFDATA & CompanyOS — Master System Architecture (v2.0)

## 1. System Thesis & Pinned Technical Baseline

OFFDATA (`offdata.com`) operates externally as one cohesive, Big-Firm-calibre Advisory, Intelligence, and Solutions institution while running internally on **CompanyOS** (`app.offdata.com`)—a proprietary operating platform condensing a 1,000-person specialist organization into **7 Persistent Agent Pods (~35 specialist profiles)**, a **3D Practice & Industry Matrix Vault**, and **isolated cloud computers** equipped with **`morluto/rea`** and **`storytold/craft-anything`**.

### Pinned Toolchain Baseline
- **Runtime & Monorepo:** Node.js `>=22.12.0` LTS · `pnpm@9.x` · Turborepo `2.x` · TypeScript `5.7+` (`strict: true`, `noUncheckedIndexedAccess: true`)
- **Web & Studio Surfaces:** Next.js `15.x` (App Router, React 19) · Tailwind CSS + `@DESIGN.md` CSS custom properties
- **Persistence & Realtime:** Supabase PostgreSQL `16+` · `pgcrypto` · `pgvector` (strictly `VECTOR(1536)`) · Supabase Realtime WebSockets & Private Object Storage
- **Durable Orchestration:** Trigger.dev `v3+` (queues, cron routines, idempotency keys, zero-compute `wait.forToken` suspension)
- **Model & Voice Gateway:** Cloudflare AI Gateway / Multi-provider SDK routing across Gemini, Claude, OpenAI, and Grok with mandatory headers (`x-tenant-id`, `x-workspace-id`, `x-agent-id`) + `1536`-dim embeddings + audio transcription for Spatial Voice Pins
- **Sandboxes & Verification:** Local `offdata/sandbox-base:local` Docker container (dev) / E2B MicroVMs (prod) + Playwright `1.50+` + `Vitest 3.x`
- **Commercial Plumbing:** Stripe Billing + Usage Meters + Stripe Tax + HTTP 402 Machine Payments · Resend (SPF/DKIM/DMARC + inbound `CC-the-Vault` webhooks) · Nango/Paragon headless OAuth · Sentry + OpenTelemetry

### Dual-Environment Boundary
- **Operating Company (`environment = 'production'`):** Executes customer engagements, published research, billing, and registered products under strict RLS, zero-data-retention (ZDR) model endpoints, and hard token caps.
- **Frontier Lab (`environment = 'frontier'`):** Isolated R&D workspace (`offdata-internal`) for testing new models, venture smoke tests, `connector-forge` MCP builds, and experimental `REA` / `Craft Anything` workflows prior to Vault promotion.

---

## 2. Reconciled Monorepo Directory Tree (`offdata-platform/`)

```text
offdata-platform/
├── GEMINI.md                          # Always-on Antigravity workspace constitution
├── DESIGN.md                          # Dual-surface tokens, 9 widgets & Critiquito rubric
├── ARCHITECTURE.md                    # Master v2.0 6-subsystem blueprint
├── ANTIGRAVITY_MISSIONS.md            # File-locked Sprint 0-3 Antigravity prompts
├── .env.example                       # Canonical env contract across all apps & workers
├── turbo.json
├── pnpm-workspace.yaml
├── tsconfig.base.json
│
├── docker/
│   └── sandbox-base.Dockerfile        # Pre-baked Ubuntu 24.04 + procps + Xvfb/noVNC + REA + Craft
│
├── contracts/                         # @offdata/contracts (Zero-dependency schema spine)
│   └── src/
│       ├── core-schemas.ts            # Entities, .agent.yaml, 9 Widgets, Registry, Outbox
│       ├── ipc-contracts.ts           # Studio <-> Agent-OS RPC, Voice-Pin & Decision APIs
│       └── index.ts                   # Public barrel export
│
├── database/
│   ├── migrations/
│   │   └── 0001_companyos_kernel.sql  # 30 RLS-enforced tables, views, triggers & seed rows
│   └── __tests__/
│       └── rls-isolation.test.ts      # Multi-JWT tenant/role isolation verification
│
├── apps/
│   ├── companyos/                     # app.offdata.com (3-Zone Studio + /api/studio/* routes)
│   ├── client-portal/                 # clients.offdata.com (Scoped Living Deal Rooms, UAT, SLAs)
│   ├── corporate-site/                # offdata.com (/intelligence, /advisory, /solutions)
│   └── demo-sandbox/                  # demo.offdata.com ($0.05-capped zero-login diagnostics)
│
├── packages/
│   ├── agent-os/                      # Subsystem 1: Upgraded Grok-Bot Workforce Runtime
│   │   └── src/
│   │       ├── registry/              # .agent.yaml camelCase loader -> snake_case DB sync
│   │       ├── gateway/               # Poteto-mode antiJobs, mcpTools ACL & budget breaker
│   │       ├── memory/                # 3-Tier 1536-dim memory + learning_proposals queue
│   │       ├── routines/              # Trigger.dev cron/event scheduler (Pause/Resume/Test)
│   │       ├── sandbox-pool/          # Dynamic-port DockerLocal, E2BCloud & HeadlessCI drivers
│   │       ├── secret-vault/          # Zero-knowledge {{VAULT:ref}} outbound proxy injector
│   │       └── connector-forge/       # Internal 'tinkabot' OpenAPI/Teach-Trace -> MCP builder
│   │
│   ├── vault/                         # Subsystem 2: Skill Resolver, 3D Matrix & Evidence Ledger
│   │   └── src/
│   │       ├── uri-resolver/          # Resolves vault://skills/* (Sprint 1+) & vault://cells/*
│   │       ├── composer/              # Resolves (Archetype x Practice x Industry) -> Mission Kit
│   │       ├── evidence-ledger/       # Content-addressed SHA-256 ingestion & locator store
│   │       └── skill-runner/          # Deterministic TS/Python calculators & ReferenceCheckAuditor
│   │
│   ├── engines-bridge/                # Subsystem 3: Containerized REA & Craft Anything Bridges
│   │   └── src/
│   │       ├── rea-worker/            # Scoped rea-agents MCP client (<=15 tools + auth gate)
│   │       └── craft-worker/          # craft-anything-cli Rust MCP client (clean-room default)
│   │
│   └── chassis/                       # Shared 80/20 Studio & Product Primitives
│       └── src/
│           ├── ui/                    # Obsidian & Alabaster design-system primitives
│           ├── widgets/               # All 9 Canonical Generative UI Widgets
│           ├── auth-rls/              # JWT-scoped Supabase client factory (founder/agent/client)
│           ├── billing-meters/        # Stripe Subscriptions, Meters & HTTP 402 MCP middleware
│           └── telemetry-economics/   # Sentry, OTel + useWorkspaceFocusTimer Shadow-Time hook
│
├── engines/                           # Domain Lifecycle State Machines
│   ├── intelligence/                  # Signal -> Benchmark -> Editorial QA -> Publish -> Lead Attr
│   ├── gtm/                           # Zero-access recon outbound, RFP Bid Desk & Loop Closer
│   ├── advisory/                      # Low-friction intake -> Assessment -> Deposit Gate -> Ops
│   └── solutions/                     # 70/20/10 Venture Office -> Build -> 10-Step Launch -> Steward
│
├── agents/                            # Declarative .agent.yaml Manifests across 7 Pods
│   ├── 01-executive-governance/
│   ├── 02-intelligence-editorial/
│   ├── 03-gtm-revenue/
│   ├── 04-advisory-discovery/
│   ├── 05-implementation-factory/
│   ├── 06-independent-assurance/
│   └── 07-managed-ops-venture/
│
└── vault/                             # Versioned Institutional Knowledge & Executable Assets
    ├── skills/                        # Foundational pod skills (seeded Day 1 for Sprint 1 bots)
    │   ├── executive/
    │   ├── engineering/
    │   └── assurance/
    ├── archetypes/                    # A_b2b_services .. E_saas_tech_vendors
    ├── practices/                     # commercial_pricing .. clean_core_engineering
    └── cells/                         # 3D intersections (intake.yaml, models/, SKILL.md, EVALS.yaml)
```

---

## 3. Symmetric Business Engines & Primary Domain Records

Each business engine owns first-class PostgreSQL records, a contextual AI Director, dedicated Generative UI Widgets, and structured cross-engine outbox handoffs:

| Engine | Primary DB Records | Contextual Director | Primary Widgets | Outbox Events Emitted |
| :--- | :--- | :--- | :--- | :--- |
| **Executive Office** | `workspaces`, `decision_packets`, `true_cost_ledger` | `coo.global-dispatcher` | `ExecutiveCooBriefing`, `ReleaseTrainDecisionPacket`, `ReviewLearningsDiffCard` | Cross-engine mission dispatches |
| **OFFDATA Intelligence** | `editorial_publications`, `artifacts` | `intel.editorial-principal` | `IntelligencePublicationWorkbench` | `research.opportunity_qualified`, `content.lead_attributed` |
| **OFFDATA Advisory** | `crm_opportunities`, `advisory_engagements`, `engagement_authorizations` | `advisory.operating-model-architect` | `ExecutiveDealRoomMemo`, `ScopeAndMarginSentinelCard`, `ReaSystemXrayGraph` | `sales.engagement_won`, `delivery.requirement_repeated` |
| **OFFDATA Solutions** | `venture_dossiers`, 6-Object Product Registry (`products` .. `product_owner_mandates`) | `venture.portfolio-merger-steward` | `VentureInvestmentDealMemo`, `CraftBuildStageWorkbench` | `venture.investment_approved`, `product.release_approved`, `product.launch_verified`, `product.consolidation_proposed` |

### Unified `ArtifactKind` & `FirmMemoryCategory` Vocabularies
To guarantee zero mismatch between `.agent.yaml` routines, Zod validators, and PostgreSQL `CHECK` constraints, all subsystems share these exact enumerations:
- **`ArtifactKind`:** `'coo_briefing'`, `'editorial_publication'`, `'deal_room_memo'`, `'proposal_sow'`, `'prd_spec'`, `'venture_deal_memo'`, `'craft_application'`, `'rea_xray_report'`, `'change_order'`, `'qa_verification_bundle'`, `'mission_dispatch_plan'`, `'portfolio_health_report'`.
- **`FirmMemoryCategory`:** `'commercial_policy'`, `'scoping_heuristic'`, `'pricing_benchmark'`, `'incumbent_weakness'`, `'content_hook_pattern'`, `'founder_taste_rule'`, `'technical_api_gotcha'`, `'qa_regression_pattern'`, `'merger_synergy_rule'`.

---

## 4. Subsystem 1: Agentic Workforce Runtime (`packages/agent-os`)

### 1. The 7 Persistent Specialist Pods (~35 Profiles)
- **Pod 01 (`01_executive_governance`):** `coo.global-dispatcher`, `finance.true-margin-controller`, `legal.compliance-sentinel`, `governance.learning-curator`
- **Pod 02 (`02_intelligence_editorial`):** `intel.signal-harvester`, `intel.benchmark-runner`, `intel.editorial-principal`, `intel.aeo-citation-strategist`, `intel.demo-producer`
- **Pod 03 (`03_gtm_revenue`):** `gtm.signal-prospector`, `gtm.loop-closer`, `gtm.rfp-bid-desk`, `gtm.pricing-proposal-architect`
- **Pod 04 (`04_advisory_discovery`):** `advisory.outside-in-recon`, `advisory.rea-system-xray`, `advisory.process-miner`, `advisory.operating-model-architect`, `advisory.vendor-spend-auditor`
- **Pod 05 (`05_implementation_factory`):** `eng.connector-forge`, `eng.chassis-builder`, `eng.craft-cleanroom-specialist`, `eng.data-migration-architect`
- **Pod 06 (`06_independent_assurance`):** `qa.reference-check-auditor`, `qa.critiquito-design-auditor`, `qa.playwright-journey-bot`, `qa.owasp-agent-redteamer`
- **Pod 07 (`07_managed_ops_venture`):** `ops.standing-product-owner`, `ops.self-healing-sre`, `venture.commercial-underwriter`, `venture.ops-friction-auditor`, `venture.skeptic-kill-agent`, `venture.portfolio-merger-steward`

### 2. Three-Tier Auditable Memory (`VECTOR(1536)`) & Learning Governance
- **Tier 1 (`firm_memories`):** Global institutional rules and benchmarks. Read-only for `agent_worker`; mutated only when Founder approves a `learning_proposals` card.
- **Tier 2 (`agent_memories`):** Scoped by `agent_id`. `agent_worker` can auto-append `memory_kind = 'work_log'`, while `behavioral_rule` changes require `learning_proposals` sign-off.
- **Tier 3 (`tenant_memories`):** Strictly RLS-isolated by `tenant_id` with mandatory `purge_after` timestamps enforcing contractual GDPR/PDPA data hygiene.

### 3. Live Computer Pool (`sandbox-pool`) & Zero-Knowledge Vault
- **`DockerLocalComputer`:** Launches `offdata/sandbox-base:local` binding `127.0.0.1:0:6080` dynamically so multiple specialists stream live desktops over `novnc_ws` into Zone 3 simultaneously without port conflicts.
- **`E2BCloudComputer`:** Production microVM driver streaming via `webrtc`.
- **`HeadlessCIComputer`:** Deterministic non-GUI fallback used when `SANDBOX_DRIVER=headless_ci` in automated CI pipelines.
- **Zero-Knowledge Secret Proxy:** Resolves `{{VAULT:secret_ref}}` headers/cookies at the outbound container gateway so raw credentials never touch LLM context or database logs.

---

## 5. Subsystem 2: Two-Layer Institutional Vault (`packages/vault` + `vault/`)

1. **Layer A — Foundational Pod Skills (`vault://skills/<domain>/<slug>@v<semver>`):**
   Lightweight Markdown + schema playbooks under `/vault/skills/**` seeded in Sprint 0/1 so core bots (`coo.global-dispatcher`, `eng.connector-forge`, `qa.playwright-journey-bot`) resolve `vault://` URIs cleanly from Day 1.
2. **Layer B — 3D Practice & Industry Matrix (`vault://cells/<cell-slug>@v<semver>`):**
   Intersects **5 Client Archetypes** (`A_b2b_services` through `E_saas_tech_vendors`) × **4 Functional Practices** (`commercial_pricing`, `process_operating_model`, `governance_risk_compliance`, `clean_core_engineering`) × **5 Executable Cell Assets** (`intake.yaml`, `models/*.ts`, `SKILL.md`, `templates/*.ts`, `EVALS.yaml`).
3. **SHA-256 Evidence Ledger & `ReferenceCheckAuditor`:**
   Every source artifact and deterministic calculator run writes an immutable `SHA-256` digest and locator to `evidence_ledger`. `qa.reference-check-auditor` parses all `CitationBadge` objects before Gate 1 passes, blocking any hallucinated or orphan figure.

---

## 6. Subsystem 3: Containerized `REA` & `Craft Anything` Bridges (`packages/engines-bridge`)

- **`rea-mcp-worker` (`morluto/rea`):** Runs inside `offdata/sandbox-base:local` (which guarantees `procps` `ps` on `PATH`), sets `REA_MCP_TOOL_FAMILIES` (max 3 stack families) and `REA_MCP_TOOL_CATALOG_PROFILE=hot-cold` (`<= 15` exposed tools), verifies `engagement_authorizations` (`rea_deep_inspection`) for external targets, and outputs `ReaSystemXrayGraph` + `evidence_ledger` records.
- **`craft-mcp-worker` (`storytold/craft-anything`):** Wraps pre-compiled `craft-anything-cli mcp` in `clean-room` mode by default, orchestrating `01_study` (`web_site_capture`) → `02_build` (`@offdata/chassis`) → `03_check` (`web_pixels_compare`, `web_walkthrough_check`, `app_coverage_evaluate` + `Critiquito` `>= 90/100`) → `04_ready` (`investigation.cany` archived to `evidence_ledger`), rendering directly in `CraftBuildStageWorkbench`.

---

## 7. Cross-Package IPC Contracts, Voice-Pin Pipeline & 30-Table RLS Matrix

### Studio ↔ Runtime IPC Routes (`@offdata/contracts/ipc-contracts.ts`)
Implemented as Next.js Route Handlers under `apps/companyos/src/app/api/studio/*` so Parallel Threads `1A` and `1B` integrate with zero interface guesswork:
- `POST /api/studio/missions/dispatch` (`DispatchMissionRequest` → `DispatchMissionResponse`)
- `POST /api/studio/decisions/resolve` (`ResolveDecisionPacketRequest` supporting `speed_1_instant_override`, `speed_2_hot_seat_3m`, `speed_3_next_train_respin` + `promoteToVault`)
- `POST /api/studio/learnings/resolve` (`ResolveLearningProposalRequest` → mutates `firm_memories`, `agent_memories`, or branch PR for `vault://`)
- `POST /api/studio/sandbox/control` (`SandboxControlRequest`: `take_over`, `resume_agent`, `start_teach`, `stop_teach`)
- `POST /api/studio/voice-transcribe` (Accepts `multipart/form-data` `audio/webm` + spatial coordinates from Zone 2 Hold-Space-to-Speak, transcribes via AI Gateway audio model, and returns validated `SpatialPinVoiceCritique`)
- `POST /api/studio/telemetry/focus` (`RecordFocusSessionRequest` → commits active Founder seconds to `workspace_focus_sessions` & `true_cost_ledger`)

### 3-Role PostgreSQL RLS Security Matrix (All 30 Tables)
1. **`founder_admin`:** Full `ALL` access across all 30 tables in CompanyOS.
2. **`agent_worker` (JWT claims: `app_role = 'agent_worker'`, `tenant_id`, `workspace_id`, `agent_id`):**
   - **Read-Only (`SELECT`):** `tenants` (own `tenant_id`), `workspaces` (own `workspace_id`), `agent_profiles`, `firm_memories`, `vault_cells`, `autonomy_policies`, `engagement_authorizations` (own `workspace_id`), `agent_routines` (own `agent_id`), `products` & `product_versions` & `service_offerings` (own `tenant_id`).
   - **Scoped Read/Write (`SELECT, INSERT, UPDATE` matching `tenant_id` + `workspace_id`):** `evidence_ledger`, `artifacts`, `artifact_versions`, `tenant_memories`, `agent_runs`, `sandbox_sessions`, `learning_proposals` (`INSERT`/`SELECT` for own `agent_id`), `decision_packets` (`INSERT`/`SELECT`), `editorial_publications`, `crm_opportunities`, `advisory_engagements`, `venture_dossiers`, `product_launch_runs`, `true_cost_ledger` (`INSERT`/`SELECT` run costs), `outbox_events` (`INSERT`/`SELECT`).
   - ** Tier-2 Self-Scope:** `agent_memories` (`SELECT` where `agent_id = current_agent_id()`, `INSERT` only where `memory_kind = 'work_log'` and `agent_id = current_agent_id()`).
   - **Zero Access:** Cannot mutate `autonomy_policies`, `firm_memories`, `vault_cells`, `engagement_authorizations`, or any row belonging to another `tenant_id`.
3. **`client_portal_user` (JWT claims: `app_role = 'client_portal_user'`, `tenant_id`):**
   - `SELECT` on `artifacts` & `artifact_versions` ONLY where `tenant_id = current_tenant_id()` AND `client_portal_visible = true`.
   - `SELECT` on `advisory_engagements` and `customer_installations` matching `tenant_id = current_tenant_id()`. Zero access to internal memories, costs, or other tenants.

---

## 8. Synchronized Sprint 0–3 Dependency Graph

1. **Sprint 0 (Single Thread — Mission 0.1):** Workspace config, `.env.example`, `docker/sandbox-base.Dockerfile`, `@offdata/contracts` (`core-schemas.ts` + `ipc-contracts.ts`), `0001_companyos_kernel.sql`, seed `/vault/skills/**` & first 3 `.agent.yaml` manifests, plus multi-JWT RLS test suite across all 30 tables.
2. **Sprint 1 (Parallel Wave `1A` + `1B`, then `1C`):**
   - `1A`: `packages/agent-os` + `packages/vault/src/uri-resolver`
   - `1B`: `packages/chassis` (all 9 Widgets + Dual-Surface tokens + Focus Shadow-Time timer) + `apps/companyos` (3-Zone Studio + `/api/studio/*` handlers)
   - `1C`: End-to-end integration of `coo.global-dispatcher`, `eng.connector-forge`, and `qa.playwright-journey-bot` with Live Computer `Take Over`.
3. **Sprint 2 (Parallel Wave `2A` + `2B`):**
   - `2A`: `packages/engines-bridge` (`rea-worker` + `craft-worker`) + `qa.critiquito-design-auditor`
   - `2B`: Full `packages/vault` (3D Composer, `ReferenceCheckAuditor`, deterministic runner) + Production Vault Cell #01 (`a-b2b-services-client-delivery-ops`).
4. **Sprint 3 (Parallel Wave `3A` + `3B` + `3C`):**
   - `3A`: External Branded-House Apps (`offdata.com`, `clients.offdata.com`, `demo.offdata.com`)
   - `3B`: `engines/intelligence`, `engines/gtm`, and `engines/advisory` (Hard Deposit Gate + `ScopeAndMarginSentinelCard`)
   - `3C`: `engines/solutions` (70/20/10 Venture Office, 10-Step Idempotent Launch Pipeline, HTTP 402 MCP billing, Standing AI Product Owner & Merger Steward).