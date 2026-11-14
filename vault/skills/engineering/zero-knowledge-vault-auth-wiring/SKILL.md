---
uri: "vault://skills/engineering/zero-knowledge-vault-auth-wiring@v1.0.0"
version: "1.0.0"
ownerPod: "05_implementation_factory"
primaryAgent: "eng.connector-forge"
artifactKind: "qa_verification_bundle"
---

# Zero-Knowledge Vault Credential Wiring

## 1. Objective
Configure authenticated HTTP headers, OAuth bearer tokens, and browser login autofills through symbolic `{{VAULT:UPPERCASE_REF}}` placeholders so plaintext credentials never enter LLM context windows or database logs.

## 2. Execution Protocol
1. **Declare Symbolic Secret Reference:**
   - Register only uppercase symbolic identifiers matching `^[A-Z0-9_]+$` inside `vaultSecretRefs`.
2. **Bind Proxy Injection Template:**
   - Configure outbound adapter requests with `Authorization: Bearer {{VAULT:SECRET_NAME}}` signed with the container's ephemeral run HMAC so `secret-vault` substitutes the live token at the network boundary and scrubs response reflections.
3. **Verify Redaction:**
   - Execute a test call against an echo interceptor in the sandbox and assert the raw secret string does not appear in stdout, stderr, or `agent_runs` telemetry.

## 3. Deterministic Gate 1 Checks
- Secret-scanner regex confirms zero high-entropy secret literals in git diff or artifact payloads.