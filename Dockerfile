# 1️⃣ Base Stage: Build the Node.js Application
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies using Yarn with frozen lockfile
COPY backend/package.json backend/yarn.lock ./
RUN yarn install --frozen-lockfile --production

# Copy application source code
COPY backend/src ./src

# 2️⃣ Final Stage: Nginx + Node.js
FROM nginx:stable-alpine

# Set working directory
WORKDIR /app

# Copy built Node.js app from the builder stage
COPY --from=builder /app /app

# Install Node.js runtime and Yarn for running the backend inside Nginx
RUN apk add --no-cache nodejs yarn

# Copy custom Nginx configuration
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Set permissions
RUN chmod -R 755 /app

# Expose ports
EXPOSE 80

# Start Node.js backend and Nginx together
CMD ["sh", "-c", "yarn start & nginx -g 'daemon off;'"]
