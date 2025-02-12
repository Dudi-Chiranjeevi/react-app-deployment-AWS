FROM node:18 AS builder

# Set working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy the rest of the app
COPY . .

# Build the React app
RUN npm run build

# Use a lightweight production image
FROM node:18-slim

# Set working directory
WORKDIR /usr/src/app

# Copy built files from the builder stage
COPY --from=builder /usr/src/app/build ./build

# Install only production dependencies
COPY package*.json ./
RUN npm install --production

# Expose port 3000
EXPOSE 3000

# Start the app using a lightweight server
CMD ["npx", "serve", "-s", "build", "-l", "3000"]
