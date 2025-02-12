# Use a minimal base image
FROM node:18-alpine AS build

# Set working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json first (for efficient caching)
COPY package*.json ./

# Install production dependencies only
RUN npm install --omit=dev

# Copy the rest of the application
COPY . .

# Build the React app
RUN npm run build

# Use a smaller production base image
FROM node:18-alpine

# Set working directory
WORKDIR /usr/src/app

# Copy only the necessary build files from the previous stage
COPY --from=build /usr/src/app/build /usr/src/app/build

# Install a lightweight HTTP server to serve the built React app
RUN npm install -g serve

# Expose port 3000
EXPOSE 3000

# Start the server
CMD ["serve", "-s", "build", "-l", "3000"]
