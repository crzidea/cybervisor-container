FROM python:3.11

ARG CYBERVISOR_VERSION=latest

# Explicit ARG reference forces BuildKit to include CYBERVISOR_VERSION in the
# cache key for the pip-install layer below, preventing stale layer reuse when
# the secret mount would otherwise mask the ARG change.
RUN echo "${CYBERVISOR_VERSION}" > /dev/null

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ENV NPM_CONFIG_PREFIX=/usr/local
RUN npm install -g @anthropic-ai/claude-code

ENV PATH="/usr/local/bin:$PATH"

RUN --mount=type=secret,id=cybervisor_pat \
    if [ "$CYBERVISOR_VERSION" = "latest" ]; then \
        pip install --no-cache-dir "cybervisor @ git+https://$(cat /run/secrets/cybervisor_pat)@github.com/crzidea/cybervisor.git"; \
    else \
        pip install --no-cache-dir "cybervisor @ git+https://$(cat /run/secrets/cybervisor_pat)@github.com/crzidea/cybervisor.git@v${CYBERVISOR_VERSION}"; \
    fi

# Verify the installed version matches the requested tag — fails fast on stale Docker cache.
RUN if [ "$CYBERVISOR_VERSION" != "latest" ]; then \
        INSTALLED=$(python -c "import importlib.metadata; print(importlib.metadata.version('cybervisor'))"); \
        if [ "$INSTALLED" != "$CYBERVISOR_VERSION" ]; then \
            echo "ERROR: expected cybervisor ${CYBERVISOR_VERSION} but installed ${INSTALLED}"; \
            exit 1; \
        fi; \
    fi

RUN mkdir /workspace && chmod 777 /workspace
WORKDIR /workspace

EXPOSE 8765

CMD ["bash"]