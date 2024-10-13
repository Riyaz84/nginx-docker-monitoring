# Use Nginx official image
FROM nginx:alpine

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy HTML content
COPY ./html /usr/share/nginx/html

# Expose HTTP and HTTPS ports
EXPOSE 80 443

