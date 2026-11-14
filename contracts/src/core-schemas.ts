import { z } from "zod";

/* ============================================================================
 * 1. CORE COMPANYOS ENUMS, VOCABULARIES & VECTOR INVARIANTS
 * ========================================================================== */

export const BusinessEngineSchema = z.enum([
    "executive",
    "intelligence",
    "advisory",
    "solutions",
]);
export type BusinessEngine = z.infer<typeof BusinessEngineSchema>;

export const StudioPostureSchema = z.enum(["workbench", "review", "operate"]);
export type StudioPosture = z.infer<typeof StudioPostureSchema>;

export const EnvironmentTierSchema = z.enum(["production", "frontier"]);
export type EnvironmentTier = z.infer<typeof EnvironmentTierSchema>;

export const CapabilityMaturitySchema = z.enum([
    "designed",
    "implemented",
    "integrated",
    "operationally_verified",
]);
export type CapabilityMaturity = z.infer<typeof CapabilityMaturitySchema>;

export const SpecialistPodSchema = z.enum([
    "01_executive_governance",
    "02_intelligence_editorial",
    "03_gtm_revenue",
    "04_advisory_discovery",
    "05_implementation_factory",
    "06_independent_assurance",
    "07_managed_ops_venture",
]);
export type SpecialistPod = z.infer<typeof SpecialistPodSchema>;

export const AutonomyStageSchema = z.enum([
    "stage_1_founder_gate",
    "stage_2_optimistic_veto_2h",
    "stage_3_earned_autopilot",
]);
export type AutonomyStage = z.infer<typeof AutonomyStageSchema>;

export const ReleaseTrainSlotSchema = z.enum([
    "monday_am",
    "thursday_pm",
    "immediate_p0",
    "internal_auto",
]);
export type ReleaseTrainSlot = z.infer<typeof ReleaseTrainSlotSchema>;

export const IterationSpeedSchema = z.enum([
    "speed_1_instant_override",
    "speed_2_hot_seat_3m",
    "speed_3_next_train_respin",
]);
export type IterationSpeed = z.infer<typeof IterationSpeedSchema>;

export const IngestionPatternSchema = z.enum([
    "outside_in_recon",
    "cc_the_vault",
    "scoped_oauth_snapshot",
    "local_zero_exfil_collector",
    "silent_work_along_capture",
]);
export type IngestionPattern = z.infer<typeof IngestionPatternSchema>;

export const InvestmentTrackSchema = z.enum([
    "core_70",
    "adjacent_20",
    "frontier_10",
]);
export type InvestmentTrack = z.infer<typeof InvestmentTrackSchema>;

export const ArtifactKindSchema = z.enum([
    "coo_briefing",
    "editorial_publication",
    "deal_room_memo",
    "proposal_sow",
    "prd_spec",
    "venture_deal_memo",
    "craft_application",
    "rea_xray_report",
    "change_order",
    "qa_verification_bundle",
    "mission_dispatch_plan",
    "portfolio_health_report",
]);
export type ArtifactKind = z.infer<typeof ArtifactKindSchema>;

export const FirmMemoryCategorySchema = z.enum([
    "commercial_policy",
    "scoping_heuristic",
    "pricing_benchmark",
    "incumbent_weakness",
    "content_hook_pattern",
    "founder_taste_rule",
    "technical_api_gotcha",
    "qa_regression_pattern",
    "merger_synergy_rule",
]);
export type FirmMemoryCategory = z.infer<typeof FirmMemoryCategorySchema>;

export const WidgetTypeSchema = z.enum([
    "ExecutiveCooBriefing",
    "IntelligencePublicationWorkbench",
    "ExecutiveDealRoomMemo",
    "ScopeAndMarginSentinelCard",
    "ReaSystemXrayGraph",
    "VentureInvestmentDealMemo",
    "CraftBuildStageWorkbench",
    "ReviewLearningsDiffCard",
    "ReleaseTrainDecisionPacket",
]);
export type WidgetType = z.infer<typeof WidgetTypeSchema>;

