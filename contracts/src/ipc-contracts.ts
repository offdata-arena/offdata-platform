import { z } from "zod";
import {
    BusinessEngineSchema,
    EmbeddingVector1536Schema,
    FirmMemoryCategorySchema,
    IterationSpeedSchema,
    LiveComputerSessionSchema,
    SpatialPinVoiceCritiqueSchema,
    StudioPostureSchema,
} from "./core-schemas";

/* ============================================================================
 * 1. RLS JWT CLAIMS CONTRACT (SHARED BY AUTH-RLS & POSTGRES app_auth.*)
 * ========================================================================== */

export const FounderJwtClaimsSchema = z.object({
    app_role: z.literal("founder_admin"),
    sub: z.string().uuid(),
});

export const AgentWorkerJwtClaimsSchema = z.object({
    app_role: z.literal("agent_worker"),
    tenant_id: z.string().uuid(),
    workspace_id: z.string().uuid(),
    agent_id: z.string().regex(/^[a-z0-9-]+\.[a-z0-9-]+$/),
    run_id: z.string().uuid().optional(),
});

export const ClientPortalJwtClaimsSchema = z.object({
    app_role: z.literal("client_portal_user"),
    tenant_id: z.string().uuid(),
    contact_email: z.string().email(),
});

export const ScopedJwtClaimsSchema = z.discriminatedUnion("app_role", [
    FounderJwtClaimsSchema,
    AgentWorkerJwtClaimsSchema,
    ClientPortalJwtClaimsSchema,
]);
export type ScopedJwtClaims = z.infer<typeof ScopedJwtClaimsSchema>;

/* ============================================================================
 * 2. STANDARD STUDIO API ENVELOPE
 * ========================================================================== */

export const StudioApiErrorSchema = z.object({
    code: z.enum([
        "VALIDATION_ERROR",
        "RLS_FORBIDDEN",
        "ANTI_JOB_BLOCKED",
        "BUDGET_EXCEEDED",
        "UNAUTHORIZED_INSPECTION",
        "REFERENCE_CHECK_FAILED",
        "NOT_FOUND",
        "INTERNAL_ERROR",
    ]),
    message: z.string(),
    details: z.record(z.string(), z.unknown()).optional(),
});
export type StudioApiError = z.infer<typeof StudioApiErrorSchema>;

export function createStudioApiResponseSchema<T extends z.ZodTypeAny>(
    dataSchema: T
) {
    return z.discriminatedUnion("ok", [
        z.object({ ok: z.literal(true), data: dataSchema }),
        z.object({ ok: z.literal(false), error: StudioApiErrorSchema }),
    ]);
}

/* ============================================================================
 * 3. STUDIO <-> AGENT-OS ROUTE CONTRACTS (/api/studio/*)
 * ========================================================================== */

/** Route 1: POST /api/studio/missions/dispatch (Cmd+K Global AI COO Bar) */
export const DispatchMissionRequestSchema = z.object({
    workspaceId: z.string().uuid(),
    tenantId: z.string().uuid(),
    activeEngine: BusinessEngineSchema,
    directivePrompt: z.string().min(3).max(4000),
    targetAgentId: z.string().default("coo.global-dispatcher"),
    attachedArtifactId: z.string().uuid().nullable().default(null),
    requireLiveComputer: z.boolean().default(false),
});
export type DispatchMissionRequest = z.infer<typeof DispatchMissionRequestSchema>;

export const DispatchMissionResponseSchema = z.object({
    agentRunId: z.string().uuid(),
    dispatchedAgentId: z.string(),
    triggerRunHandleId: z.string(),
    liveComputerSession: LiveComputerSessionSchema.nullable(),
});
export type DispatchMissionResponse = z.infer<typeof DispatchMissionResponseSchema>;

/** Route 2: POST /api/studio/decisions/resolve (3-Pane Release Train Console) */
export const ResolveDecisionPacketRequestSchema = z.object({
    packetId: z.string().uuid(),
    decision: z.enum([
        "approve",
        "approve_with_override",
        "iterate",
        "reject_and_kill",
    ]),
    iterationSpeed: IterationSpeedSchema.nullable().default(null),
    founderOverrideSpec: z.record(z.string(), z.unknown()).nullable().default(null),
    spatialVoiceCritiques: z.array(SpatialPinVoiceCritiqueSchema).default([]),
    promoteToVault: z.boolean().default(false),
    proposedFirmMemoryCategory: FirmMemoryCategorySchema.nullable().default(null),
});
export type ResolveDecisionPacketRequest = z.infer<
    typeof ResolveDecisionPacketRequestSchema
>;

