# ─────────── Builder Stage ───────────
FROM node:22-alpine AS builder
WORKDIR /app

# Install build dependencies for native modules (lightningcss/swc)
RUN apk add --no-cache \
    libc6-compat \
    python3 \
    make \
    g++

# 1) Accept build-args
ARG NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY
ARG NEXT_PUBLIC_API_URL

# 2) Export them into the Next build environment
ENV NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=${NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY}
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}

# 3) Dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# 4) Source + Build
COPY . .
RUN yarn build

# ─────── Production Stage ───────
FROM node:22-alpine AS runner
WORKDIR /app

# Install runtime dependencies
RUN apk add --no-cache libc6-compat

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Create non-root user for security
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy built application
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

CMD ["node", "server.js"]
