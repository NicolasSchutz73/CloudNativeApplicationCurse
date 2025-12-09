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
RUN npm ci --only=production && \
    npm cache clean --force

# Generate Prisma Client
RUN npx prisma generate

# Copy application source
COPY . .

RUN npm run build

EXPOSE 3000

CMD ["npm", "start"]