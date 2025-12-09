# Stage 1: Build the Vue application
FROM node:20-alpine AS builder

LABEL maintainer="devops@gmail.com"
LABEL version="1.0.0"

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including devDependencies needed for build)
RUN npm ci && \
    npm cache clean --force

# Copy application source
COPY . .

# Build the Vue application
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine

LABEL maintainer="devops@gmail.com"
LABEL version="1.0.0"

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built assets from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx (default CMD from nginx:alpine)
CMD ["nginx", "-g", "daemon off;"]
