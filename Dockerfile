# 1️⃣ Base Stage: Build the Node.js Application
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package.json and yarn.lock first to optimize caching
COPY backend/package.json backend/yarn.lock ./

# Install dependencies using Yarn with frozen lockfile
RUN yarn install --frozen-lockfile --production

# Copy application source code
COPY backend/src ./src

# Ensure correct permissions
RUN chmod -R 755 /app

# 2️⃣ Final Stage: Runtime with Node.js & Nginx
FROM nginx:stable-alpine

# Set working directory
WORKDIR /app

# Install Node.js, Yarn & su-exec (for privilege dropping)
RUN apk add --no-cache nodejs yarn su-exec

# Create a non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy built Node.js app from the builder stage
COPY --from=builder /app /app

# Copy custom Nginx configuration
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Fix Nginx permission issues
RUN mkdir -p /var/cache/nginx /var/run /var/run/nginx && \
    chown -R root:root /var/cache/nginx /var/run/nginx /var/run && \
    chmod -R 777 /var/cache/nginx /var/run/nginx /var/run

# Expose ports
EXPOSE 80

# Start Nginx as root (needed for PID file) & Backend as a Non-Root User
CMD ["sh", "-c", "nginx && su-exec appuser yarn start"]
