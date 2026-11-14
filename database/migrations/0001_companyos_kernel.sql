-- ============================================================================
-- OFFDATA & CompanyOS — Migration 0001 (v2.0 Reconciled):
-- 31-Table Institutional Kernel, Agent OS, 3D Vault, Editorial Engine,
-- 6-Object Product Registry, Atomic Shadow-Time Ledger & Complete 3-Role RLS
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- 0. EXTENSIONS & SCOPED JWT CLAIM HELPERS (app_auth)
-- ----------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "vector";

CREATE SCHEMA IF NOT EXISTS app_auth;

CREATE OR REPLACE FUNCTION app_auth.jwt_claims()
RETURNS JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT COALESCE(NULLIF(current_setting('request.jwt.claims', true), ''), '{}')::jsonb;
$$;

CREATE OR REPLACE FUNCTION app_auth.current_actor_role()
RETURNS TEXT
LANGUAGE sql
STABLE
AS $$
  SELECT COALESCE(
    app_auth.jwt_claims() ->> 'app_role',
    app_auth.jwt_claims() ->> 'role',
    'anonymous'
  );
$$;

CREATE OR REPLACE FUNCTION app_auth.is_founder()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
AS $$
  SELECT app_auth.current_actor_role() = 'founder_admin';
$$;

CREATE OR REPLACE FUNCTION app_auth.current_tenant_id()
RETURNS UUID
LANGUAGE sql
STABLE
AS $$
  SELECT NULLIF(app_auth.jwt_claims() ->> 'tenant_id', '')::uuid;
$$;

CREATE OR REPLACE FUNCTION app_auth.current_workspace_id()
RETURNS UUID
LANGUAGE sql
STABLE
AS $$
  SELECT NULLIF(app_auth.jwt_claims() ->> 'workspace_id', '')::uuid;
$$;

CREATE OR REPLACE FUNCTION app_auth.current_agent_id()
RETURNS TEXT
LANGUAGE sql
STABLE
AS $$
  SELECT NULLIF(app_auth.jwt_claims() ->> 'agent_id', '');
$$;

CREATE OR REPLACE FUNCTION public.trigger_set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

-- ----------------------------------------------------------------------------
-- 1. CORE ENUMERATED TYPES (1:1 WITH @offdata/contracts v2.0)
-- ----------------------------------------------------------------------------
CREATE TYPE business_engine AS ENUM ('executive', 'intelligence', 'advisory', 'solutions');
CREATE TYPE studio_posture AS ENUM ('workbench', 'review', 'operate');
CREATE TYPE environment_tier AS ENUM ('production', 'frontier');
CREATE TYPE capability_maturity AS ENUM ('designed', 'implemented', 'integrated', 'operationally_verified');
CREATE TYPE specialist_pod AS ENUM (
  '01_executive_governance',
  '02_intelligence_editorial',
  '03_gtm_revenue',
  '04_advisory_discovery',
  '05_implementation_factory',
  '06_independent_assurance',
  '07_managed_ops_venture'
);
CREATE TYPE autonomy_stage AS ENUM (
  'stage_1_founder_gate',
  'stage_2_optimistic_veto_2h',
  'stage_3_earned_autopilot'
);
CREATE TYPE release_train_slot AS ENUM ('monday_am', 'thursday_pm', 'immediate_p0', 'internal_auto');
CREATE TYPE iteration_speed AS ENUM (
  'speed_1_instant_override',
  'speed_2_hot_seat_3m',
  'speed_3_next_train_respin'
);
CREATE TYPE ingestion_pattern AS ENUM (
  'outside_in_recon',
  'cc_the_vault',
  'scoped_oauth_snapshot',
  'local_zero_exfil_collector',
  'silent_work_along_capture'
);
CREATE TYPE investment_track AS ENUM ('core_70', 'adjacent_20', 'frontier_10');
CREATE TYPE client_archetype AS ENUM (
  'A_b2b_services',
  'B_regulated_finance',
  'C_supply_chain_industrial',
  'D_pe_ma_rollups',
  'E_saas_tech_vendors'
);
CREATE TYPE functional_practice AS ENUM (
  'commercial_pricing',
  'process_operating_model',
  'governance_risk_compliance',
  'clean_core_engineering'
);
CREATE TYPE commercial_wrapper_type AS ENUM (
  'self_serve_saas',
  'metered_http402_mcp',
  'managed_operations_sla'
);
CREATE TYPE true_cost_category AS ENUM (
  'recurring_revenue',
  'one_time_fee_revenue',
  'llm_and_tool_burn',
  'sandbox_and_hosting_infra',
  'external_contractor',
  'support_and_rework',
  'founder_shadow_time'
);
CREATE TYPE artifact_kind AS ENUM (
  'coo_briefing',
  'editorial_publication',
  'deal_room_memo',
  'proposal_sow',
  'prd_spec',
  'venture_deal_memo',
  'craft_application',
  'rea_xray_report',
  'change_order',
  'qa_verification_bundle',
  'mission_dispatch_plan',
  'portfolio_health_report'
);
CREATE TYPE firm_memory_category AS ENUM (
  'commercial_policy',
  'scoping_heuristic',
  'pricing_benchmark',
  'incumbent_weakness',
  'content_hook_pattern',
  'founder_taste_rule',
  'technical_api_gotcha',
  'qa_regression_pattern',
  'merger_synergy_rule'
);

