# Use a base image with Node.js installed
FROM node:18-alpine AS build

# Set working directory
WORKDIR /app

# Ensure required tools are installed
RUN apk add --no-cache bash

# Copy package files first for caching
COPY package.json package-lock.json ./

# Set NPM to allow unsafe operations
ENV NPM_CONFIG_UNSAFE_PERM=true
ENV NODE_OPTIONS="--max-old-space-size=1024"

# Install dependencies with fallback
RUN npm ci || npm install --legacy-peer-deps

# Copy the rest of the application
COPY . .

# Ensure correct permissions
RUN chmod -R 777 /app

# Build the React app
RUN npm run build

# Use a lightweight production image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy built app
COPY --from=build /app/build /app/build
COPY --from=build /app/package.json /app/
COPY --from=build /app/node_modules /app/node_modules

# Install a lightweight HTTP server
RUN npm install -g serve

# Expose the application port
EXPOSE 3000

# Start the React app
CMD ["serve", "-s", "build", "-l", "3000"]
