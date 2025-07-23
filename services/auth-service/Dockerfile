# build stage
FROM node:18-alpine AS build
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile
COPY . .
RUN yarn build

# runtime stage
FROM node:18-alpine
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY package.json yarn.lock ./
RUN yarn install --production --frozen-lockfile
USER node
ENV NODE_ENV=production
CMD ["node", "dist/index.js"]
