#!/usr/bin/env sh

set -o errexit

# Copy certs to standardized paths
cert-post-enroll-hook.sh

REDISCLI_AUTH="$(cat "$TLS_PASSWORD_FILE")"
export REDISCLI_AUTH

redis-cli \
    --tls \
    --cacert "$TLS_CA_CERT_FILE" \
    --cert "$TLS_CERT_FILE" \
    --key "$TLS_KEY_FILE" \
    --user "$TLS_USERNAME" \
    config set tls-cert-file "$TLS_CERT_FILE"