-- ----------------------------------------------------------------------------
-- 2. TENANTS, WORKSPACES, SHA-256 EVIDENCE LEDGER & ARTIFACT KERNEL
-- ----------------------------------------------------------------------------
CREATE TABLE tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  is_internal BOOLEAN NOT NULL DEFAULT FALSE,
  archetype client_archetype,
  nda_strict BOOLEAN NOT NULL DEFAULT TRUE,
  zdr_enforced BOOLEAN NOT NULL DEFAULT TRUE,
  pii_retention_days INTEGER NOT NULL DEFAULT 30,
  monthly_compute_cap_usd NUMERIC(10,2) NOT NULL DEFAULT 250.00,
  founder_shadow_rate_usd NUMERIC(10,2) NOT NULL DEFAULT 250.00,
  metadata JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE workspaces (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE RESTRICT,
  slug TEXT NOT NULL,
  title TEXT NOT NULL,
  engine business_engine NOT NULL,
  environment environment_tier NOT NULL DEFAULT 'production',
  default_posture studio_posture NOT NULL DEFAULT 'workbench',
  maturity capability_maturity NOT NULL DEFAULT 'designed',
  is_archived BOOLEAN NOT NULL DEFAULT FALSE,
  context_summary TEXT,
  metadata JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (tenant_id, slug)
);

CREATE TABLE evidence_ledger (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  sha256_hash CHAR(64) NOT NULL,
  source_kind TEXT NOT NULL CHECK (source_kind IN (
    'client_document', 'oauth_snapshot', 'web_capture', 'rea_runtime_trace',
    'craft_cany_bundle', 'deterministic_model_output', 'call_transcript', 'playwright_video'
  )),
  source_label TEXT NOT NULL,
  storage_uri TEXT NOT NULL,
  byte_size BIGINT NOT NULL DEFAULT 0,
  extracted_metadata JSONB NOT NULL DEFAULT '{}',
  purge_after TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (workspace_id, sha256_hash)
);

CREATE TABLE artifacts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  engine business_engine NOT NULL,
  kind artifact_kind NOT NULL,
  title TEXT NOT NULL,
  client_portal_visible BOOLEAN NOT NULL DEFAULT FALSE,
  editorial_signed_off BOOLEAN NOT NULL DEFAULT FALSE,
  latest_version_number INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE artifact_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  artifact_id UUID NOT NULL REFERENCES artifacts(id) ON DELETE CASCADE,
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  version_number INTEGER NOT NULL,
  content_markdown TEXT,
  widget_payload JSONB,
  citation_evidence_ids UUID[] NOT NULL DEFAULT '{}',
  sha256_digest CHAR(64) NOT NULL,
  created_by_actor TEXT NOT NULL,
  change_summary TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (artifact_id, version_number)
);

CREATE TABLE engagement_authorizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  signed_evidence_id UUID NOT NULL REFERENCES evidence_ledger(id) ON DELETE RESTRICT,
  scope_type TEXT NOT NULL CHECK (scope_type IN ('rea_deep_inspection', 'craft_deep_mode', 'voice_likeness_clone')),
  authorized_targets TEXT[] NOT NULL,
  granted_by_name TEXT NOT NULL,
  granted_by_email TEXT NOT NULL,
  valid_from TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  revoked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- 3. SUBSYSTEM 1: AGENT OS (PROFILES, 3-TIER 1536-DIM MEMORY, ROUTINES, VMs)
-- ----------------------------------------------------------------------------
CREATE TABLE agent_profiles (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  pod specialist_pod NOT NULL,
  practice TEXT NOT NULL,
  avatar_presence TEXT NOT NULL,
  mandate TEXT NOT NULL,
  anti_jobs TEXT[] NOT NULL,
  memory_scopes JSONB NOT NULL,
  skill_uris TEXT[] NOT NULL DEFAULT '{}',
  mcp_tools TEXT[] NOT NULL DEFAULT '{}',
  vault_secret_refs TEXT[] NOT NULL DEFAULT '{}',
  runtime_isolation TEXT NOT NULL DEFAULT 'ephemeral_tenant_sandbox' CHECK (
    runtime_isolation IN ('stateless_worker', 'ephemeral_tenant_sandbox')
  ),
  worker_model TEXT NOT NULL DEFAULT 'gemini-2.5-pro',
  critic_model TEXT NOT NULL DEFAULT 'claude-sonnet-4-5',
  max_budget_usd_per_run NUMERIC(8,2) NOT NULL DEFAULT 5.00,
  manifest_sha256 CHAR(64) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE firm_memories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scope_key TEXT NOT NULL,
  category firm_memory_category NOT NULL,
  assertion TEXT NOT NULL,
  supporting_metadata JSONB NOT NULL DEFAULT '{}',
  embedding VECTOR(1536),
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE agent_memories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id TEXT NOT NULL REFERENCES agent_profiles(id) ON DELETE CASCADE,
  memory_kind TEXT NOT NULL CHECK (memory_kind IN ('work_log', 'behavioral_rule')),
  content TEXT NOT NULL,
  run_ref_id UUID,
  embedding VECTOR(1536),
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE tenant_memories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE,
  scope_key TEXT NOT NULL,
  content TEXT NOT NULL,
  source_evidence_id UUID REFERENCES evidence_ledger(id) ON DELETE SET NULL,
  embedding VECTOR(1536),
  purge_after TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE autonomy_policies (
  workflow_or_routine_key TEXT PRIMARY KEY,
  engine business_engine NOT NULL,
  stage autonomy_stage NOT NULL DEFAULT 'stage_1_founder_gate',
  consecutive_clean_runs INTEGER NOT NULL DEFAULT 0,
  runs_required_for_stage_2 INTEGER NOT NULL DEFAULT 20,
  runs_required_for_stage_3 INTEGER NOT NULL DEFAULT 50,
  max_run_cost_usd NUMERIC(8,2) NOT NULL DEFAULT 5.00,
  max_financial_side_effect_usd NUMERIC(10,2) NOT NULL DEFAULT 0.00,
  protected_repo_globs TEXT[] NOT NULL DEFAULT ARRAY['packages/chassis/src/auth-rls/**', 'database/**'],
  auto_demote_on_incident BOOLEAN NOT NULL DEFAULT TRUE,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE agent_routines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id TEXT NOT NULL REFERENCES agent_profiles(id) ON DELETE CASCADE,
  workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE,
  routine_slug TEXT NOT NULL,
  trigger_spec TEXT NOT NULL,
  timezone TEXT NOT NULL DEFAULT 'Asia/Singapore',
  expected_artifact_type TEXT NOT NULL,
  approval_boundary TEXT NOT NULL,
  max_duration_seconds INTEGER NOT NULL DEFAULT 600,
  is_paused BOOLEAN NOT NULL DEFAULT FALSE,
  last_triggered_at TIMESTAMPTZ,
  last_test_run_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE NULLS NOT DISTINCT (agent_id, workspace_id, routine_slug)
);

CREATE TABLE agent_runs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  agent_id TEXT NOT NULL REFERENCES agent_profiles(id) ON DELETE RESTRICT,
  routine_id UUID REFERENCES agent_routines(id) ON DELETE SET NULL,
  trigger_reason TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN (
    'queued', 'running', 'gate1_failed', 'gate2_failed', 'awaiting_takeover',
    'staged_for_train', 'completed', 'halted_anti_job', 'halted_budget'
  )),
  activity_status_line TEXT,
  models_telemetry JSONB NOT NULL DEFAULT '[]',
  cost_usd NUMERIC(10,5) NOT NULL DEFAULT 0,
  sandbox_seconds INTEGER NOT NULL DEFAULT 0,
  durable_wait_token TEXT,
  error_detail TEXT,
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

