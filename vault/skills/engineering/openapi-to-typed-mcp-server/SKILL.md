---
uri: "vault://skills/engineering/openapi-to-typed-mcp-server@v1.0.0"
version: "1.0.0"
ownerPod: "05_implementation_factory"
primaryAgent: "eng.connector-forge"
widgetType: "CraftBuildStageWorkbench"
---

# OpenAPI & API Docs to Typed MCP Connector

## 1. Objective
Autonomously scaffold, typecheck, and contract-test a scoped Model Context Protocol (MCP) server inside an isolated sandbox from an OpenAPI specification or API documentation URL.

## 2. Execution Protocol
1. **Extract & Scope Operations:**
   - Parse target endpoints; include read-only (`GET` / query) operations by default. Exclude destructive (`DELETE` / bulk overwrite) endpoints unless explicitly requested in the approved mission brief.
2. **Generate Strict TypeScript + Zod Server:**
   - Emit strict `camelCase` Zod input/output schemas for every MCP tool (`<= 15` focused tools per connector).
   - Route all outbound HTTP calls through the Zero-Knowledge Proxy helper using `{{VAULT:SECRET_REF}}` headers.
3. **Run Sandbox Contract Suite:**
   - Execute `pnpm typecheck` and deterministic mock-server request/response tests inside the sandbox; archive test logs to `evidence_ledger` and open a draft PR for Thursday Release Train review.

## 3. Deterministic Gate 1 Checks
- Zero hardcoded tokens, bearer strings, or basic-auth literals in generated source files.
- `tsc --noEmit` and Vitest contract assertions exit with code `0`.