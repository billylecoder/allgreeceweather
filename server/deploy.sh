#!/usr/bin/env bash
set -euo pipefail

# Use a dedicated non-root SSH account on the VPS.
REMOTE_HOST="deploy@example.com"
REMOTE_DIR="/var/www/weather-blog/public"

# Build locally; abort if Hugo reports an error.
hugo --gc --minify

# Upload only the generated site. --delete keeps the server in sync with the local build.
rsync -az --delete public/ "${REMOTE_HOST}:${REMOTE_DIR}/"