CREATE TABLE learning_proposals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id TEXT NOT NULL REFERENCES agent_profiles(id) ON DELETE CASCADE,
  source_run_id UUID NOT NULL REFERENCES agent_runs(id) ON DELETE CASCADE,
  target_scope TEXT NOT NULL CHECK (target_scope IN ('firm_memory', 'agent_rule', 'vault_skill_patch')),
  firm_memory_category firm_memory_category,
  target_identifier TEXT NOT NULL,
  before_snippet TEXT,
  proposed_assertion_or_diff TEXT NOT NULL,
  evidence_summary TEXT NOT NULL,
  confidence NUMERIC(3,2) NOT NULL DEFAULT 0.85,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'discarded')),
  resolved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE sandbox_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  agent_run_id UUID NOT NULL REFERENCES agent_runs(id) ON DELETE CASCADE,
  driver TEXT NOT NULL CHECK (driver IN ('docker_local', 'e2b_cloud', 'headless_ci')),
  external_sandbox_id TEXT NOT NULL,
  stream_protocol TEXT NOT NULL CHECK (stream_protocol IN ('webrtc', 'novnc_ws', 'headless_none')),
  stream_endpoint_url TEXT,
  assigned_host_port INTEGER,
  status TEXT NOT NULL CHECK (status IN (
    'booting', 'agent_operating', 'awaiting_takeover',
    'human_takeover_active', 'teach_recording', 'terminated'
  )),
  current_activity_line TEXT NOT NULL DEFAULT 'Provisioning isolated environment...',
  takeover_reason TEXT,
  recorded_teach_trace_uri TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  terminated_at TIMESTAMPTZ
);

-- ----------------------------------------------------------------------------
-- 4. SUBSYSTEM 2: 3D INSTITUTIONAL VAULT MATRIX
-- ----------------------------------------------------------------------------
CREATE TABLE vault_cells (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cell_slug TEXT UNIQUE NOT NULL,
  version_semver TEXT NOT NULL DEFAULT '1.0.0',
  title TEXT NOT NULL,
  archetype client_archetype NOT NULL,
  practice functional_practice NOT NULL,
  industry_tags TEXT[] NOT NULL DEFAULT '{}',
  maturity capability_maturity NOT NULL DEFAULT 'designed',
  supported_ingestion ingestion_pattern[] NOT NULL,
  intake_protocol_path TEXT NOT NULL,
  deterministic_models_dir TEXT NOT NULL,
  skill_playbook_path TEXT NOT NULL,
  deal_room_template_path TEXT NOT NULL,
  evals_suite_path TEXT NOT NULL,
  times_deployed INTEGER NOT NULL DEFAULT 0,
  failure_regression_count INTEGER NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- 5. RELEASE TRAINS, 3-PANE REVIEW & 3-SPEED ITERATION ENGINE
-- ----------------------------------------------------------------------------
CREATE TABLE decision_packets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  agent_run_id UUID NOT NULL REFERENCES agent_runs(id) ON DELETE CASCADE,
  artifact_id UUID REFERENCES artifacts(id) ON DELETE SET NULL,
  artifact_version_id UUID REFERENCES artifact_versions(id) ON DELETE SET NULL,
  engine business_engine NOT NULL,
  train_slot release_train_slot NOT NULL DEFAULT 'monday_am',
  headline TEXT NOT NULL,
  gate1_deterministic_report JSONB NOT NULL,
  gate2_adversarial_report JSONB NOT NULL,
  critiquito_visual_report JSONB,
  execution_spec JSONB NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN (
    'pending', 'approved', 'approved_with_override',
    'hot_seat_running', 'respin_queued', 'rejected'
  )),
  iteration_speed_selected iteration_speed,
  spatial_voice_critiques JSONB NOT NULL DEFAULT '[]',
  founder_override_spec JSONB,
  promote_to_vault BOOLEAN NOT NULL DEFAULT FALSE,
  resolved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- 6. SYMMETRIC BUSINESS ENGINES: INTELLIGENCE, GTM/ADVISORY & VENTURE OFFICE
-- ----------------------------------------------------------------------------

