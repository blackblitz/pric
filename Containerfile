ARG CUDA=true
FROM python:3.14.6-slim-trixie
COPY --from=ghcr.io/astral-sh/uv:0.11.29 /uv /usr/local/bin
COPY --from=ghcr.io/astral-sh/ruff:0.15.22 /ruff /usr/local/bin
COPY --from=ghcr.io/astral-sh/ty:0.0.61 /ty /usr/local/bin
RUN apt-get update && \
    apt-get install -y wget && \
    TEMP="$(mktemp)" && \
    wget -O "$TEMP" "https://github.com/helix-editor/helix/releases/download/25.07.1/helix_25.7.1-1_amd64.deb" && \
    dpkg -i "$TEMP" && \
    rm -f "$TEMP"
WORKDIR /root/pric
COPY pyproject.toml uv.lock README.md .
COPY src src
RUN if [ "$CUDA" = "true" ]; then \
        uv sync --extra=cuda --locked; \
    else \
        uv sync --locked; \
    fi
ENTRYPOINT ["uv", "run", "pric"]
