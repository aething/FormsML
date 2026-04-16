FROM node:20-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

FROM base AS deps
WORKDIR /app
COPY package.json pnpm-lock.yaml* ./
RUN pnpm install --no-frozen-lockfile

FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# КРИТИЧЕСКИЕ ПЕРЕМЕННЫЕ ДЛЯ СБОРКИ PAYLOAD 3.0
ARG DATABASE_URI
ARG PAYLOAD_SECRET
ARG NEXT_PUBLIC_SERVER_URL

ENV DATABASE_URI=$DATABASE_URI
ENV PAYLOAD_SECRET=$PAYLOAD_SECRET
ENV NEXT_PUBLIC_SERVER_URL=$NEXT_PUBLIC_SERVER_URL
ENV NODE_ENV=production

RUN pnpm run build

FROM base AS runner
WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

EXPOSE 3000
ENV PORT=3000

CMD ["node", "server.js"]