# ─────────── Builder Stage ───────────
FROM node:22-alpine AS builder
WORKDIR /app

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
FROM node:22-alpine
WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY package.json yarn.lock ./
RUN yarn install --production --frozen-lockfile

EXPOSE 3000
CMD ["yarn", "start"]
