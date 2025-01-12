#!/usr/bin/env sh

set -o errexit

# Copy certs to standardized paths
cert-post-enroll-hook.sh

mariadb \
    --user="$TLS_USERNAME" \
    --password="$(cat "$TLS_PASSWORD_FILE")" \
    --no-auto-rehash \
    --execute="FLUSH SSL"
