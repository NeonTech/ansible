#!/usr/bin/env sh

set -o errexit

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