-- Engine 1: OFFDATA Intelligence Publications & Channel Attribution
CREATE TABLE editorial_publications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL DEFAULT '00000000-0000-4000-8000-000000000001' REFERENCES tenants(id) ON DELETE RESTRICT,
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  artifact_id UUID NOT NULL REFERENCES artifacts(id) ON DELETE CASCADE,
  slug TEXT UNIQUE NOT NULL,
  property_type TEXT NOT NULL CHECK (property_type IN (
    'intelligence_brief', 'field_note', 'operating_benchmark'
  )),
  title TEXT NOT NULL,
  human_editorial_byline TEXT NOT NULL,
  contains_synthetic_media BOOLEAN NOT NULL DEFAULT FALSE,
  c2pa_manifest_attached BOOLEAN NOT NULL DEFAULT FALSE,
  channel_variants JSONB NOT NULL DEFAULT '[]',
  published_urls JSONB NOT NULL DEFAULT '{}',
  attributed_leads_count INTEGER NOT NULL DEFAULT 0,
  publication_status TEXT NOT NULL DEFAULT 'drafting' CHECK (publication_status IN (
    'drafting', 'qa_verified', 'staged_for_train', 'published', 'archived'
  )),
  embedding VECTOR(1536),
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Engine 2: OFFDATA Advisory & GTM Pipeline
CREATE TABLE crm_opportunities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  company_name TEXT NOT NULL,
  contact_name TEXT NOT NULL,
  contact_email TEXT NOT NULL,
  archetype client_archetype,
  stage TEXT NOT NULL CHECK (stage IN (
    'signal_identified', 'diagnostic_sent', 'discovery', 'proposal_review', 'won', 'lost'
  )),
  attributed_publication_id UUID REFERENCES editorial_publications(id) ON DELETE SET NULL,
  attributed_artifact_id UUID REFERENCES artifacts(id) ON DELETE SET NULL,
  outside_in_diagnostic_id UUID REFERENCES artifacts(id) ON DELETE SET NULL,
  estimated_value_usd NUMERIC(12,2),
  external_crm_ref TEXT,
  next_loop_closer_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE advisory_engagements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE RESTRICT,
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE RESTRICT,
  opportunity_id UUID REFERENCES crm_opportunities(id) ON DELETE SET NULL,
  vault_cell_id UUID REFERENCES vault_cells(id) ON DELETE SET NULL,
  engagement_tier TEXT NOT NULL CHECK (engagement_tier IN (
    'opportunity_assessment', 'transformation_pilot', 'managed_operations_retainer'
  )),
  primary_ingestion ingestion_pattern NOT NULL,
  fixed_or_monthly_fee_usd NUMERIC(12,2) NOT NULL,
  stripe_deposit_paid BOOLEAN NOT NULL DEFAULT FALSE,
  locked_sow_sha256 CHAR(64),
  locked_prd_sha256 CHAR(64),
  client_accepted_at TIMESTAMPTZ,
  status TEXT NOT NULL DEFAULT 'scoping' CHECK (status IN (
    'scoping', 'awaiting_deposit', 'active_delivery', 'uat_review', 'managed_ops_live', 'closed'
  )),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Engine 3: OFFDATA Solutions Venture Office
CREATE TABLE venture_dossiers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL DEFAULT '00000000-0000-4000-8000-000000000001' REFERENCES tenants(id) ON DELETE RESTRICT,
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  slug TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  track investment_track NOT NULL DEFAULT 'core_70',
  stage TEXT NOT NULL DEFAULT 'scouted' CHECK (stage IN (
    'scouted', 'underwritten', 'killed', 'routed_advisory',
    'smoke_testing', 'building_v1', 'live_portfolio', 'merged_into_suite', 'lead_magnet'
  )),
  composite_score NUMERIC(5,2),
  signal_evidence JSONB NOT NULL DEFAULT '{}',
  underwriting_memo JSONB NOT NULL DEFAULT '{}',
  merged_into_dossier_id UUID REFERENCES venture_dossiers(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- 7. THE 6-OBJECT PRODUCT & SERVICE REGISTRY + 10-STEP LAUNCH PIPELINE
-- ----------------------------------------------------------------------------
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL DEFAULT '00000000-0000-4000-8000-000000000001' REFERENCES tenants(id) ON DELETE RESTRICT,
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE RESTRICT,
  origin_dossier_id UUID REFERENCES venture_dossiers(id) ON DELETE SET NULL,
  slug TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  repo_path_or_url TEXT NOT NULL,
  chassis_version TEXT NOT NULL DEFAULT '1.0.0',
  lifecycle_status TEXT NOT NULL DEFAULT 'development' CHECK (lifecycle_status IN (
    'development', 'launching', 'live_active', 'consolidating', 'retired_lead_magnet'
  )),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE product_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  approval_packet_id UUID REFERENCES decision_packets(id) ON DELETE RESTRICT,
  version_semver TEXT NOT NULL,
  source_commit_sha TEXT NOT NULL,
  artifact_digest_sha256 CHAR(64) NOT NULL,
  qa_evidence_bundle JSONB NOT NULL,
  release_notes_md TEXT NOT NULL,
  rollback_version_semver TEXT,
  released_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (product_id, version_semver)
);

CREATE TABLE service_offerings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  offering_slug TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  wrapper_type commercial_wrapper_type NOT NULL,
  stripe_product_id TEXT,
  stripe_meter_id TEXT,
  base_monthly_usd NUMERIC(10,2) NOT NULL DEFAULT 0.00,
  unit_outcome_price_usd NUMERIC(10,4),
  free_diagnostic_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  sla_commitments JSONB NOT NULL DEFAULT '{}',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE production_deployments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  active_version_id UUID NOT NULL REFERENCES product_versions(id) ON DELETE RESTRICT,
  environment_name TEXT NOT NULL DEFAULT 'production',
  primary_url TEXT NOT NULL,
  health_check_path TEXT NOT NULL DEFAULT '/api/health',
  sentry_project_slug TEXT NOT NULL,
  daily_compute_breaker_usd NUMERIC(10,2) NOT NULL DEFAULT 50.00,
  availability_30d_pct NUMERIC(5,2) NOT NULL DEFAULT 100.00,
  last_smoke_verified_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (product_id, environment_name)
);

CREATE TABLE customer_installations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE RESTRICT,
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE RESTRICT,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
  pinned_version_id UUID NOT NULL REFERENCES product_versions(id) ON DELETE RESTRICT,
  service_offering_id UUID NOT NULL REFERENCES service_offerings(id) ON DELETE RESTRICT,
  stripe_subscription_id TEXT,
  tenant_adapter_config JSONB NOT NULL DEFAULT '{}',
  status TEXT NOT NULL DEFAULT 'provisioning' CHECK (status IN (
    'provisioning', 'active', 'past_due', 'paused', 'churned'
  )),
  installed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (tenant_id, product_id)
);