export const ExpectedRoutineOutputSchema = z.union([
    ArtifactKindSchema,
    WidgetTypeSchema,
]);
export type ExpectedRoutineOutput = z.infer<typeof ExpectedRoutineOutputSchema>;

/** Enforces the 1536-dimension pgvector law before database insert */
export const EmbeddingVector1536Schema = z
    .array(z.number().finite())
    .length(1536);
export type EmbeddingVector1536 = z.infer<typeof EmbeddingVector1536Schema>;

/* ============================================================================
 * 2. SUBSYSTEM 1: AGENT OS (.agent.yaml, 3-TIER MEMORY, ROUTINES, LIVE VM)
 * ========================================================================== */

export const VaultUriSchema = z
    .string()
    .regex(
        /^vault:\/\/(skills|cells)\/[a-z0-9-]+(?:\/[a-z0-9-]+)*@v\d+\.\d+\.\d+$/,
        "Must match vault://skills/<domain>/<slug>@vX.Y.Z or vault://cells/<slug>@vX.Y.Z"
    );
export type VaultUri = z.infer<typeof VaultUriSchema>;

export const AgentRoutineSpecSchema = z.object({
    id: z.string().regex(/^[a-z0-9-]+$/),
    trigger: z
        .string()
        .regex(
            /^(cron:.+|event:[a-z0-9_]+\.[a-z0-9_]+)$/,
            "Must start with 'cron:' or 'event:<domain>.<action>'"
        ),
    timezone: z.string().default("Asia/Singapore"),
    expectedArtifactType: ExpectedRoutineOutputSchema,
    approvalBoundary: z.string().min(3),
    maxDurationSeconds: z.number().int().min(10).max(3600).default(600),
});
export type AgentRoutineSpec = z.infer<typeof AgentRoutineSpecSchema>;

export const AgentManifestSchema = z.object({
    id: z
        .string()
        .regex(/^[a-z0-9-]+\.[a-z0-9-]+$/)
        .describe("camelCase manifest file; ID formatted as '<domain>.<role-slug>'"),
    title: z.string().min(3).max(120),
    pod: SpecialistPodSchema,
    practice: z.string().min(3),
    avatarPresence: z.string().min(3),
    mandate: z.string().min(20).max(900),
    antiJobs: z
        .array(z.string().min(10))
        .min(1)
        .describe("Poteto-mode hard blocks enforced deterministically by ToolGateway"),
    memoryScopes: z.object({
        read: z.array(z.string()),
        writeAuto: z.array(z.enum(["agent.work_log"])).default(["agent.work_log"]),
        writeRequiresLearningReview: z.array(z.string()).default([]),
    }),
    skills: z.array(VaultUriSchema).min(1),
    routines: z.array(AgentRoutineSpecSchema).max(50).default([]),
    integrationsAndVault: z.object({
        mcpTools: z.array(z.string()).min(1),
        vaultSecretRefs: z
            .array(z.string().regex(/^[A-Z0-9_]+$/))
            .default([])
            .describe("Symbolic uppercase refs only; resolved inside outbound proxy"),
        runtimeIsolation: z
            .enum(["stateless_worker", "ephemeral_tenant_sandbox"])
            .default("ephemeral_tenant_sandbox"),
    }),
    modelRouting: z.object({
        workerModel: z.string().default("gemini-2.5-pro"),
        criticModel: z.string().default("claude-sonnet-4-5"),
        maxBudgetUsdPerRun: z.number().positive().max(50).default(5.0),
    }),
});
export type AgentManifest = z.infer<typeof AgentManifestSchema>;

