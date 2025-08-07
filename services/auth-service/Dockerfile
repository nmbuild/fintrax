# Build stage ──────────────
FROM node:18-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage - using the built application
# This stage is optimized for production use
FROM node:18-alpine
WORKDIR /app
ENV NODE_ENV=production

COPY --from=build /app/dist ./dist
COPY package.json package-lock.json ./
RUN npm ci --only=production

USER node
EXPOSE 3000
CMD ["node", "dist/src/server.js"]
