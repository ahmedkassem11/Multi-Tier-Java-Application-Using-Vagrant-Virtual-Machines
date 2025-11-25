#!/bin/bash
set -e

# WEB01 Provisioning Script

echo "Setting up hosts file..."
cat <<EOF | sudo tee -a /etc/hosts
192.168.56.11 web01
192.168.56.12 app01
192.168.56.13 rmq01
192.168.56.14 mc01
192.168.56.15 db01
EOF

echo "Installing Nginx..."
sudo yum install nginx -y

echo "Configuring Nginx..."
sudo sed -i 's/server_name[[:space:]]\+_;/server_name server1;/' /etc/nginx/nginx.conf


sudo mkdir -p /etc/nginx/ssl 

if [ -f  key.pem ] && [ -f cert.pem ];then
    echo "SSL certificate and key already exist. Skipping generation."
else
    openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem \
        -sha256 -days 3650 -nodes \
        -subj "/C=EG/ST=Cairo/L=Cairo/O=GoApplicatio/OU=ITservice/CN=www.goapplication.com"
fi

sudo cp cert.pem /etc/nginx/ssl/cert.pem
sudo cp key.pem /etc/nginx/ssl/key.pem
sudo chown nginx:nginx /etc/nginx/ssl/cert.pem
sudo chown nginx:nginx /etc/nginx/ssl/key.pem

sudo tee /etc/nginx/conf.d/server.conf <<'EOF'
upstream vproapp {
    server app01:8080;
}
server {
    listen 80;
    location / {
        return 301 https://$host$request_uri;
    }
}
server {
    listen 443 ssl;

    ssl_certificate     /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass http://vproapp;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF
sudo chown nginx:nginx  /etc/nginx/conf.d/server.conf 

sudo systemctl restart nginx
sudo systemctl enable nginx

echo "WEB01 setup complete."