CREATE TABLE product_owner_mandates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID UNIQUE NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  owner_agent_id TEXT NOT NULL REFERENCES agent_profiles(id) ON DELETE RESTRICT,
  target_gross_margin_pct NUMERIC(5,2) NOT NULL DEFAULT 80.00,
  health_check_cron TEXT NOT NULL DEFAULT '0 */6 * * *',
  steward_review_cron TEXT NOT NULL DEFAULT '0 8 1,15 * *',
  autonomous_patch_allowed BOOLEAN NOT NULL DEFAULT FALSE,
  mandate_status TEXT NOT NULL DEFAULT 'active' CHECK (mandate_status IN ('active', 'suspended')),
  last_steward_report JSONB NOT NULL DEFAULT '{}',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE product_launch_runs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL DEFAULT '00000000-0000-4000-8000-000000000001' REFERENCES tenants(id) ON DELETE RESTRICT,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  product_version_id UUID NOT NULL REFERENCES product_versions(id) ON DELETE CASCADE,
  approval_packet_id UUID NOT NULL REFERENCES decision_packets(id) ON DELETE RESTRICT,
  launch_manifest JSONB NOT NULL,
  completed_steps TEXT[] NOT NULL DEFAULT '{}',
  failed_step TEXT,
  is_fully_launched BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (product_version_id)
);

