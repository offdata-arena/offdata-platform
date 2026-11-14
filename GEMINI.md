# OFFDATA & CompanyOS — Workspace Constitution (v2.0)

Keep these architectural, visual, security, and verification laws active across every planning artifact, code edit, terminal execution, and browser verification pass. Always cross-reference @DESIGN.md for UI/visual rules, @ARCHITECTURE.md for package and runtime structure, @contracts/src/core-schemas.ts and @contracts/src/ipc-contracts.ts for canonical schemas, and @database/migrations/0001_companyos_kernel.sql for persistence and Row-Level Security (RLS).

## 1. Institutional Identity & Core Mandate

1. **External Brand (`offdata.com`, `clients.offdata.com`, `demo.offdata.com`):** OFFDATA is an institutional, Big-Firm-calibre AI-Native Advisory, Intelligence, and Solutions company. Every public page and client Deal Room must project executive precision, verifiable evidence, and human editorial accountability—never consumer chatbot or generic SaaS aesthetics.
2. **Internal Operating System (`app.offdata.com` — CompanyOS):** Condenses a 1,000-person consulting, research, and engineering organization into ~35 typed Specialist Agent Profiles across **7 Persistent Pods**, a **3D Practice & Industry Matrix Vault**, and **isolated cloud computers** powered by `morluto/rea` and `storytold/craft-anything`.
3. **Equal Three-Engine Symmetry:** `OFFDATA Intelligence` (Communications & Research), `OFFDATA Advisory` (Consulting & Managed Delivery), and `OFFDATA Solutions` (Venture Studio & Product Factory) are equal first-class business modules supervised through `Today & Global AI COO`—never subordinate tabs inside a dev dashboard.
4. **Anti-Dashboard Mandate:** CompanyOS is NOT a static CRUD admin panel or chat wrapper. It is a living 3-zone institutional studio combining active specialist presence, publication-grade interactive artifacts, closed-loop visual building, and a pinned Live Computer stream with 1-Click Human Takeover.

## 2. Monorepo Boundaries, Casing & Schema-First Laws

- **Workspace Packages:**
  - `apps/companyos` — Internal 3-Zone Executive Studio (`app.offdata.com`)
  - `apps/client-portal` — Authenticated Client Deal Rooms, UAT & SLA health (`clients.offdata.com`)
  - `apps/corporate-site` — Public branded-house presence (`offdata.com`)
  - `apps/demo-sandbox` — Compute-capped zero-login diagnostics & Field Notes (`demo.offdata.com`)
  - `contracts` (`@offdata/contracts`) — Canonical Zod entity schemas (`core-schemas.ts`) and API/IPC request-response contracts (`ipc-contracts.ts`)
  - `packages/agent-os` (`@offdata/agent-os`) — `.agent.yaml` registry, `ToolGateway`, 3-tier memory, Trigger.dev routines, Zero-Knowledge Vault proxy, Live Computer pool, `connector-forge`
  - `packages/vault` (`@offdata/vault`) — `vault://` URI skill loader, 3D Matrix Composer (`Archetype x Practice x Assets`), deterministic model runner, SHA-256 `evidence_ledger` & `ReferenceCheckAuditor`
  - `packages/engines-bridge` (`@offdata/engines-bridge`) — Containerized MCP adapters for `rea-agents` and `craft-anything-cli`
  - `packages/chassis` (`@offdata/chassis`) — Dual-Surface UI primitives, all 9 Generative UI Widgets, RLS client builders, Stripe Billing/Meters/HTTP-402 helpers, and True-Cost Shadow-Time telemetry
  - `engines/intelligence`, `engines/gtm`, `engines/advisory`, `engines/solutions` — Durable business lifecycle state machines
- **Import Boundary Law:** Never use deep relative imports across packages (`../../../packages/*`). Import strictly through workspace package entrypoints (`@offdata/*`).
- **Strict Naming & Casing Law:**
  - **YAML, Zod, TypeScript & JSON APIs:** Strictly **`camelCase`** (`antiJobs`, `memoryScopes`, `mcpTools`, `vaultSecretRefs`, `expectedArtifactType`, `approvalBoundary`, `maxBudgetUsdPerRun`).
  - **PostgreSQL Tables, Columns & SQL Enums:** Strictly **`snake_case`** (`anti_jobs`, `memory_scopes`, `mcp_tools`, `vault_secret_refs`, `tenant_id`, `workspace_id`). Map cleanly in data-access repositories; never mix conventions inside `.agent.yaml` files.
- **Schema-First Law:** Any new data model, Generative UI widget, cross-engine event, or frontend-to-backend route MUST be declared in `@offdata/contracts` (`core-schemas.ts` or `ipc-contracts.ts`) before implementation.

## 3. "Poteto-Mode" Agent, RLS & Security Invariants

