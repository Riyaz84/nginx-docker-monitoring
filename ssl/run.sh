#!/bin/bash

# Create necessary directories
mkdir -p html
echo "<h1>Hello from Nginx!</h1>" > html/index.html

# Create Docker network
docker network create my_network

# Run Nginx container
docker run -d --name nginx_server \
  --network my_network \
  -v $(pwd)/html:/usr/share/nginx/html \
  -p 8080:80 \
  nginx

# Run Netdata for monitoring
docker run -d --name netdata \
  --network my_network \
  -p 19999:19999 \
  --cap-add SYS_PTRACE \
  --security-opt apparmor=unconfined \
  netdata/netdata

# Run Nginx as a reverse proxy for HTTPS
docker run -d --name nginx_proxy \
  --network my_network \
  -v $(pwd)/ssl:/etc/nginx/ssl \
  -p 443:443 \
  nginx:alpine \
  /bin/sh -c "echo 'server { listen 443 ssl; server_name localhost; ssl_certificate /etc/nginx/ssl/cert.pem; ssl_certificate_key /etc/nginx/ssl/key.pem; location / { proxy_pass http://nginx_server:80; } }' > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"

# SSH access setup in the monitoring container
docker exec -it netdata bash -c "apt-get update && apt-get install -y openssh-server && service ssh start && echo 'PermitRootLogin no' >> /etc/ssh/sshd_config && echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && echo 'root:password' | chpasswd"

# Display URLs
echo "Nginx server is running on http://localhost:8080"
echo "Netdata monitoring dashboard is running on http://localhost:19999"
echo "Nginx HTTPS proxy is running on https://localhost"

