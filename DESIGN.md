# OFFDATA & CompanyOS — Institutional Visual System & Layout Specification (v2.0)

OFFDATA's visual architecture projects a 1,000-person Tier-1 advisory, research, and technology institution condensed into a high-precision executive workstation—combining **McKinsey / Financial Times editorial authority**, **Bloomberg / Linear keyboard speed**, **Grok Bot's living specialist presence**, and **Craft Anything's `Study -> Build -> Check -> Ready` clarity**.

---

## 1. Dual-Surface Color System

CompanyOS separates **Internal Operating Machinery (Precision Obsidian Chrome)** around the perimeter from **Executive & Client Deliverables (Warm Alabaster Editorial Paper)** on the center stage and public/client domains.

```css
:root {
  /* ==========================================================================
     SURFACE TIER A: OS STUDIO CHROME (Top Bar, Left Presence Rail, Right VM Drawer)
     ========================================================================== */
  --os-bg-canvas:        #0B0D10; /* Deepest workstation frame & technical graph stage */
  --os-bg-rail:          #0F1217; /* Zone 1: Left Practice & Pod Presence Rail */
  --os-bg-panel:         #141820; /* Zone 3: Right Live Computer & Decision Console */
  --os-bg-elevated:      #1B202B; /* Active pills, Cmd+K palette, hover surfaces */
  --os-border-hairline:  #232936; /* 1px crisp structural zone dividers */
  --os-border-strong:    #323B4E; /* Focused controls & active selection borders */

  --os-text-primary:     #F1F3F5; /* High-contrast crisp primary text */
  --os-text-secondary:   #9AA3B2; /* Supporting labels & inactive navigation */
  --os-text-muted:       #646E82; /* Timestamps, SHAs, keyboard shortcut hints */

  /* ==========================================================================
     SURFACE TIER B: EDITORIAL & DEAL-ROOM PAPER (Center Document Stage & Public Web)
     ========================================================================== */
  --paper-bg:            #FAF9F6; /* Warm institutional alabaster */
  --paper-surface:       #FFFFFF; /* Elevated financial tables & interactive modules */
  --paper-subtle:        #F2F0EB; /* Evidence footnotes, callout wells, subtle headers */
  --paper-border:        #E4E1DA; /* Crisp 1px editorial rule lines */
  --paper-border-strong: #C8C3B8; /* Financial summary rules & active table borders */

  --paper-ink-primary:   #111315; /* Deep charcoal-black primary ink */
  --paper-ink-secondary: #454A52; /* Analytical body prose */
  --paper-ink-muted:     #737982; /* Provenance hashes, captions, source locators */
  --paper-brand-navy:    #0F2537; /* Primary OFFDATA institutional accent */
  --paper-brand-slate:   #1E3A52; /* Interactive slider fills & primary buttons */

  /* ==========================================================================
     SEMANTIC PRESENCE & ASSURANCE SIGNALS (Strictly Functional — <5% Screen Area)
     ========================================================================== */
  --signal-vm-active:    #7C5CFF; /* Active Cloud Computer / Takeover Ready */
  --signal-vm-bg:        rgba(124, 92, 255, 0.12);

  --signal-verified:     #0D9488; /* Gate 1 + Gate 2 Verified / Reference-Checked */
  --signal-verified-bg:  rgba(13, 148, 136, 0.12);

  --signal-train-wait:   #D97706; /* Staged for Release Train / Human Takeover Needed */
  --signal-train-bg:     rgba(217, 119, 6, 0.12);

  --signal-critical:     #DC2626; /* Anti-Job Blocked / Margin Breach / Failed Eval */
  --signal-critical-bg:  rgba(220, 38, 38, 0.12);
}
```

### Surface Assignment Rules
- **Editorial & Commercial Artifacts** (`ExecutiveCooBriefing`, `IntelligencePublicationWorkbench`, `ExecutiveDealRoomMemo`, `VentureInvestmentDealMemo`, `offdata.com`, `clients.offdata.com`, `demo.offdata.com`) render on **Surface Tier B (`--paper-bg`)**.
- **Technical Inspection & Build Artifacts** (`ReaSystemXrayGraph`, `CraftBuildStageWorkbench` viewport canvas, Monaco code diffs, live terminal/browser streams) render on **Surface Tier A (`--os-bg-canvas`)** to maximize visual contrast during technical review.

