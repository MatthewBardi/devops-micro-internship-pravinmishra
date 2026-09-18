#!/bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# Give the small B1s VM extra memory for the React build.
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Install Git, Nginx, and a modern Node.js version.
apt-get update
apt-get install -y ca-certificates curl git nginx
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Download and build the course React application.
git clone https://github.com/pravinmishraaws/my-react-app.git /opt/my-react-app
cd /opt/my-react-app
sed -i "s/Your Full Name/Matthew Bardi/g; s#DD/MM/YYYY#$(date +%d/%m/%Y)#g" src/App.js
npm install --no-audit --no-fund
CI=false npm run build

# Serve the production build with Nginx.
rm -rf /var/www/html/*
cp -a build/. /var/www/html/
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

cat > /etc/nginx/sites-available/default <<'NGINX'
server {
    listen 80 default_server;
    server_name _;
    root /var/www/html;
    index index.html;

    location / {
        try_files $uri /index.html;
        error_page 404 /index.html;
    }
}
NGINX

nginx -t
systemctl enable nginx
systemctl restart nginx
test -s /var/www/html/index.html
echo "React deployment completed successfully."