export const LearningProposalSchema = z.object({
    id: z.string().uuid(),
    agentId: z.string(),
    sourceRunId: z.string().uuid(),
    targetScope: z.enum(["firm_memory", "agent_rule", "vault_skill_patch"]),
    firmMemoryCategory: FirmMemoryCategorySchema.nullable().default(null),
    targetIdentifier: z.string(),
    proposedAssertionOrDiff: z.string().min(10),
    evidenceSummary: z.string().min(5),
    confidence: z.number().min(0).max(1),
    status: z.enum(["pending", "approved", "discarded"]).default("pending"),
});
export type LearningProposal = z.infer<typeof LearningProposalSchema>;

export const SandboxDriverSchema = z.enum([
    "docker_local",
    "e2b_cloud",
    "headless_ci",
]);
export type SandboxDriver = z.infer<typeof SandboxDriverSchema>;

export const StreamProtocolSchema = z.enum([
    "webrtc",
    "novnc_ws",
    "headless_none",
]);
export type StreamProtocol = z.infer<typeof StreamProtocolSchema>;

export const LiveComputerSessionSchema = z.object({
    id: z.string().uuid(),
    workspaceId: z.string().uuid(),
    tenantId: z.string().uuid(),
    agentRunId: z.string().uuid(),
    driver: SandboxDriverSchema,
    streamProtocol: StreamProtocolSchema,
    streamEndpointUrl: z.string().url().nullable(),
    assignedHostPort: z.number().int().positive().nullable().default(null),
    status: z.enum([
        "booting",
        "agent_operating",
        "awaiting_takeover",
        "human_takeover_active",
        "teach_recording",
        "terminated",
    ]),
    currentActivityLine: z.string().max(180),
    takeoverReason: z.string().nullable().default(null),
});
export type LiveComputerSession = z.infer<typeof LiveComputerSessionSchema>;

/* ============================================================================
 * 3. SUBSYSTEM 2: 3D INSTITUTIONAL VAULT & SHA-256 EVIDENCE LEDGER
 * ========================================================================== */

export const ClientArchetypeSchema = z.enum([
    "A_b2b_services",
    "B_regulated_finance",
    "C_supply_chain_industrial",
    "D_pe_ma_rollups",
    "E_saas_tech_vendors",
]);
export type ClientArchetype = z.infer<typeof ClientArchetypeSchema>;

export const FunctionalPracticeSchema = z.enum([
    "commercial_pricing",
    "process_operating_model",
    "governance_risk_compliance",
    "clean_core_engineering",
]);
export type FunctionalPractice = z.infer<typeof FunctionalPracticeSchema>;

export const VaultCellManifestSchema = z.object({
    cellSlug: z.string().regex(/^[a-z0-9-]+$/),
    versionSemver: z.string().regex(/^\d+\.\d+\.\d+$/).default("1.0.0"),
    title: z.string(),
    archetype: ClientArchetypeSchema,
    practice: FunctionalPracticeSchema,
    industryTags: z.array(z.string()).default([]),
    maturity: CapabilityMaturitySchema,
    assets: z.object({
        intakeProtocolPath: z.string().endsWith("intake.yaml"),
        deterministicModelsDir: z.string(),
        skillPlaybookPath: z.string().endsWith("SKILL.md"),
        dealRoomTemplatePath: z.string(),
        evalsSuitePath: z.string().endsWith("EVALS.yaml"),
    }),
    supportedIngestionPatterns: z.array(IngestionPatternSchema).min(1),
});
export type VaultCellManifest = z.infer<typeof VaultCellManifestSchema>;

export const CitationBadgeSchema = z.object({
    evidenceId: z.string().uuid(),
    sha256Hash: z.string().length(64),
    sourceLabel: z.string().max(140),
    locator: z
        .string()
        .min(1)
        .describe("Verified page, line range, or JSONPath inside evidence_ledger"),
    excerpt: z.string().max(500),
});
export type CitationBadge = z.infer<typeof CitationBadgeSchema>;