1. **One Job & Deterministic `antiJobs`:** Every specialist agent requires a declarative `.agent.yaml` manifest validated by `AgentManifestSchema`. `ToolGateway` in `@offdata/agent-os` must deterministically block any tool call not listed in `mcpTools` OR violating `antiJobs` (setting run status to `halted_anti_job`).
2. **Zero Direct LLM External Side-Effects:** Agents never send external emails, mutate Stripe billing, publish social/web posts, run production schema migrations, or merge to `main` directly. Agents stage `DecisionPacket` proposals; deterministic TypeScript executors run side-effects only after Stage-1 Founder approval or deterministic `autonomy_policies` clearance (Stage 2/3).
3. **3-Role PostgreSQL RLS Across All 30 Tables:**
   - Every operational table has `ENABLE ROW LEVEL SECURITY` and `FORCE ROW LEVEL SECURITY`.
   - Never inject a Supabase `service_role` client into an agent tool or client portal handler. Always construct a JWT-scoped client (`app_role` = `founder_admin` | `agent_worker` | `client_portal_user`, bound to `tenant_id`, `workspace_id`, and `agent_id`).
   - Different client tenants MUST NEVER share a sandbox container, browser session, or Tier-3 memory scope.
4. **Zero-Knowledge Secret Vault:** Plaintext API keys, OAuth tokens, and passwords must NEVER enter LLM prompts, `agent_memories`, or logs. Agents use symbolic `{{VAULT:secret_ref}}` placeholders resolved strictly inside the outbound network/browser proxy in `@offdata/agent-os`.
5. **Reference-Check Law:** No Advisory assessment, Intelligence publication, or Venture Deal Memo may enter Founder Review with unverified numbers or quotes. Every quantitative claim must attach a `CitationBadge` whose `sha256Hash` and `locator` pass deterministic verification against `evidence_ledger`.

## 4. Embeddings, Sandbox Base Image & REA / Craft Anything Laws

1. **Fixed `1536`-Dimension Vector Law:** Every `pgvector` column in PostgreSQL is typed `VECTOR(1536)`. Every embedding call across the monorepo MUST explicitly pass `outputDimensionality: 1536` (for Gemini embedding models) or `dimensions: 1536` (for OpenAI embedding models) and assert `vector.length === 1536` prior to insert.
2. **Pre-Baked Sandbox Image & Dynamic Ports:**
   - Local live computers build from `docker/sandbox-base.Dockerfile` (`offdata/sandbox-base:local`), which pre-installs `procps` (`ps` binary), `Xvfb`, Chromium, `x11vnc`, `websockify`, Playwright, `rea-agents`, and `craft-anything-cli`.
   - Never hardcode host port `6080`; bind dynamically (`127.0.0.1:0:6080`) and inspect the assigned port so parallel specialist containers never collide. Support `SANDBOX_DRIVER=headless_ci` for headless automated test runs.
3. **`morluto/rea` (`@offdata/engines-bridge/rea-worker`):**
   - Never expose the full 220+ REA MCP tool catalog to an LLM. Always set `REA_MCP_TOOL_FAMILIES` (max 3 families) and `REA_MCP_TOOL_CATALOG_PROFILE=hot-cold` so exposed tools stay at or below 15.
   - If `isExternalClientTarget === true`, verify an active, unrevoked row in `engagement_authorizations` (`scope_type = 'rea_deep_inspection'`) matching `tenant_id` before booting the container.
4. **`storytold/craft-anything` (`@offdata/engines-bridge/craft-worker`):**
   - Invoke `craft-anything-cli mcp` defaulting strictly to `mode: "clean-room"`. Block `deep` mode unless `engagement_authorizations` contains a valid `craft_deep_mode` grant.

## 5. UI, 9 Canonical Widgets & Anti-Slop Laws (See `@DESIGN.md`)

- Read `@DESIGN.md` before creating or editing any `.tsx` or `.css` file.
- Render structured operational outputs exclusively through the **9 Canonical Generative UI Widgets** (`ExecutiveCooBriefing`, `IntelligencePublicationWorkbench`, `ExecutiveDealRoomMemo`, `ScopeAndMarginSentinelCard`, `ReaSystemXrayGraph`, `VentureInvestmentDealMemo`, `CraftBuildStageWorkbench`, `ReviewLearningsDiffCard`, `ReleaseTrainDecisionPacket`).
- **Hard Visual Bans:** Zero 4-card SaaS KPI stat rows; zero purple/cyan neon AI gradients; zero chat-bubble streams as primary workspace screens; mandatory `tabular-nums` on all numeric/financial text; zero nested competing vertical scrollbars.

## 6. Antigravity Definition of Done

1. **Plan & File-Lock Check:** In Planning Mode, confirm file paths match `@ARCHITECTURE.md` and respect the active mission's **Owned Paths** lock when running parallel Agent Manager threads.
2. **Real Persistence Over Mocks:** Wire real Zod validation, RLS-scoped PostgreSQL queries, and typed `@offdata/contracts` IPC routes. Track capability maturity honestly (`designed -> implemented -> integrated -> operationally_verified`).
3. **Deterministic Gate 1:** Run `pnpm turbo run typecheck`, `pnpm turbo run lint`, and `pnpm turbo run test` with zero errors before finishing any mission.
4. **Browser Agent & `Critiquito` Gate 2 (`>= 90/100`):** For all `apps/*` changes, launch the Antigravity Browser Agent against `1440x900` and `390x844`, exercise interactive states (Engine switcher, `Cmd+K` COO, Spatial Voice Pin, Zone 3 Live Computer drawer), and verify full compliance with `@DESIGN.md`.