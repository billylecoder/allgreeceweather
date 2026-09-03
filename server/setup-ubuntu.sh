#!/usr/bin/env bash
set -euo pipefail

# Run on a fresh Ubuntu/Debian VPS as root.
# Replace the domain in the Nginx files before enabling the site.

apt-get update
apt-get install -y nginx rsync ufw curl ca-certificates certbot python3-certbot-nginx

# Create a non-root account used only for deployments.
if ! id deploy >/dev/null 2>&1; then
    adduser --disabled-password --gecos "" deploy
fi

# Minimal firewall: SSH + HTTP + HTTPS.
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable

install -d -o deploy -g www-data -m 0755 /var/www/weather-blog/public

# Install your SSH public key for the deploy user before first deployment.
# Example (run from your own computer, not the VPS):
#   ssh-copy-id deploy@example.com
#
# Copy server/nginx-http.conf to /etc/nginx/sites-available/weather-blog.
# Replace example.com with your real domain, then enable it:
#   ln -s /etc/nginx/sites-available/weather-blog /etc/nginx/sites-enabled/weather-blog
#   rm -f /etc/nginx/sites-enabled/default
#   nginx -t
#   systemctl reload nginx
#
# Finally request HTTPS with Certbot:
#   certbot --nginx -d example.com -d www.example.com
#
# After confirming key-based SSH works for deploy, harden SSH separately by disabling
# root/password login in /etc/ssh/sshd_config, then: systemctl reload ssh