/* ============================================================================
 * 4. SUBSYSTEM 3: REA & CRAFT ANYTHING ENGINE BRIDGE CONTRACTS
 * ========================================================================== */

export const ReaToolFamilySchema = z.enum([
    "javascript",
    "web",
    "dotnet",
    "jvm",
    "native",
    "elf",
    "macho",
    "pe",
    "network",
]);
export type ReaToolFamily = z.infer<typeof ReaToolFamilySchema>;

export const ReaInspectionTaskSchema = z.object({
    workspaceId: z.string().uuid(),
    tenantId: z.string().uuid(),
    isExternalClientTarget: z.boolean(),
    authorizationArtifactId: z.string().uuid().nullable(),
    toolFamilies: z
        .array(ReaToolFamilySchema)
        .min(1)
        .max(3)
        .describe("Hard cap at 3 stack families so exposed MCP tools stay <= 15"),
    catalogProfile: z.enum(["hot-cold", "minimal"]).default("hot-cold"),
    targetEntrypoint: z.string().min(1),
});
export type ReaInspectionTask = z.infer<typeof ReaInspectionTaskSchema>;

export const CraftStageSchema = z.enum([
    "01_study",
    "02_build",
    "03_check",
    "04_ready",
]);
export type CraftStage = z.infer<typeof CraftStageSchema>;

export const CritiquitoAuditScoreSchema = z.object({
    surfaceAndHierarchy: z.number().min(0).max(20),
    typographyAndTabularNums: z.number().min(0).max(20),
    zeroViewportClipping: z.number().min(0).max(20),
    wcagContrastAndRestraint: z.number().min(0).max(20),
    antiSlopCompliance: z.number().min(0).max(20),
    totalScore: z.number().min(0).max(100),
    passed: z.boolean().describe("Requires totalScore >= 90 and zero blockingViolations"),
    blockingViolations: z.array(z.string()),
});
export type CritiquitoAuditScore = z.infer<typeof CritiquitoAuditScoreSchema>;

export const CraftBuildTaskSchema = z.object({
    workspaceId: z.string().uuid(),
    tenantId: z.string().uuid(),
    mode: z.enum(["clean-room", "deep"]).default("clean-room"),
    authorizationArtifactId: z.string().uuid().nullable().default(null),
    currentStage: CraftStageSchema,
    viewportsTested: z
        .array(z.enum(["390x844", "768x1024", "1440x900"]))
        .default(["390x844", "768x1024", "1440x900"]),
    pixelParityScore: z.number().min(0).max(100).nullable(),
    walkthroughPassed: z.boolean(),
    investigationCanyDigest: z.string().length(64).nullable(),
});
export type CraftBuildTask = z.infer<typeof CraftBuildTaskSchema>;

/* ============================================================================
 * 5. ALL 9 CANONICAL GENERATIVE UI WIDGETS & SPATIAL VOICE ITERATION
 * ========================================================================== */

export const SpatialPinVoiceCritiqueSchema = z.object({
    pinId: z.string().uuid(),
    artifactVersionId: z.string().uuid(),
    viewport: z
        .enum(["390x844", "768x1024", "1440x900", "document"])
        .default("document"),
    domSelectorOrBlockId: z.string().min(1),
    coordinatesPct: z.object({
        x: z.number().min(0).max(100),
        y: z.number().min(0).max(100),
    }),
    videoTimestampSec: z.number().nonnegative().nullable().default(null),
    voiceTranscript: z.string().min(1),
    quickRejectionTags: z.array(z.string()).default([]),
    requestedSpeed: IterationSpeedSchema,
    promoteToVaultRule: z.boolean().default(false),
});
export type SpatialPinVoiceCritique = z.infer<typeof SpatialPinVoiceCritiqueSchema>;

