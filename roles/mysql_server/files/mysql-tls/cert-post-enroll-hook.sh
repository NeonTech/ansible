#!/bin/bash

set -o errexit

for tls_domain in ${TLS_DOMAINS//,/ }; do
    tls_subject=$tls_domain
    break
done

renewal_file=$CERTBOT_CONFIG_DIR/renewal/$tls_subject.conf
# Add configuration to the top of the file iif (uncommented) configuration does not exist
if ! grep --invert --regexp "^#" "$renewal_file" | grep --quiet renew_before_expiry; then
    sed --in-place '1s/^/renew_before_expiry = 8 hours\n/' "$renewal_file"
fi

cp "$CERTBOT_CONFIG_DIR/live/$tls_subject/fullchain.pem" "$TLS_CERT_FILE"
cp "$CERTBOT_CONFIG_DIR/live/$tls_subject/privkey.pem" "$TLS_KEY_FILE"