-- ----------------------------------------------------------------------------
-- 8. TRUE-COST OPERATING ECONOMICS, ATOMIC SHADOW-TIME SYNC & OUTBOX
-- ----------------------------------------------------------------------------
CREATE TABLE workspace_focus_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  posture studio_posture NOT NULL,
  active_seconds INTEGER NOT NULL CHECK (active_seconds > 0 AND active_seconds <= 14400),
  shadow_hourly_rate_usd NUMERIC(10,2) NOT NULL DEFAULT 250.00,
  computed_shadow_cost_usd NUMERIC(12,4) GENERATED ALWAYS AS (
    ROUND((active_seconds::numeric / 3600.0) * shadow_hourly_rate_usd, 4)
  ) STORED,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE true_cost_ledger (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE RESTRICT,
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE RESTRICT,
  category true_cost_category NOT NULL,
  amount_usd NUMERIC(12,4) NOT NULL,
  agent_run_id UUID REFERENCES agent_runs(id) ON DELETE SET NULL,
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  engagement_id UUID REFERENCES advisory_engagements(id) ON DELETE SET NULL,
  focus_session_id UUID REFERENCES workspace_focus_sessions(id) ON DELETE SET NULL,
  external_idempotency_ref TEXT UNIQUE,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Atomic trigger: every recorded Founder focus session writes its shadow cost to true_cost_ledger
CREATE OR REPLACE FUNCTION public.sync_focus_session_to_true_cost_ledger()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.true_cost_ledger (
    tenant_id,
    workspace_id,
    category,
    amount_usd,
    focus_session_id,
    external_idempotency_ref,
    occurred_at
  ) VALUES (
    NEW.tenant_id,
    NEW.workspace_id,
    'founder_shadow_time',
    -1 * NEW.computed_shadow_cost_usd,
    NEW.id,
    'focus_session:' || NEW.id::text,
    NEW.recorded_at
  )
  ON CONFLICT (external_idempotency_ref) DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_sync_focus_session_to_ledger
  AFTER INSERT ON workspace_focus_sessions
  FOR EACH ROW
  EXECUTE FUNCTION public.sync_focus_session_to_true_cost_ledger();

-- Security-invoker view ensures caller RLS policies are honored
CREATE OR REPLACE VIEW v_workspace_true_margins
WITH (security_invoker = true)
AS
SELECT
  w.id AS workspace_id,
  w.tenant_id,
  w.title AS workspace_title,
  w.engine,
  COALESCE(SUM(CASE WHEN l.amount_usd > 0 THEN l.amount_usd ELSE 0 END), 0) AS gross_revenue_usd,
  COALESCE(ABS(SUM(CASE WHEN l.category IN ('llm_and_tool_burn', 'sandbox_and_hosting_infra') THEN l.amount_usd ELSE 0 END)), 0) AS ai_and_infra_cost_usd,
  COALESCE(ABS(SUM(CASE WHEN l.category IN ('external_contractor', 'support_and_rework') THEN l.amount_usd ELSE 0 END)), 0) AS support_and_contractor_cost_usd,
  COALESCE((SELECT ROUND(SUM(fs.active_seconds)::numeric / 60.0, 2) FROM workspace_focus_sessions fs WHERE fs.workspace_id = w.id), 0) AS founder_active_minutes,
  COALESCE(ABS(SUM(CASE WHEN l.category = 'founder_shadow_time' THEN l.amount_usd ELSE 0 END)), 0) AS founder_shadow_cost_usd,
  COALESCE(SUM(l.amount_usd), 0) AS true_contribution_usd,
  CASE
    WHEN COALESCE(SUM(CASE WHEN l.amount_usd > 0 THEN l.amount_usd ELSE 0 END), 0) = 0 THEN 0
    ELSE ROUND(
      (COALESCE(SUM(l.amount_usd), 0) / SUM(CASE WHEN l.amount_usd > 0 THEN l.amount_usd ELSE 0 END)) * 100.0,
      2
    )
  END AS true_contribution_margin_pct
FROM workspaces w
LEFT JOIN true_cost_ledger l ON l.workspace_id = w.id
GROUP BY w.id, w.tenant_id, w.title, w.engine;

CREATE TABLE outbox_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  schema_version TEXT NOT NULL DEFAULT '1.0',
  event_type TEXT NOT NULL,
  origin_engine business_engine NOT NULL,
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  correlation_id UUID NOT NULL,
  idempotency_key TEXT UNIQUE NOT NULL,
  payload JSONB NOT NULL,
  dispatched_at TIMESTAMPTZ,
  delivery_attempts INTEGER NOT NULL DEFAULT 0,
  last_error TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- 9. INDEXES & UPDATED_AT TRIGGERS
-- ----------------------------------------------------------------------------
CREATE INDEX idx_firm_memories_vec ON firm_memories USING hnsw (embedding vector_cosine_ops);
CREATE INDEX idx_agent_memories_vec ON agent_memories USING hnsw (embedding vector_cosine_ops);
CREATE INDEX idx_tenant_memories_vec ON tenant_memories USING hnsw (embedding vector_cosine_ops);
CREATE INDEX idx_publications_vec ON editorial_publications USING hnsw (embedding vector_cosine_ops);

CREATE INDEX idx_decision_trains ON decision_packets (status, train_slot, created_at DESC) WHERE status = 'pending';
CREATE INDEX idx_learnings_pending ON learning_proposals (status, created_at DESC) WHERE status = 'pending';
CREATE INDEX idx_runs_workspace ON agent_runs (workspace_id, started_at DESC);
CREATE INDEX idx_sandbox_active ON sandbox_sessions (workspace_id, status) WHERE status <> 'terminated';
CREATE INDEX idx_outbox_undispatched ON outbox_events (created_at ASC) WHERE dispatched_at IS NULL;
CREATE INDEX idx_ledger_workspace_date ON true_cost_ledger (workspace_id, occurred_at DESC);

CREATE TRIGGER set_tenants_updated_at BEFORE UPDATE ON tenants FOR EACH ROW EXECUTE FUNCTION public.trigger_set_updated_at();
CREATE TRIGGER set_workspaces_updated_at BEFORE UPDATE ON workspaces FOR EACH ROW EXECUTE FUNCTION public.trigger_set_updated_at();
CREATE TRIGGER set_artifacts_updated_at BEFORE UPDATE ON artifacts FOR EACH ROW EXECUTE FUNCTION public.trigger_set_updated_at();
CREATE TRIGGER set_publications_updated_at BEFORE UPDATE ON editorial_publications FOR EACH ROW EXECUTE FUNCTION public.trigger_set_updated_at();
CREATE TRIGGER set_crm_updated_at BEFORE UPDATE ON crm_opportunities FOR EACH ROW EXECUTE FUNCTION public.trigger_set_updated_at();
CREATE TRIGGER set_engagements_updated_at BEFORE UPDATE ON advisory_engagements FOR EACH ROW EXECUTE FUNCTION public.trigger_set_updated_at();
CREATE TRIGGER set_dossiers_updated_at BEFORE UPDATE ON venture_dossiers FOR EACH ROW EXECUTE FUNCTION public.trigger_set_updated_at();
CREATE TRIGGER set_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION public.trigger_set_updated_at();
CREATE TRIGGER set_installations_updated_at BEFORE UPDATE ON customer_installations FOR EACH ROW EXECUTE FUNCTION public.trigger_set_updated_at();
CREATE TRIGGER set_launch_runs_updated_at BEFORE UPDATE ON product_launch_runs FOR EACH ROW EXECUTE FUNCTION public.trigger_set_updated_at();

-- ----------------------------------------------------------------------------
-- 10. COMPLETE 3-ROLE ROW-LEVEL SECURITY (ALL 31 PUBLIC TABLES)
-- ----------------------------------------------------------------------------
DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOREACH tbl IN ARRAY ARRAY[
    'tenants', 'workspaces', 'evidence_ledger', 'artifacts', 'artifact_versions',
    'engagement_authorizations', 'agent_profiles', 'firm_memories', 'agent_memories',
    'tenant_memories', 'autonomy_policies', 'agent_routines', 'agent_runs',
    'learning_proposals', 'sandbox_sessions', 'vault_cells', 'decision_packets',
    'editorial_publications', 'crm_opportunities', 'advisory_engagements',
    'venture_dossiers', 'products', 'product_versions', 'service_offerings',
    'production_deployments', 'customer_installations', 'product_owner_mandates',
    'product_launch_runs', 'workspace_focus_sessions', 'true_cost_ledger', 'outbox_events'
  ]
  LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY;', tbl);
    EXECUTE format('ALTER TABLE %I FORCE ROW LEVEL SECURITY;', tbl);
    EXECUTE format(
      'CREATE POLICY founder_full_access ON %I FOR ALL USING (app_auth.is_founder()) WITH CHECK (app_auth.is_founder());',
      tbl
    );
  END LOOP;
END $$;

-- ============================================================================
-- ROLE 2 POLICIES: agent_worker (Tenant, Workspace, Agent & Self-Approval Locks)
-- ============================================================================

-- Read-Only Reference & Governance Tables for Agents
CREATE POLICY agent_tenants_select ON tenants
  FOR SELECT USING (app_auth.current_actor_role() = 'agent_worker' AND id = app_auth.current_tenant_id());

CREATE POLICY agent_workspaces_select ON workspaces
  FOR SELECT USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND id = app_auth.current_workspace_id()
  );

CREATE POLICY agent_profiles_select ON agent_profiles
  FOR SELECT USING (app_auth.current_actor_role() = 'agent_worker' AND is_active = TRUE);

CREATE POLICY agent_firm_memories_select ON firm_memories
  FOR SELECT USING (app_auth.current_actor_role() = 'agent_worker');

CREATE POLICY agent_vault_cells_select ON vault_cells
  FOR SELECT USING (app_auth.current_actor_role() = 'agent_worker');

CREATE POLICY agent_autonomy_policies_select ON autonomy_policies
  FOR SELECT USING (app_auth.current_actor_role() = 'agent_worker');

CREATE POLICY agent_authorizations_select ON engagement_authorizations
  FOR SELECT USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
  );

CREATE POLICY agent_routines_select ON agent_routines
  FOR SELECT USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND (agent_id = app_auth.current_agent_id() OR workspace_id = app_auth.current_workspace_id())
  );

