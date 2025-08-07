# Build stage
FROM node:18-alpine AS build
WORKDIR /app
COPY package.json yarn.lock ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:18-alpine
WORKDIR /app
ENV NODE_ENV=production

COPY --from=build /app/dist ./dist
COPY package.json yarn.lock ./
RUN npm ci --only=production

USER node
EXPOSE 3000
CMD ["node", "dist/server.js"]
