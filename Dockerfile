# Use a lightweight Node.js image for building
FROM node:18-alpine AS build

# Set working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to leverage Docker caching
COPY package*.json ./

# Install only production dependencies
RUN npm install --omit=dev

# Copy the rest of the application
COPY . .

# Build the React app
RUN npm run build

# Use a smaller production base image
FROM node:18-alpine

# Set working directory
WORKDIR /usr/src/app

# Copy only necessary files from the build stage
COPY --from=build /usr/src/app/package.json ./
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/build ./build

# Set environment to production
ENV NODE_ENV=production

# Expose port 3000
EXPOSE 3000

# Serve the React app using a lightweight HTTP server
CMD ["npx", "serve", "-s", "build", "-l", "3000"]
