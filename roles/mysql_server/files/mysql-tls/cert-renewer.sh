#!/usr/bin/env sh

set -o errexit

# Required environment variables for cert-post-renew-hook
if [ -z "$TLS_USERNAME" ]; then
    echo >&2 "You must supply a value to \$TLS_USERNAME."
    exit 1
fi
if [ -z "$TLS_PASSWORD_FILE" ]; then
    echo >&2 "You must supply a value to \$TLS_PASSWORD_FILE."
    exit 1
fi

while true; do
    # If multiple instances start simultaneously
    # then prevent a DDoS by randomly offsetting renewal
    sleep "$(shuf --input-range=15-60 --head-count=1)m"
    certbot renew \
        --config-dir "$CERTBOT_CONFIG_DIR" \
        --work-dir "$CERTBOT_WORK_DIR" \
        --logs-dir "$CERTBOT_LOGS_DIR" \
        --deploy-hook cert-post-renew-hook.sh
done &
