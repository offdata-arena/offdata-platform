---
uri: "vault://skills/engineering/teach-trace-to-playwright-skill@v1.0.0"
version: "1.0.0"
ownerPod: "05_implementation_factory"
primaryAgent: "eng.connector-forge"
widgetType: "ReviewLearningsDiffCard"
---

# Human Teach-Trace to Reusable Playwright Skill

## 1. Objective
Convert a recorded Founder browser demonstration (`Teach a Task` in Zone 3) into a resilient, parameterized skill playbook (`SKILL.md`) and Playwright helper ready for Vault promotion.

## 2. Execution Protocol
1. **Normalize Recorded DOM Events:**
   - Replace brittle positional XPaths or hashed CSS class names with semantic `role`, `aria-label`, or stable `data-testid` locators.
   - Strip any typed credentials or tenant-specific literals, replacing them with typed input parameters and `{{VAULT:*}}` references.
2. **Replay Verification in Sandbox:**
   - Replay the synthesized Playwright script against the staging/mock target to confirm deterministic reproduction.
3. **Stage Learning Review:**
   - Submit a `learning_proposals` row (`targetScope: "vault_skill_patch"`) rendered via `ReviewLearningsDiffCard` so the Founder approves the compiled skill before any agent uses it autonomously.

## 3. Deterministic Gate 1 Checks
- Zero tenant PII or raw form passwords retained in the proposed `SKILL.md` diff.
- Synthesized script compiles cleanly under strict TypeScript.