-- Tier-2 Self-Scoped Agent Memory (Auto-append work_log ONLY; behavioral_rule blocked)
CREATE POLICY agent_own_memories_select ON agent_memories
  FOR SELECT USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND agent_id = app_auth.current_agent_id()
  );

CREATE POLICY agent_own_worklog_insert ON agent_memories
  FOR INSERT WITH CHECK (
    app_auth.current_actor_role() = 'agent_worker'
    AND agent_id = app_auth.current_agent_id()
    AND memory_kind = 'work_log'
  );

-- Tier-3 Tenant Memory (Strictly isolated by tenant_id)
CREATE POLICY agent_tenant_memories_rw ON tenant_memories
  FOR ALL USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND (workspace_id IS NULL OR workspace_id = app_auth.current_workspace_id())
  )
  WITH CHECK (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND (workspace_id IS NULL OR workspace_id = app_auth.current_workspace_id())
  );

-- Append-Only SHA-256 Evidence Ledger (Agents can read & insert, never delete/tamper)
CREATE POLICY agent_evidence_select ON evidence_ledger
  FOR SELECT USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
  );

CREATE POLICY agent_evidence_insert ON evidence_ledger
  FOR INSERT WITH CHECK (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
  );

-- Artifacts & Versions (Agents cannot self-sign editorial_signed_off = TRUE)
CREATE POLICY agent_artifacts_select ON artifacts
  FOR SELECT USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
  );

CREATE POLICY agent_artifacts_write ON artifacts
  FOR INSERT WITH CHECK (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
    AND editorial_signed_off = FALSE
  );

CREATE POLICY agent_artifacts_update ON artifacts
  FOR UPDATE USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
  )
  WITH CHECK (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
    AND editorial_signed_off = FALSE
  );

CREATE POLICY agent_artifact_versions_select ON artifact_versions
  FOR SELECT USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
  );

CREATE POLICY agent_artifact_versions_insert ON artifact_versions
  FOR INSERT WITH CHECK (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
  );

-- Agent Runs, Sandbox Sessions, Learnings & Decision Packets (Self-Approval Blocked)
CREATE POLICY agent_runs_rw ON agent_runs
  FOR ALL USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
  )
  WITH CHECK (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
    AND agent_id = app_auth.current_agent_id()
  );

CREATE POLICY agent_sandbox_rw ON sandbox_sessions
  FOR ALL USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
  )
  WITH CHECK (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
  );

CREATE POLICY agent_learnings_select ON learning_proposals
  FOR SELECT USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND agent_id = app_auth.current_agent_id()
  );

CREATE POLICY agent_learnings_propose ON learning_proposals
  FOR INSERT WITH CHECK (
    app_auth.current_actor_role() = 'agent_worker'
    AND agent_id = app_auth.current_agent_id()
    AND status = 'pending'
  );

CREATE POLICY agent_decisions_select ON decision_packets
  FOR SELECT USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
  );

CREATE POLICY agent_decisions_stage ON decision_packets
  FOR INSERT WITH CHECK (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
    AND status = 'pending'
  );

CREATE POLICY agent_decisions_attach_qa ON decision_packets
  FOR UPDATE USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
    AND status = 'pending'
  )
  WITH CHECK (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
    AND status = 'pending'
  );

-- Domain Engines (Intelligence, Advisory, Ventures & Registry)
CREATE POLICY agent_publications_draft ON editorial_publications
  FOR ALL USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
  )
  WITH CHECK (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
    AND publication_status IN ('drafting', 'qa_verified', 'staged_for_train')
  );

CREATE POLICY agent_crm_rw ON crm_opportunities
  FOR ALL USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
  )
  WITH CHECK (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
  );

CREATE POLICY agent_engagements_rw ON advisory_engagements
  FOR ALL USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
  )
  WITH CHECK (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
  );

CREATE POLICY agent_dossiers_rw ON venture_dossiers
  FOR ALL USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
  )
  WITH CHECK (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
  );

CREATE POLICY agent_products_select ON products
  FOR SELECT USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
  );

CREATE POLICY agent_product_versions_select ON product_versions
  FOR SELECT USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND EXISTS (
      SELECT 1 FROM products p
      WHERE p.id = product_versions.product_id
        AND p.tenant_id = app_auth.current_tenant_id()
    )
  );

CREATE POLICY agent_service_offerings_select ON service_offerings
  FOR SELECT USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND EXISTS (
      SELECT 1 FROM products p
      WHERE p.id = service_offerings.product_id
        AND p.tenant_id = app_auth.current_tenant_id()
    )
  );

CREATE POLICY agent_deployments_smoke_rw ON production_deployments
  FOR SELECT USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND EXISTS (
      SELECT 1 FROM products p
      WHERE p.id = production_deployments.product_id
        AND p.tenant_id = app_auth.current_tenant_id()
    )
  );

CREATE POLICY agent_deployments_smoke_update ON production_deployments
  FOR UPDATE USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND EXISTS (
      SELECT 1 FROM products p
      WHERE p.id = production_deployments.product_id
        AND p.tenant_id = app_auth.current_tenant_id()
    )
  )
  WITH CHECK (
    app_auth.current_actor_role() = 'agent_worker'
    AND EXISTS (
      SELECT 1 FROM products p
      WHERE p.id = production_deployments.product_id
        AND p.tenant_id = app_auth.current_tenant_id()
    )
  );

CREATE POLICY agent_installations_select ON customer_installations
  FOR SELECT USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
  );

CREATE POLICY agent_mandates_steward_rw ON product_owner_mandates
  FOR SELECT USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND EXISTS (
      SELECT 1 FROM products p
      WHERE p.id = product_owner_mandates.product_id
        AND p.tenant_id = app_auth.current_tenant_id()
    )
  );

CREATE POLICY agent_mandates_steward_update ON product_owner_mandates
  FOR UPDATE USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND owner_agent_id = app_auth.current_agent_id()
  )
  WITH CHECK (
    app_auth.current_actor_role() = 'agent_worker'
    AND owner_agent_id = app_auth.current_agent_id()
  );