/** Widget 1: Today & Global AI COO Executive Home (Symmetric 3-Engine Pulse) */
export const ExecutiveCooBriefingWidgetSchema = z.object({
    widgetType: z.literal("ExecutiveCooBriefing"),
    briefingDateIso: z.string(),
    executiveHeadline: z.string(),
    cooNarrativeSummary: z.string(),
    firmTrueContributionUsd30d: z.number(),
    firmTrueMarginPct30d: z.number(),
    founderShadowHours7d: z.number().nonnegative(),
    pendingMondayTrainCount: z.number().int().nonnegative(),
    pendingThursdayTrainCount: z.number().int().nonnegative(),
    pendingLearningsCount: z.number().int().nonnegative(),
    engineOperatingCards: z
        .array(
            z.object({
                engine: z.enum(["intelligence", "advisory", "solutions"]),
                directorAgentId: z.string(),
                primaryMetricLabel: z.string(),
                primaryMetricValue: z.string(),
                secondaryMetricLabel: z.string(),
                secondaryMetricValue: z.string(),
                activeWorkspacesCount: z.number().int().nonnegative(),
                healthStatus: z.enum(["healthy", "attention_needed", "critical"]),
                topPriorityNote: z.string(),
            })
        )
        .length(3),
    crossEngineOpportunities: z.array(
        z.object({
            opportunityId: z.string().uuid(),
            title: z.string(),
            originEngine: BusinessEngineSchema,
            targetEngines: z.array(BusinessEngineSchema).min(1),
            rationale: z.string(),
            suggestedCommandPrompt: z.string(),
        })
    ),
});

export const EditorialChannelSchema = z.enum([
    "offdata_web",
    "linkedin_article",
    "executive_newsletter",
    "youtube_demo_script",
    "aeo_citation_pack",
]);
export type EditorialChannel = z.infer<typeof EditorialChannelSchema>;

/** Widget 2: OFFDATA Intelligence Publication & Channel Preview Workbench */
export const IntelligencePublicationWorkbenchWidgetSchema = z.object({
    widgetType: z.literal("IntelligencePublicationWorkbench"),
    publicationProperty: z.enum([
        "intelligence_brief",
        "field_note",
        "operating_benchmark",
    ]),
    title: z.string(),
    thesisSummary: z.string(),
    article50Governance: z.object({
        humanEditorialByline: z.string(),
        containsSyntheticMedia: z.boolean(),
        c2paManifestAttached: z.boolean(),
    }),
    canonicalBodyMarkdown: z.string(),
    verifiedClaims: z
        .array(
            z.object({
                claimStatement: z.string(),
                citation: CitationBadgeSchema,
            })
        )
        .min(1),
    channelVariants: z.array(
        z.object({
            channel: EditorialChannelSchema,
            headlineOrHook: z.string(),
            formattedPreview: z.string(),
            ctaTargetUrl: z.string().url(),
        })
    ),
    attributedLeadsCount: z.number().int().nonnegative().default(0),
});

/** Widget 3: OFFDATA Advisory & Client Portal Living Deal-Room Memo */
export const ExecutiveDealRoomMemoWidgetSchema = z.object({
    widgetType: z.literal("ExecutiveDealRoomMemo"),
    headline: z.string(),
    clientOrSubjectName: z.string(),
    editorialStatus: z.enum(["draft", "reference_checked", "founder_signed_off"]),
    executiveSummary: z.string(),
    sensitivityDrivers: z.array(
        z.object({
            key: z.string(),
            label: z.string(),
            unit: z.enum(["usd", "pct", "hours", "count"]),
            min: z.number(),
            max: z.number(),
            defaultValue: z.number(),
        })
    ),
    economicsComparison: z.array(
        z.object({
            metricLabel: z.string(),
            baselineValue: z.string(),
            projectedValue: z.string(),
            deltaLabel: z.string(),
            citation: CitationBadgeSchema,
        })
    ),
    recommendations: z.array(
        z.object({
            phase: z.string(),
            title: z.string(),
            outcomePromise: z.string(),
            fixedFeeOrPriceUsd: z.number().nonnegative(),
            citations: z.array(CitationBadgeSchema).min(1),
        })
    ),
});

