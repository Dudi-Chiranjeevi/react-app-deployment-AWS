# Use a lightweight Node.js image
FROM node:18 AS build

WORKDIR /usr/src/app

# Copy package.json and package-lock.json first to leverage Docker cache
COPY package*.json ./

# Install dependencies
RUN npm install --omit=dev

# Copy the rest of the application
COPY . .

# Build the application
RUN npm run build

# Use a smaller base image for production
FROM node:18-alpine

WORKDIR /usr/src/app

# Copy only necessary files from the build stage
COPY --from=build /usr/src/app .

# Set the environment to production
ENV NODE_ENV=production

# Expose the application port
EXPOSE 3000

# Run the application
CMD ["npm", "start"]