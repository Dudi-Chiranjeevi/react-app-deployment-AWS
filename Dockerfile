# Use a base image with Node.js installed
FROM node:18-alpine AS build

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json first to leverage caching
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the application
COPY . .

# Set environment variables (if required)
ARG NODE_ENV=production
ENV NODE_ENV=$NODE_ENV

# Remove old build if it exists (optional, for safety)
RUN rm -rf build

# Build the React app
RUN npm run build

# Use a lightweight production image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy only the necessary files from the build stage
COPY --from=build /app/build /app/build
COPY --from=build /app/package.json /app/
COPY --from=build /app/node_modules /app/node_modules

# Install a lightweight HTTP server to serve static files
RUN npm install -g serve

# Expose the application port
EXPOSE 3000

# Start the React app in production mode
CMD ["serve", "-s", "build", "-l", "3000"]