/** Widget 4: OFFDATA Advisory Scope & Margin Sentinel Card */
export const ScopeAndMarginSentinelCardWidgetSchema = z.object({
    widgetType: z.literal("ScopeAndMarginSentinelCard"),
    engagementTitle: z.string(),
    inboundRequestExcerpt: z.string(),
    lockedSowClauseRef: z.string(),
    classification: z.enum([
        "in_scope",
        "out_of_scope_change_order",
        "margin_breach_risk",
    ]),
    currentTrueMarginPct: z.number(),
    projectedMarginIfAbsorbedPct: z.number(),
    stagedChangeOrder: z
        .object({
            deliverableTitle: z.string(),
            proposedFeeUsd: z.number().positive(),
            estimatedAgentCostUsd: z.number().nonnegative(),
            draftClientNote: z.string(),
        })
        .nullable(),
});

/** Widget 5: REA Runtime & Legacy System X-Ray Graph */
export const ReaSystemXrayGraphWidgetSchema = z.object({
    widgetType: z.literal("ReaSystemXrayGraph"),
    systemName: z.string(),
    inspectedStack: z.array(ReaToolFamilySchema),
    nodes: z.array(
        z.object({
            id: z.string(),
            label: z.string(),
            kind: z.enum([
                "service",
                "legacy_binary",
                "undocumented_api",
                "datastore",
                "clean_core_blocker",
            ]),
            hotspotRiskScore: z.number().min(0).max(100),
            citation: CitationBadgeSchema,
        })
    ),
    edges: z.array(
        z.object({
            source: z.string(),
            target: z.string(),
            protocol: z.string(),
            verifiedAtRuntime: z.boolean(),
        })
    ),
});

/** Widget 6: OFFDATA Solutions 70/20/10 Venture Investment Deal Memo */
export const VentureInvestmentDealMemoWidgetSchema = z.object({
    widgetType: z.literal("VentureInvestmentDealMemo"),
    dossierSlug: z.string(),
    ventureTitle: z.string(),
    investmentTrack: InvestmentTrackSchema,
    recommendedVerdict: z.enum([
        "greenlight_factory_wedge",
        "route_to_advisory_pilot",
        "kill_and_archive",
    ]),
    scoringPillars: z.object({
        verifiedSpendSignal30: z.number().min(0).max(30),
        zeroFrictionOnboarding25: z.number().min(0).max(25),
        grossMarginAndMoat20: z.number().min(0).max(20),
        diagnosticDistributionHook15: z.number().min(0).max(15),
        sharedChassisAndMergerFit10: z.number().min(0).max(10),
        compositeScore100: z.number().min(0).max(100),
    }),
    unitEconomicsModel: z.object({
        targetMonthlyArpuUsd: z.number().nonnegative(),
        p95MonthlyAiAndInfraCostUsd: z.number().nonnegative(),
        projectedGrossMarginPct: z.number(),
        smokeTestBudgetCapUsd: z.number().nonnegative().max(500),
    }),
    skepticKillRisks: z.array(z.string()).min(1),
    spendEvidenceCitations: z.array(CitationBadgeSchema).min(1),
});

/** Widget 7: Craft Anything 4-Stage Factory Build Workbench */
export const CraftBuildStageWorkbenchWidgetSchema = z.object({
    widgetType: z.literal("CraftBuildStageWorkbench"),
    productTitle: z.string(),
    stage: CraftStageSchema,
    mode: z.enum(["clean-room", "deep"]),
    stagingPreviewUrl: z.string().url(),
    playwrightWalkthroughVideoUrl: z.string().url().nullable(),
    viewportChecks: z.array(
        z.object({
            viewport: z.enum(["390x844", "768x1024", "1440x900"]),
            parityScore: z.number().min(0).max(100),
            screenshotUrl: z.string().url(),
            passed: z.boolean(),
        })
    ),
    critiquitoAudit: CritiquitoAuditScoreSchema,
});

