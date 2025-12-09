# Build stage
FROM node:18-alpine as build

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Build arguments for environment variables
ARG REACT_APP_API_URL
ARG REACT_APP_ENVIRONMENT
ENV REACT_APP_API_URL=${REACT_APP_API_URL}
ENV REACT_APP_ENVIRONMENT=${REACT_APP_ENVIRONMENT}

# Build the application
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy built files from build stage
COPY --from=build /app/build /usr/share/nginx/html

# Copy nginx configurations
# Use nginx-internal.conf for container deployment (behind reverse proxy)
# Use nginx.dev.conf for development (HTTP only)
# Use nginx.conf for production (HTTPS with SSL - standalone)
COPY nginx-internal.conf /etc/nginx/conf.d/nginx-internal.conf
COPY nginx.dev.conf /etc/nginx/conf.d/nginx.dev.conf
COPY nginx.conf /etc/nginx/conf.d/nginx.prod.conf

# Default to internal config (for use behind reverse proxy)
COPY nginx-internal.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
