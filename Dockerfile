# Use a base image with Node.js installed
FROM node:18-alpine AS build

# Set working directory
WORKDIR /app

# Copy package files first for caching
COPY package.json package-lock.json ./

# Fix for potential permission issues
RUN npm config set unsafe-perm true

# Install dependencies with fallback
RUN npm ci || npm install --legacy-peer-deps

# Copy the rest of the app
COPY . .

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