/** Widget 8: Grok-Style Review Learnings Governance Diff Card */
export const ReviewLearningsDiffCardWidgetSchema = z.object({
    widgetType: z.literal("ReviewLearningsDiffCard"),
    proposal: LearningProposalSchema,
    beforeSnippet: z.string().nullable(),
    afterSnippet: z.string(),
});

/** Widget 9: Standardized Monday/Thursday Release Train Decision Header */
export const ReleaseTrainDecisionPacketWidgetSchema = z.object({
    widgetType: z.literal("ReleaseTrainDecisionPacket"),
    packetId: z.string().uuid(),
    trainSlot: ReleaseTrainSlotSchema,
    engine: BusinessEngineSchema,
    headline: z.string(),
    runCostUsd: z.number().nonnegative(),
    projectedTrueMarginPct: z.number(),
    gate1Deterministic: z.object({
        passed: z.boolean(),
        checksRun: z.number().int().nonnegative(),
        referenceCheckPassed: z.boolean(),
        failures: z.array(z.string()),
    }),
    gate2Adversarial: z.object({
        criticModel: z.string(),
        score: z.number().min(0).max(100),
        sharpestTradeoffNote: z.string(),
        holdoutPassCount: z.number().int().nonnegative(),
        holdoutTotalCount: z.number().int().nonnegative(),
    }),
    executionActionLabel: z.string(),
});

export const GenerativeWidgetSchema = z.discriminatedUnion("widgetType", [
    ExecutiveCooBriefingWidgetSchema,
    IntelligencePublicationWorkbenchWidgetSchema,
    ExecutiveDealRoomMemoWidgetSchema,
    ScopeAndMarginSentinelCardWidgetSchema,
    ReaSystemXrayGraphWidgetSchema,
    VentureInvestmentDealMemoWidgetSchema,
    CraftBuildStageWorkbenchWidgetSchema,
    ReviewLearningsDiffCardWidgetSchema,
    ReleaseTrainDecisionPacketWidgetSchema,
]);
export type GenerativeWidget = z.infer<typeof GenerativeWidgetSchema>;

/* ============================================================================
 * 6. 6-OBJECT PRODUCT REGISTRY & 10-STEP IDEMPOTENT LAUNCH PIPELINE
 * ========================================================================== */

export const CommercialWrapperTypeSchema = z.enum([
    "self_serve_saas",
    "metered_http402_mcp",
    "managed_operations_sla",
]);
export type CommercialWrapperType = z.infer<typeof CommercialWrapperTypeSchema>;

export const LaunchStepIdSchema = z.enum([
    "01_register_product",
    "02_register_release_version",
    "03_provision_production_env",
    "04_enable_commercial_billing",
    "05_enable_monitoring_and_caps",
    "06_create_support_operations",
    "07_assign_ai_product_owner",
    "08_prepare_gtm_and_diagnostics",
    "09_verify_live_smoke_tests",
    "10_activate_portfolio_steward",
]);
export type LaunchStepId = z.infer<typeof LaunchStepIdSchema>;

export const LaunchStepStateSchema = z.object({
    status: z.enum(["pending", "completed", "failed_paused"]),
    idempotencyRef: z.string().nullable(),
    verifiedAt: z.string().datetime().nullable(),
    errorDetail: z.string().nullable(),
});