---

## 2. Typography & Mandatory Numeric Alignment

1. **Font Families:**
   - **Institutional Editorial Display (`--font-editorial`):** `'Newsreader', 'Instrument Serif', Georgia, serif` — Weight `400`–`500`, tracking `-0.02em`, line-height `1.15`. Used for Executive Briefing headers, Intelligence report titles, SOW/Deal-Room headlines, Venture Deal Memos, and `offdata.com` hero statements.
   - **Precision UI & Analytical Prose (`--font-sans`):** `'Geist', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif` — Paper prose uses `15px` (`0.9375rem`) at `1.6` line-height with strict `68ch–74ch` max measure. Studio chrome uses `13px` (`0.8125rem`) for dense, scannable clarity.
   - **Technical, Evidence & Financial Mono (`--font-mono`):** `'JetBrains Mono', 'Geist Mono', monospace` — `12px` (`0.75rem`) for SHA-256 citation badges, commit digests, REA traces, token burn meters, and SLA clocks.
2. **Non-Negotiable Tabular Numeric Law:**
   Every currency value, margin percentage, score, timer, slider readout, and table cell MUST apply:
   ```css
   .numeric, table td, table th, [data-metric] {
     font-variant-numeric: tabular-nums lining-nums;
   }
   ```

---

## 3. The 3-Zone Institutional Studio Geometry (`app.offdata.com`)

`apps/companyos` uses a locked `100dvh x 100vw` viewport grid (`overflow: hidden` on `body`) divided by `1px solid var(--os-border-hairline)` borders, with exactly one independent vertical scroll container inside each zone.

```text
+--------------------------------------------------------------------------------------------------------+
| TOP COMMAND BAR (44px): [OFFDATA] | [Today | Intelligence | Advisory | Solutions] | [Cmd+K COO] | [VM] |
+------------------------+-----------------------------------------------------+-------------------------+
| ZONE 1: PRACTICE &     | ZONE 2: LIVING ARTIFACT STAGE                       | ZONE 3: LIVE COMPUTER   |
| POD PRESENCE (264px)   | (Flex 1fr — Min 640px)                              | & DECISION (420px)      |
|                        |                                                     |                         |
| > Today & AI COO       | Posture: [ Workbench ]   [ Review ]   [ Operate ]   | [o] Sandbox #04 (noVNC) |
| > Release Trains (4)   | --------------------------------------------------- | Agent: eng.connector    |
| > Review Learnings (2) |  +-----------------------------------------------+  | +---------------------+ |
|                        |  |                                               |  | | Live Browser / IDE  | |
| ENGINE WORKSPACES      |  |  9 Canonical Generative UI Widgets            |  | | / Terminal Stream   | |
| - AI-to-Commerce #01   |  |  (Deal Room / Publication / Venture Memo /    |  | |                     | |
| - Northstar Delivery   |  |   Craft 4-Step Stage / REA X-Ray / Briefing)  |  | +---------------------+ |
| - Scope Ops v1.0       |  |                                               |  | [Take Over] [Teach Task]|
|                        |  |  * Click any block/frame to drop Spatial Pin  |  | ----------------------- |
| ACTIVE POD ROSTER      |  |    + Hold SPACE to record 10s Voice Critique  |  | 3-SPEED ITERATION       |
| * rea-xray    [Active] |  +-----------------------------------------------+  | [A] Approve & Execute   |
| * scope-sent  [Idle]   |                                                     | [2] Hot-Seat (3m Delta) |
| * qa-journey  [14/16]  |  Footer: True Margin 74.2% | Shadow Time: 08m ($33) | [3] Next Train Re-Spin  |
+------------------------+-----------------------------------------------------+-------------------------+
```

