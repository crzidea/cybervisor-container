FROM python:3.11

ARG CYBERVISOR_VERSION=latest

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ENV NPM_CONFIG_PREFIX=/usr/local
RUN npm install -g @anthropic-ai/claude-code

ENV PATH="/usr/local/bin:$PATH"

RUN --mount=type=secret,id=cybervisor_pat \
    if [ "$CYBERVISOR_VERSION" = "latest" ]; then \
        pip install --no-cache-dir "cybervisor @ git+https://$(cat /run/secrets/cybervisor_pat)@github.com/cybervisor/cybervisor.git"; \
    else \
        pip install --no-cache-dir "cybervisor @ git+https://$(cat /run/secrets/cybervisor_pat)@github.com/cybervisor/cybervisor.git@v${CYBERVISOR_VERSION}"; \
    fi

RUN mkdir /workspace && chmod 777 /workspace
WORKDIR /workspace

EXPOSE 8765

CMD ["bash"]