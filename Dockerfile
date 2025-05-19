# Stage 1: Build dependencies
FROM oven/bun:1.1 AS builder

WORKDIR /app
COPY package.json ./
RUN bun install --production
COPY . .


# Stage 2: Slim runtime image
FROM oven/bun:1.1-slim

WORKDIR /app

# Copy only needed files from builder
COPY --from=builder /app /app

# Optional: Remove test/dev files
RUN rm -rf src/__tests__ .git node_modules/.cache

EXPOSE 3000

CMD ["bun", "src/server.js"]