# Staged for the new production host. Keep disabled until DNS for both names
# points here; then enable it, issue the certificate, and switch HTTP to HTTPS.
upstream bakecycle_puma {
  server 127.0.0.1:3000 fail_timeout=0;
}

# Preserve the canonical hostname while still serving ACME challenges for both
# names during certificate issuance.
server {
  listen 80;
  listen [::]:80;
  server_name www.bakecycle.com;

  location ^~ /.well-known/acme-challenge/ {
    root /var/www/bakecycle_next_production/shared/public;
  }

  location / {
    return 301 http://bakecycle.com$request_uri;
  }
}

server {
  listen 80;
  listen [::]:80;
  server_name bakecycle.com;

  root /var/www/bakecycle_next_production/current/public;
  client_max_body_size 50M;

  location ^~ /.well-known/acme-challenge/ {
    root /var/www/bakecycle_next_production/shared/public;
  }

  location ^~ /assets/ {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
  }

  location /cable {
    proxy_pass http://bakecycle_puma;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_read_timeout 3600s;
  }

  try_files $uri/index.html $uri @bakecycle;

  location @bakecycle {
    proxy_pass http://bakecycle_puma;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }
}
