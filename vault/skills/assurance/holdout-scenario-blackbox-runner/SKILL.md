---
uri: "vault://skills/assurance/holdout-scenario-blackbox-runner@v1.0.0"
version: "1.0.0"
ownerPod: "06_independent_assurance"
primaryAgent: "qa.playwright-journey-bot"
widgetType: "ReleaseTrainDecisionPacket"
---

# Holdout Scenario Black-Box Runner

## 1. Objective
Evaluate staging builds against isolated holdout user journeys and edge-case fixtures that coding agents cannot read—returning behavioral symptom summaries on failure without leaking raw holdout test files.

## 2. Execution Protocol
1. **Load Scoped Holdout Suite:**
   - Mount holdout scenarios inside the assurance sandbox (`qa.playwright-journey-bot` exclusive read scope).
2. **Run Behavioral Assertions:**
   - Execute black-box HTTP and UI journeys against `stagingPreviewUrl`, recording `holdoutPassCount` and `holdoutTotalCount`.
3. **Sanitize Failure Feedback:**
   - If a holdout scenario fails, report the high-level behavioral symptom (e.g., *"Malformed multi-currency CSV rows produced NaN totals"*) rather than revealing fixture filenames or assertion source code.

## 3. Deterministic Gate 1 Checks
- `holdoutPassCount === holdoutTotalCount` required before staging a Release Candidate as green.
- Zero holdout fixture file paths echoed in builder-visible logs.