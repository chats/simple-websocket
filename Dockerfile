# Stage 1: Build dependencies
FROM oven/bun:1.1 AS builder

WORKDIR /app
COPY package.json ./
RUN bun install --production
COPY . .


# Stage 2: Slim runtime image
#FROM oven/bun:1.1-slim
FROM debian:bookworm-slim

# Install necessary packages
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libgcc-s1 \
    libstdc++6 \
    libssl3 \
    libcurl4 \
    unzip \
    && rm -rf /var/lib/apt/lists/*


# Install bun
RUN apt-get update && apt-get install -y \
    curl \
    && curl -fsSL https://bun.sh/install | bash \
    && rm -rf /var/lib/apt/lists/*
ENV PATH="/root/.bun/bin:${PATH}"
# Install bun dependencies
##RUN bun env add --global \
#    bun:node \
#    bun:bun \
#    bun:bun-libc \
#    bun:libc \
#    bun:libssl \
#    bun:libcurl

# Create non-root user
RUN addgroup --system app && adduser --system --ingroup app appuser

WORKDIR /app

# Copy only needed files from builder
COPY --from=builder /app /app

# Optional: Remove test/dev files
RUN rm -rf src/__tests__ .git node_modules/.cache

# Change ownership (optional if COPY already uses builder's permissions)
RUN chown -R appuser:app /app

USER appuser

EXPOSE 3000

CMD ["bun", "src/server.js"]