export const ProductLaunchManifestSchema = z.object({
    productSlug: z.string().regex(/^[a-z0-9-]+$/),
    productName: z.string(),
    versionSemver: z.string().regex(/^\d+\.\d+\.\d+$/),
    sourceCommitSha: z.string().min(7).max(40),
    artifactDigestSha256: z.string().length(64),
    approvalDecisionPacketId: z.string().uuid(),
    aiProductOwnerAgentId: z.string().default("ops.standing-product-owner"),
    operations: z.object({
        productionUrl: z.string().url(),
        healthCheckPath: z.string().startsWith("/").default("/api/health"),
        sentryProjectSlug: z.string(),
        dailyComputeCircuitBreakerUsd: z.number().positive(),
        rollbackVersionSemver: z.string().nullable(),
    }),
    commercialOfferings: z
        .array(
            z.object({
                wrapperType: CommercialWrapperTypeSchema,
                stripeProductId: z.string(),
                stripeMeterId: z.string().nullable(),
                baseMonthlyUsd: z.number().nonnegative(),
                freeDiagnosticEnabled: z.boolean().default(true),
            })
        )
        .min(1),
    stepStates: z.object({
        "01_register_product": LaunchStepStateSchema,
        "02_register_release_version": LaunchStepStateSchema,
        "03_provision_production_env": LaunchStepStateSchema,
        "04_enable_commercial_billing": LaunchStepStateSchema,
        "05_enable_monitoring_and_caps": LaunchStepStateSchema,
        "06_create_support_operations": LaunchStepStateSchema,
        "07_assign_ai_product_owner": LaunchStepStateSchema,
        "08_prepare_gtm_and_diagnostics": LaunchStepStateSchema,
        "09_verify_live_smoke_tests": LaunchStepStateSchema,
        "10_activate_portfolio_steward": LaunchStepStateSchema,
    }),
});
export type ProductLaunchManifest = z.infer<typeof ProductLaunchManifestSchema>;

/* ============================================================================
 * 7. TRUE-COST OPERATING ECONOMICS & CROSS-ENGINE DURABLE OUTBOX EVENTS
 * ========================================================================== */

export const TrueCostCategorySchema = z.enum([
    "recurring_revenue",
    "one_time_fee_revenue",
    "llm_and_tool_burn",
    "sandbox_and_hosting_infra",
    "external_contractor",
    "support_and_rework",
    "founder_shadow_time",
]);
export type TrueCostCategory = z.infer<typeof TrueCostCategorySchema>;

export const WorkspaceMarginSummarySchema = z.object({
    workspaceId: z.string().uuid(),
    tenantId: z.string().uuid(),
    grossRevenueUsd: z.number(),
    aiAndInfraCostUsd: z.number(),
    supportAndContractorCostUsd: z.number(),
    founderActiveMinutes: z.number().nonnegative(),
    founderShadowCostUsd: z.number().nonnegative(),
    trueContributionUsd: z.number(),
    trueContributionMarginPct: z.number(),
});
export type WorkspaceMarginSummary = z.infer<typeof WorkspaceMarginSummarySchema>;

export const OutboxEventTypeSchema = z.enum([
    "research.opportunity_qualified",
    "content.lead_attributed",
    "sales.engagement_won",
    "delivery.requirement_repeated",
    "venture.investment_approved",
    "product.release_approved",
    "product.launch_verified",
    "product.consolidation_proposed",
    "communications.client_inbound_ingested",
    "operations.incident_detected",
    "agent_os.connector_requested",
    "sandbox.teach_trace_saved",
    "factory.staging_deployed",
    "launch.step_09_smoke_requested",
    "outbox.event_published",
]);
export type OutboxEventType = z.infer<typeof OutboxEventTypeSchema>;

export const OutboxEventSchema = z.object({
    id: z.string().uuid(),
    schemaVersion: z.literal("1.0").default("1.0"),
    eventType: OutboxEventTypeSchema,
    originEngine: BusinessEngineSchema,
    workspaceId: z.string().uuid(),
    tenantId: z.string().uuid(),
    correlationId: z.string().uuid(),
    idempotencyKey: z.string().min(8).max(200),
    payload: z.record(z.string(), z.unknown()),
    createdAt: z.string().datetime(),
});
export type OutboxEvent = z.infer<typeof OutboxEventSchema>;