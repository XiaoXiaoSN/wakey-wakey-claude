FROM debian:bookworm-slim

# install curl and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# install claude-code
RUN curl -fsSL https://claude.ai/install.sh | bash

# set PATH if the installer puts binary in ~/.local/bin
ENV PATH="/root/.local/bin:${PATH}"

# set environment variables for minimum token usage
ENV ANTHROPIC_MODEL=haiku
ENV DISABLE_PROMPT_CACHING=0
ENV PROMPT="reply hi only"

# CLAUDE_CODE_OAUTH_TOKEN should be provided at runtime via docker run -e or k8s secret
# get token by running: claude setup-token

# create directory for mounting config only
# credentials are now provided via environment variable
RUN mkdir -p /root/.claude

# default command: minimal token usage query
CMD ["sh", "-c", "claude -p --model $ANTHROPIC_MODEL --max-turns 1 \"$PROMPT\""]

