# Stage 1: Build dependencies
FROM oven/bun:1.1 AS builder

WORKDIR /app
COPY package.json ./
RUN bun install --production
COPY . .


# Stage 2: Slim runtime image
FROM oven/bun:1.1-slim

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