export const ResolveDecisionPacketResponseSchema = z.object({
    packetId: z.string().uuid(),
    newStatus: z.enum([
        "approved",
        "approved_with_override",
        "hot_seat_running",
        "respin_queued",
        "rejected",
    ]),
    executedSideEffectRef: z.string().nullable(),
    hotSeatFollowUpRunId: z.string().uuid().nullable(),
    createdLearningProposalId: z.string().uuid().nullable(),
});
export type ResolveDecisionPacketResponse = z.infer<
    typeof ResolveDecisionPacketResponseSchema
>;

/** Route 3: POST /api/studio/learnings/resolve ("Review Learnings" Cards) */
export const ResolveLearningProposalRequestSchema = z.object({
    proposalId: z.string().uuid(),
    action: z.enum(["approve", "discard"]),
    editedAssertionOrDiff: z.string().nullable().default(null),
});
export type ResolveLearningProposalRequest = z.infer<
    typeof ResolveLearningProposalRequestSchema
>;

export const ResolveLearningProposalResponseSchema = z.object({
    proposalId: z.string().uuid(),
    status: z.enum(["approved", "discarded"]),
    committedRecordIdOrPrUrl: z.string().nullable(),
});
export type ResolveLearningProposalResponse = z.infer<
    typeof ResolveLearningProposalResponseSchema
>;

/** Route 4: POST /api/studio/sandbox/control (Zone 3 Live Computer Takeover & Teach) */
export const SandboxControlRequestSchema = z.object({
    sessionId: z.string().uuid(),
    command: z.enum([
        "take_over",
        "resume_agent",
        "start_teach",
        "stop_teach",
        "terminate",
    ]),
    operatorNote: z.string().max(500).nullable().default(null),
});
export type SandboxControlRequest = z.infer<typeof SandboxControlRequestSchema>;

export const SandboxControlResponseSchema = z.object({
    session: LiveComputerSessionSchema,
    emittedTeachEventId: z.string().uuid().nullable().default(null),
});
export type SandboxControlResponse = z.infer<typeof SandboxControlResponseSchema>;

/** Route 5: POST /api/studio/routines/control (Pause / Resume / Safe Test Run) */
export const RoutineControlRequestSchema = z.object({
    routineId: z.string().uuid(),
    action: z.enum(["pause", "resume", "test_run"]),
});
export type RoutineControlRequest = z.infer<typeof RoutineControlRequestSchema>;

export const RoutineControlResponseSchema = z.object({
    routineId: z.string().uuid(),
    isPaused: z.boolean(),
    triggeredTestRunId: z.string().uuid().nullable(),
});
export type RoutineControlResponse = z.infer<typeof RoutineControlResponseSchema>;

/** Route 6: POST /api/studio/voice-transcribe (Multipart audio/webm + JSON metadata) */
export const VoicePinUploadMetadataSchema = z.object({
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
    quickRejectionTags: z.array(z.string()).default([]),
    requestedSpeed: IterationSpeedSchema.default("speed_2_hot_seat_3m"),
    promoteToVaultRule: z.boolean().default(false),
});
export type VoicePinUploadMetadata = z.infer<typeof VoicePinUploadMetadataSchema>;

export const VoicePinTranscribeResponseSchema = z.object({
    critique: SpatialPinVoiceCritiqueSchema,
    durationMs: z.number().int().nonnegative(),
});
export type VoicePinTranscribeResponse = z.infer<
    typeof VoicePinTranscribeResponseSchema
>;

/** Route 7: POST /api/studio/telemetry/focus (Automatic Founder Shadow-Time Ledger) */
export const RecordFocusSessionRequestSchema = z.object({
    workspaceId: z.string().uuid(),
    tenantId: z.string().uuid(),
    posture: StudioPostureSchema,
    activeSeconds: z.number().int().min(1).max(14400),
});
export type RecordFocusSessionRequest = z.infer<
    typeof RecordFocusSessionRequestSchema
>;

export const RecordFocusSessionResponseSchema = z.object({
    focusSessionId: z.string().uuid(),
    computedShadowCostUsd: z.number().nonnegative(),
    updatedTrueMarginPct: z.number(),
});
export type RecordFocusSessionResponse = z.infer<
    typeof RecordFocusSessionResponseSchema
>;

/* ============================================================================
 * 4. GATEWAY EMBEDDING CONTRACT (ENFORCES 1536 DIMENSIONS)
 * ========================================================================== */

export const CreateEmbeddingRequestSchema = z.object({
    tenantId: z.string().uuid(),
    workspaceId: z.string().uuid().nullable().default(null),
    agentId: z.string().nullable().default(null),
    inputText: z.string().min(1).max(32000),
    outputDimensionality: z.literal(1536).default(1536),
});
export type CreateEmbeddingRequest = z.infer<typeof CreateEmbeddingRequestSchema>;

export const CreateEmbeddingResponseSchema = z.object({
    model: z.string(),
    embedding: EmbeddingVector1536Schema,
    costUsd: z.number().nonnegative(),
});
export type CreateEmbeddingResponse = z.infer<typeof CreateEmbeddingResponseSchema>;