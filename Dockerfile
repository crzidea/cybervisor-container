FROM python:3.11 AS cybervisor-base

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

RUN curl -fsSL https://claude.ai/install.sh | bash \
    && cp -r /root/.local/share/claude /usr/local/share/claude \
    && chmod -R 755 /usr/local/share/claude \
    && CLAUDE_VERSION=$(readlink /root/.local/bin/claude | xargs basename) \
    && printf "#!/bin/bash\n/usr/local/share/claude/versions/$CLAUDE_VERSION \"\$@\"" > /usr/local/bin/claude \
    && chmod +x /usr/local/bin/claude

ENV PATH="/usr/local/bin:$PATH"

RUN mkdir /workspace && chmod 777 /workspace
WORKDIR /workspace

CMD ["bash"]