### Ergonomics & Interaction Flows
1. **Top Command Bar (`44px`):**
   - Gives **equal first-class prominence** to `Today` (Executive COO Home) and the three business engines (`Intelligence`, `Advisory`, `Solutions`).
   - Center `Cmd+K` opens the contextual **Global AI COO Bar**—aware of the open Engine, active Workspace, selected artifact version, and live Pod roster.
   - Right **Live VM Pill** pulses `--signal-vm-active` whenever any container in `sandbox_sessions` is active; clicking toggles Zone 3.
2. **Zone 1 — Left Practice & Pod Presence Rail (`264px`, `Cmd+\` collapses to `56px`):**
   - Lists workspaces scoped to the selected Engine plus the **Active Specialist Pod Roster** streaming real-time activity lines (`"Verifying 18 SHA-256 citations"`), run burn (`$0.62`), and hover cards inspecting the bot's active `mcpTools` and memory scopes.
3. **Zone 2 — Center Living Artifact Stage (`minmax(640px, 1fr)`):**
   - **`Workbench` Posture:** Co-editing publications, Deal-Room proposals, Venture Deal Memos, REA graphs, or Craft builds.
   - **`Review` Posture:** Release Train evaluation mode enabling direct inline text/number overrides (`Speed 1`) and **Spatial Pin + Hold-Space-to-Speak**: clicking any DOM block or video timestamp drops a numbered pin and records `audio/webm` while `Space` is held, posting to `/api/studio/voice-transcribe` to create a structured `SpatialPinVoiceCritique`.
   - **`Operate` Posture:** Embedded live operations inside the asset itself—showing channel/lead attribution (Intelligence), SLA health & Scope Sentinel logs (Advisory), or customer installations, availability, AI Product Owner actions, and True Contribution Margin including logged Founder Shadow-Time (Solutions).
4. **Zone 3 — Right Live Computer & Decision Console (`420px`, expandable to `55vw` or Fullscreen):**
   - Embeds the live `webrtc` or `novnc_ws` desktop/browser stream of the active container.
   - **`Take Over`:** Unlocks immediate mouse/keyboard pass-through to clear SSO/2FA/CAPTCHA or adjust a visual detail, then clicks `Resume Agent`.
   - **`Teach a Task`:** Records human clicks/keystrokes inside the sandbox browser and emits a `sandbox.teach_trace_saved` event so `eng.connector-forge` compiles a draft `SKILL.md` into `Review Learnings`.

---

## 4. The 9 Canonical Generative UI Widgets (`@offdata/chassis/widgets`)

Every business engine and executive function renders through dedicated, schema-validated components—never generic chat markdown:

1. **`ExecutiveCooBriefing` (`Today & AI COO` Home):** Institutional morning/intraday briefing followed by **three equal Engine Operating Cards** (`Intelligence`, `Advisory`, `Solutions`) displaying pipeline velocity, True Contribution Margin, SLA health, Release Train queue counts, and 1-click cross-engine flywheel triggers.
2. **`IntelligencePublicationWorkbench` (`OFFDATA Intelligence`):** Split editorial canvas with source-evidence claim verification on the left, publication-grade article/benchmark editor in the center, and tabbed native channel previews (`offdata.com/intelligence`, LinkedIn, Newsletter, YouTube script/cut sheet, and AEO/GEO Share-of-Model citation check) + attributed lead counter.
3. **`ExecutiveDealRoomMemo` (`OFFDATA Advisory` & `clients.offdata.com`):** Alabaster strategy & diagnostic tear sheet featuring executive thesis, interactive ROI/utilization sensitivity sliders, baseline-vs-projected economics table, phased implementation pricing, and clickable `[SHA-256]` evidence citation drawers.
4. **`ScopeAndMarginSentinelCard` (`OFFDATA Advisory` Assurance):** Side-by-side diff of an inbound client request against the locked SOW/PRD clause, live True-Margin impact if absorbed unbilled, and a 1-click staged Stripe Change Order.
5. **`ReaSystemXrayGraph` (`OFFDATA Advisory` Discovery):** Interactive runtime architecture, undocumented API, and legacy dependency topology generated from `rea-agents`, highlighting clean-core blockers and verified runtime evidence traces.
6. **`VentureInvestmentDealMemo` (`OFFDATA Solutions` Venture Office):** 1-page Investment Committee tear sheet displaying `70/20/10` track allocation, 100-point composite underwriting breakdown (Spend Signal, Zero-Friction Onboarding, p95 Gross Margin, Wrapper Defense, Merger Fit), Skeptic Agent kill-risks, and bounded smoke-test budget authorization.
7. **`CraftBuildStageWorkbench` (`OFFDATA Solutions` Product Factory):** Displays the `01 Study -> 02 Build -> 03 Check -> 04 Ready` progress bar, live staging preview switchable across `390x844`, `768x1024`, and `1440x900`, pixel/walkthrough parity badges, Playwright video player, and `Critiquito` 100-point breakdown.
8. **`ReviewLearningsDiffCard` (Firm-Wide Governance):** Side-by-side diff of an agent's proposed Tier-1/Tier-2 memory rule or `vault://` `SKILL.md` patch, linked to the originating run trace, with `Approve to Vault` and `Discard` actions.
9. **`ReleaseTrainDecisionPacket` (Monday & Thursday Review Header):** Standardized decision wrapper uniting Gate 1 deterministic checks, Reference-Check status, Gate 2 adversarial critique & holdout score, run cost, True-Margin projection, and 3-Speed Iteration actions.

---

## 5. External Branded-House Surfaces & EU AI Act Article 50 Provenance

- **`offdata.com` (`apps/corporate-site`):** Editorial branded-house layout on `--paper-bg` (`#FAF9F6`) with `--paper-brand-navy` (`#0F2537`) accents across `/advisory`, `/intelligence`, `/solutions`, `/industries`, and `/company`. Zero fake team headcounts or stock robot imagery.
- **`clients.offdata.com` (`apps/client-portal`):** Calm, high-trust client workspace displaying only `client_portal_visible = true` Deal-Room memos, SOW scope trackers, UAT previews, 1-click acceptance + Stripe deposit/retainer checkout, and live Managed Ops SLA telemetry.
- **Article 50 Visual Provenance:**
  - Human-reviewed written publications signed off on a Release Train display an explicit **Named Principal Editorial Byline** (`"Reviewed & Published under OFFDATA Editorial Responsibility — [Principal Name]"`), satisfying the EU AI Act Article 50(4) human-editorial exemption cleanly.
  - Any synthetic video avatar or generated audio briefing automatically renders a persistent, subtle `"AI-Generated Digital Presenter"` corner badge and C2PA metadata manifest.

---

## 6. Banned Patterns & Automated `Critiquito` Gate 2 Rubric (`>= 90/100`)

### Immediate Visual Rejections
- Generic 4-card SaaS stat headers (`Users`, `Revenue`, `Active Bots`, `Tasks`) with pastel icons.
- Neon purple/pink/cyan gradients, heavy blur glassmorphism, container `border-radius > 8px` (use crisp `4px–6px`), or decorative drop shadows.
- Raw chat-bubble streams used as a primary studio screen.
- Any quantitative claim in an external or Review artifact missing a clickable `CitationBadge`.

### Automated 100-Point `Critiquito` Inspection (`qa.critiquito-design-auditor`)
Tested via Playwright at `1440x900` and `390x844` before any UI PR boards a Release Train:
1. **Surface & Focal Hierarchy (20 pts):** Crisp Obsidian-vs-Alabaster separation; primary artifact unmistakable within 2 seconds; equal top-level visibility of `Today`, `Intelligence`, `Advisory`, and `Solutions`.
2. **Typography & Tabular Numerics (20 pts):** Verified font loading (`Newsreader`, `Geist`, `JetBrains Mono`), `tabular-nums` computed on 100% of `[data-metric]` / `table td` elements, and prose width `<= 75ch`.
3. **Viewport & Scroll Integrity (20 pts):** `document.documentElement.scrollWidth === window.innerWidth` at both `1440px` and `390px`; zero nested competing vertical scrollbars per zone.
4. **Contrast & Signal Restraint (20 pts):** WCAG AA (`>= 4.5:1`) contrast across all text; semantic signal colors occupy under 5% of viewport pixels.
5. **Zero Placeholder / Slop Check (20 pts):** Zero `"Lorem ipsum"`, `"TODO"`, hardcoded mock banners, or broken citation drawers.