CREATE POLICY agent_launch_runs_select ON product_launch_runs
  FOR SELECT USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
  );

-- Economics & Outbox (Agents read margins, log negative compute costs only, and emit events)
CREATE POLICY agent_focus_sessions_select ON workspace_focus_sessions
  FOR SELECT USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
  );

CREATE POLICY agent_ledger_select ON true_cost_ledger
  FOR SELECT USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
  );

CREATE POLICY agent_ledger_insert_burn ON true_cost_ledger
  FOR INSERT WITH CHECK (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
    AND category IN ('llm_and_tool_burn', 'sandbox_and_hosting_infra')
    AND amount_usd <= 0
  );

CREATE POLICY agent_outbox_select ON outbox_events
  FOR SELECT USING (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
  );

CREATE POLICY agent_outbox_insert ON outbox_events
  FOR INSERT WITH CHECK (
    app_auth.current_actor_role() = 'agent_worker'
    AND tenant_id = app_auth.current_tenant_id()
    AND workspace_id = app_auth.current_workspace_id()
  );

-- ============================================================================
-- ROLE 3 POLICIES: client_portal_user (clients.offdata.com Strict Isolation)
-- ============================================================================
CREATE POLICY client_portal_tenant_select ON tenants
  FOR SELECT USING (
    app_auth.current_actor_role() = 'client_portal_user'
    AND id = app_auth.current_tenant_id()
  );

CREATE POLICY client_portal_workspaces_select ON workspaces
  FOR SELECT USING (
    app_auth.current_actor_role() = 'client_portal_user'
    AND tenant_id = app_auth.current_tenant_id()
    AND engine = 'advisory'
  );

CREATE POLICY client_portal_artifacts_select ON artifacts
  FOR SELECT USING (
    app_auth.current_actor_role() = 'client_portal_user'
    AND tenant_id = app_auth.current_tenant_id()
    AND client_portal_visible = TRUE
  );

CREATE POLICY client_portal_versions_select ON artifact_versions
  FOR SELECT USING (
    app_auth.current_actor_role() = 'client_portal_user'
    AND tenant_id = app_auth.current_tenant_id()
    AND EXISTS (
      SELECT 1 FROM artifacts a
      WHERE a.id = artifact_versions.artifact_id
        AND a.tenant_id = app_auth.current_tenant_id()
        AND a.client_portal_visible = TRUE
    )
  );

-- Allows client Deal-Room citation drawers to inspect ONLY cited evidence in visible artifacts
CREATE POLICY client_portal_cited_evidence_select ON evidence_ledger
  FOR SELECT USING (
    app_auth.current_actor_role() = 'client_portal_user'
    AND tenant_id = app_auth.current_tenant_id()
    AND EXISTS (
      SELECT 1
      FROM artifact_versions av
      JOIN artifacts a ON a.id = av.artifact_id
      WHERE a.tenant_id = app_auth.current_tenant_id()
        AND a.client_portal_visible = TRUE
        AND evidence_ledger.id = ANY(av.citation_evidence_ids)
    )
  );

CREATE POLICY client_portal_engagements_select ON advisory_engagements
  FOR SELECT USING (
    app_auth.current_actor_role() = 'client_portal_user'
    AND tenant_id = app_auth.current_tenant_id()
  );

CREATE POLICY client_portal_installations_select ON customer_installations
  FOR SELECT USING (
    app_auth.current_actor_role() = 'client_portal_user'
    AND tenant_id = app_auth.current_tenant_id()
  );

-- ----------------------------------------------------------------------------
-- 11. DAY-1 INSTITUTIONAL SEED (INTERNAL TENANT & 5 CORE WORKSPACES)
-- ----------------------------------------------------------------------------
INSERT INTO tenants (id, slug, name, is_internal, nda_strict, zdr_enforced, monthly_compute_cap_usd)
VALUES (
  '00000000-0000-4000-8000-000000000001',
  'offdata-internal',
  'OFFDATA Institutional Headquarters',
  TRUE,
  TRUE,
  TRUE,
  1000.00
);

INSERT INTO workspaces (id, tenant_id, slug, title, engine, environment, default_posture, maturity)
VALUES
  ('00000000-0000-4000-8000-000000000101', '00000000-0000-4000-8000-000000000001', 'hq-executive', 'Today & Global AI COO', 'executive', 'production', 'workbench', 'designed'),
  ('00000000-0000-4000-8000-000000000102', '00000000-0000-4000-8000-000000000001', 'intelligence-lab', 'OFFDATA Intelligence & Benchmarks', 'intelligence', 'production', 'workbench', 'designed'),
  ('00000000-0000-4000-8000-000000000103', '00000000-0000-4000-8000-000000000001', 'advisory-practice', 'OFFDATA Advisory & Delivery Studio', 'advisory', 'production', 'workbench', 'designed'),
  ('00000000-0000-4000-8000-000000000104', '00000000-0000-4000-8000-000000000001', 'solutions-factory', 'OFFDATA Solutions & Venture Factory', 'solutions', 'production', 'workbench', 'designed'),
  ('00000000-0000-4000-8000-000000000105', '00000000-0000-4000-8000-000000000001', 'frontier-lab', 'OFFDATA Frontier R&D Sandbox', 'solutions', 'frontier', 'workbench', 'designed');

COMMIT;

-- ----------------------------------------------------------------------------
-- 12. NON-SUPERUSER ROLE & SCHEMA GRANTS (REQUIRED FOR RLS EVALUATION)
-- ----------------------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticated') THEN
    CREATE ROLE authenticated NOLOGIN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN
    CREATE ROLE anon NOLOGIN;
  END IF;
END $$;

GRANT USAGE ON SCHEMA public, app_auth TO PUBLIC, authenticated, anon;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA app_auth TO PUBLIC, authenticated, anon;
-- Table GRANTs allow PostgREST/test roles to reach tables; FORCE RLS policies strictly gate row access
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;