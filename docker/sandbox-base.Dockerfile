# syntax=docker/dockerfile:1.7
# ==============================================================================
# OFFDATA & CompanyOS — Pre-Baked Live Computer, REA & Craft Anything Base Image
# Build once locally: docker build -f docker/sandbox-base.Dockerfile -t offdata/sandbox-base:local .
# ==============================================================================

# ------------------------------------------------------------------------------
# STAGE 1: Compile Craft Anything Rust CLI/MCP Binary Once (Cached Layer)
# ------------------------------------------------------------------------------
FROM rust:1-bookworm AS craft-builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    git pkg-config libssl-dev ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
ARG CRAFT_ANYTHING_REPO="https://github.com/storytold/craft-anything.git"
ARG CRAFT_ANYTHING_REF="main"

RUN git clone --depth 1 --branch "${CRAFT_ANYTHING_REF}" "${CRAFT_ANYTHING_REPO}" ./craft-anything \
    && cd ./craft-anything \
    && cargo build --release \
    && strip target/release/craft-anything-cli || true

# ------------------------------------------------------------------------------
# STAGE 2: Institutional Live Computer Runtime (Ubuntu 24.04 + GUI + REA + PW)
# ------------------------------------------------------------------------------
FROM ubuntu:24.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:99 \
    SCREEN_RESOLUTION=1440x900x24 \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright \
    REA_MCP_TOOL_CATALOG_PROFILE=hot-cold \
    CRAFT_DEFAULT_MODE=clean-room

# Install procps (mandatory 'ps' binary for morluto/rea), Xvfb, Fluxbox, x11vnc, noVNC & Node 22
RUN apt-get update && apt-get install -y --no-install-recommends \
    procps \
    ca-certificates \
    curl \
    gnupg \
    git \
    jq \
    unzip \
    python3 \
    python3-pip \
    python3-venv \
    xvfb \
    fluxbox \
    x11vnc \
    novnc \
    websockify \
    dbus-x11 \
    fonts-liberation \
    fonts-noto-color-emoji \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" \
    > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update && apt-get install -y --no-install-recommends nodejs \
    && npm install -g pnpm@9 rea-agents@latest \
    && npx playwright@1.50.0 install --with-deps chromium \
    && rm -rf /var/lib/apt/lists/*

# Copy pre-compiled Craft Anything binary from Stage 1
COPY --from=craft-builder /build/craft-anything/target/release/craft-anything-cli /usr/local/bin/craft-anything-cli
RUN chmod +x /usr/local/bin/craft-anything-cli

# Create non-root isolated operator account
RUN groupadd -g 1001 offdata \
    && useradd -m -u 1001 -g offdata -s /bin/bash offdata \
    && mkdir -p /workspace /artifacts \
    && chown -R offdata:offdata /workspace /artifacts /ms-playwright

# Self-contained entrypoint supporting both Live WebSocket Desktop & Headless CI
COPY --chmod=0755 <<'EOF' /usr/local/bin/entrypoint-sandbox.sh
#!/usr/bin/env bash
set -euo pipefail

# Verify mandatory REA runtime dependency
command -v ps >/dev/null 2>&1 || { echo "FATAL: procps 'ps' binary missing"; exit 1; }

if [[ "${SANDBOX_HEADLESS:-0}" != "1" ]]; then
  rm -f /tmp/.X99-lock
  Xvfb "${DISPLAY}" -screen 0 "${SCREEN_RESOLUTION}" -ac +extension GLX +render -noreset &
  sleep 0.5
  fluxbox >/tmp/fluxbox.log 2>&1 &
  x11vnc -display "${DISPLAY}" -nopw -forever -shared -rfbport 5900 -quiet >/tmp/x11vnc.log 2>&1 &
  websockify --web=/usr/share/novnc/ 6080 localhost:5900 >/tmp/websockify.log 2>&1 &
fi

exec "$@"
EOF

USER offdata
WORKDIR /workspace

# Internal port 6080 MUST be bound dynamically on host (127.0.0.1:0:6080)
EXPOSE 6080

ENTRYPOINT ["/usr/local/bin/entrypoint-sandbox.sh"]
CMD ["sleep", "infinity"]