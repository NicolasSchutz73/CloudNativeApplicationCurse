FROM node:20-alpine AS builder

LABEL maintainer="devops@gmail.com"
LABEL version="1.0.0"

# Install OpenSSL (required for Prisma)
RUN apk add --no-cache openssl

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY prisma ./prisma/

# Install dependencies
RUN npm ci && \
    npm cache clean --force

# Generate Prisma Client
RUN npx prisma generate

# Copy application source
COPY . .
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN npm run build

EXPOSE 3000

ENTRYPOINT ["docker-entrypoint.sh"]