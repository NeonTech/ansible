#!/bin/bash

tls_subject=""
declare -a tls_sans
for tls_domain in ${TLS_DOMAINS//,/ }; do
    if [ -z "$tls_subject" ]; then
        tls_subject=$tls_domain
    fi
    tls_sans=("${tls_sans[@]}" --domain "$tls_domain")
done
if [ -z "$tls_subject" ]; then
    echo >&2 "You must supply at least one value to \$TLS_DOMAINS."
    exit 1
fi

# Currently, for TLS termination, the reverse proxy does not use certificates
# from the private CA, thus, an email and public DNS is required for ACME.
if [ -z "$TLS_ACME_EMAIL" ]; then
    echo >&2 "You must supply a value to \$TLS_ACME_EMAIL."
    exit 1
fi
if [ -z "$TLS_ACME_CLOUDFLARE_FILE" ]; then
    echo >&2 "You must supply a value to \$TLS_ACME_CLOUDFLARE_FILE."
    exit 1
fi

certbot certonly \
    --non-interactive \
    --config-dir "$CERTBOT_CONFIG_DIR" \
    --work-dir "$CERTBOT_WORK_DIR" \
    --logs-dir "$CERTBOT_LOGS_DIR" \
    --agree-tos \
    --email "$TLS_ACME_EMAIL" \
    --dns-cloudflare \
    --dns-cloudflare-credentials "$TLS_ACME_CLOUDFLARE_FILE" \
    --dns-cloudflare-propagation-seconds 10 \
    --cert-name "$tls_subject" \
    "${tls_sans[@]}"
cert-post-enroll-hook.sh
