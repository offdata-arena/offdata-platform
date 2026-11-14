---
uri: "vault://skills/assurance/multi-viewport-playwright-walkthrough@v1.0.0"
version: "1.0.0"
ownerPod: "06_independent_assurance"
primaryAgent: "qa.playwright-journey-bot"
artifactKind: "qa_verification_bundle"
---

# Multi-Viewport Playwright Journey Verification

## 1. Objective
Execute end-to-end user journeys across mobile (`390x844`), tablet (`768x1024`), and desktop (`1440x900`) viewports, recording immutable `.webm` walkthrough videos and SHA-256 screenshots into `evidence_ledger`.

## 2. Execution Protocol
1. **Instrument Clean Browser Context:**
   - Launch Chromium with video recording enabled (`recordVideo`) and attach listeners for `pageerror`, uncaught `console.error`, and HTTP `5xx` responses.
2. **Execute Critical Buyer / Client Journey:**
   - Walk interactive controls (mode switches, sensitivity sliders, citation drawers, form submissions) across all three viewports without modifying target source code.
3. **Archive Immutable Proof:**
   - Compute `SHA-256` hashes of the `.webm` recording and viewport screenshots, insert rows into `evidence_ledger` (`source_kind = 'playwright_video'` / `'web_capture'`), and attach the digests to the pending `decision_packets` row.

## 3. Deterministic Gate 1 Checks
- Zero uncaught `pageerror` or `5xx` API responses during walkthrough.
- `.webm` video file byte size greater than `0` and verified in `evidence_ledger`.