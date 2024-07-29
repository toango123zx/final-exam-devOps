# Define the base stage
FROM node:22.1.0

WORKDIR /app

COPY ./package*.json ./
COPY ./tsconfig*.json ./
COPY ./pnpm-lock.yaml ./

RUN npm install -g pnpm
RUN pnpm install

COPY . .

RUN pnpm build

# Define the build stage
FROM node:22.1.0-alpine AS base

WORKDIR /app

COPY ./package*.json ./
COPY ./tsconfig*.json ./
COPY ./pnpm-lock.yaml ./

FROM base AS build

RUN npm install -g pnpm
RUN pnpm install

COPY . .

RUN pnpm build
RUN pnpm prune --prod

FROM base AS deloy
# Define the deploy stage

COPY --from=build /app/dist /app/dist
COPY --from=build /app/node_modules /app/node_modules

# EXPOSE 3000

# ENV DATABASE_URL=mongodb+srv://user1:root@learn-depops.cxygkbf.mongodb.net/sgroup

CMD ["node", "dist/main.js"]