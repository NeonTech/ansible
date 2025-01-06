#!/bin/bash

tls_subject=""
declare -a tls_sans
for tls_domain in ${TLS_DOMAINS//,/ }; do
    if [ "$tls_subject" = "" ]; then
        tls_subject=$tls_domain
    fi
    tls_sans=("${tls_sans[@]}" --domain "$tls_domain")
done
if [ "$tls_subject" = "" ]; then
    echo >&2 "You must supply at least one value to \$TLS_DOMAINS."
    exit 1
fi

# Discover an ACME provisioner
provisioner=$(step ca provisioner list | jq --raw-output '[.[] | select(.type == "ACME") | .name][0]')
if [ "$provisioner" = "null" ]; then
    echo >&2 "No ACME provisioners found."
    exit 1
else
    tls_acme_url=$TLS_CA_URL/acme/$provisioner/directory
    echo "Using ACME URL: ${tls_acme_url}"
fi

if [ -z "$TLS_ACME_RFC2136_FILE" ]; then
    echo >&2 "You must supply a value to \$TLS_ACME_RFC2136_FILE."
    exit 1
fi

certbot certonly \
    --non-interactive \
    --config-dir "$CERTBOT_CONFIG_DIR" \
    --work-dir "$CERTBOT_WORK_DIR" \
    --logs-dir "$CERTBOT_LOGS_DIR" \
    --register-unsafely-without-email \
    --server "$tls_acme_url" \
    --dns-rfc2136 \
    --dns-rfc2136-credentials "$TLS_ACME_RFC2136_FILE" \
    --dns-rfc2136-propagation-seconds 10 \
    --cert-name "$tls_subject" \
    "${tls_sans[@]}"
cert-post-enroll-hook.sh
