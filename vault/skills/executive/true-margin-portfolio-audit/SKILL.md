---
uri: "vault://skills/executive/true-margin-portfolio-audit@v1.0.0"
version: "1.0.0"
ownerPod: "01_executive_governance"
primaryAgent: "coo.global-dispatcher"
widgetType: "ExecutiveCooBriefing"
---

# True-Margin & Shadow-Time Portfolio Audit

## 1. Objective
Compute real contribution economics across all active workspaces—accounting for LLM/tool burn, sandbox compute, support rework, AND logged Founder Shadow-Time—to surface margin erosion before scaling unprofitable offerings.

## 2. Execution Protocol
1. **Read Deterministic Margin View:**
   - Query `economics.read_true_margins` (`v_workspace_true_margins`) across `intelligence`, `advisory`, and `solutions`. Never estimate margin percentages via LLM arithmetic.
2. **Enforce Studio Margin Thresholds:**
   - Flag `attention_needed` on Managed Advisory workspaces below `60%` True Contribution Margin or exceeding `120` Founder active minutes/month.
   - Flag `attention_needed` on SaaS/MCP Factory products below `80%` gross margin.
3. **Render Symmetric 3-Engine Briefing:**
   - Emit `ExecutiveCooBriefing` containing exactly three `engineOperatingCards` (`intelligence`, `advisory`, `solutions`) plus actionable `crossEngineOpportunities`.

## 3. Deterministic Gate 1 Checks
- `engineOperatingCards.length === 3`.
- All monetary and percentage metrics match `v_workspace_true_margins` rows to 2 decimal places.