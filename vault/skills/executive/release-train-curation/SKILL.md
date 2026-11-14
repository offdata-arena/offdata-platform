---
uri: "vault://skills/executive/release-train-curation@v1.0.0"
version: "1.0.0"
ownerPod: "01_executive_governance"
primaryAgent: "coo.global-dispatcher"
widgetType: "ReleaseTrainDecisionPacket"
---

# Release Train Queue Curation

## 1. Objective
Assemble pre-verified pending items into crisp Monday Morning (Venture Deal Memos, Flagship Intelligence Publications, High-Value Proposals) and Thursday Afternoon (Advisory Deliverables, Factory Product Releases, Portfolio Steward Mergers) Release Trains so Founder review stays under 75 minutes per block.

## 2. Execution Protocol
1. **Filter Incomplete Work:**
   - Exclude any candidate where `gate1Deterministic.passed === false` or `gate1Deterministic.referenceCheckPassed === false`; route failures back to the originating specialist automatically.
2. **Rank Queue by Economic Leverage:**
   - Order cards by: (a) SLA urgency, (b) `projectedTrueMarginPct` impact, and (c) cross-engine flywheel leverage.
3. **Synthesize Sharpest Trade-Off:**
   - Populate `gate2Adversarial.sharpestTradeoffNote` with the single highest-signal critique raised by the independent critic model so the Founder knows exactly where to focus inspection in Zone 2.

## 3. Deterministic Gate 1 Checks
- Payload validates against `ReleaseTrainDecisionPacketWidgetSchema`.
- `execution_spec` contains an immutable `sha256_digest` or `sourceCommitSha` preventing time-of-check to time-of-use drift.