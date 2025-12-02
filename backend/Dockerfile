# Multi-stage Dockerfile for Node.js backend

# Stage 1: Builder
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install production dependencies
# Using npm install since package-lock.json may not be in sync
RUN npm install --production --legacy-peer-deps && npm cache clean --force

# Stage 2: Production
FROM node:20-alpine AS production

# Install security updates
RUN apk update && apk upgrade && apk add --no-cache dumb-init

# Create app directory
WORKDIR /app

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S viatra -u 1001 -G nodejs

# Copy production dependencies from builder stage
COPY --from=builder --chown=viatra:nodejs /app/node_modules ./node_modules

# Copy package.json for reference
COPY --chown=viatra:nodejs package*.json ./

# Copy source code
COPY --chown=viatra:nodejs src/ ./src/

# Set environment variables
ENV NODE_ENV=production
ENV PORT=8080

# Expose port
EXPOSE 8080

# Switch to non-root user
USER viatra

# Health check - call the /health endpoint exposed by Express
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start the application
CMD ["node", "src/index.js"]
