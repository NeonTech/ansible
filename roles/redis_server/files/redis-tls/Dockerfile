ARG STEP_VERSION=0.28.2@sha256:dbe894c2d146b7389cc2e1e1d14cccd03f8c765a6eeb957f3340333c2f86a767
ARG REDIS_VERSION=7.4.1@sha256:33bca304adb3404963e8562c597fc83b800b79d2fbf1ff914bbd4bf1e16e3904
FROM smallstep/step-cli:${STEP_VERSION} AS step
FROM bitnami/redis:${REDIS_VERSION}

# TLS
ARG TLS_CA_HOST=localhost
ARG TLS_CA_PORT=443
ENV TLS_CA_URL=https://${TLS_CA_HOST}:${TLS_CA_PORT}
ARG TLS_CA_FINGERPRINT
ENV TLS_CA_FINGERPRINT=${TLS_CA_FINGERPRINT}
ENV TLS_DIR=/run/tls
ENV TLS_CA_CERT_FILE=$TLS_DIR/ca.crt
ENV TLS_CERT_FILE=$TLS_DIR/leaf.crt
ENV TLS_KEY_FILE=$TLS_DIR/leaf.key
# Parent Dockerfile TLS
ENV REDIS_TLS_ENABLED=true
ENV REDIS_TLS_CA_DIR=$TLS_DIR
ENV REDIS_TLS_CA_FILE=$TLS_CA_CERT_FILE
ENV REDIS_TLS_CERT_FILE=$TLS_CERT_FILE
ENV REDIS_TLS_KEY_FILE=$TLS_KEY_FILE

# Install step
COPY --from=step /usr/local/bin/step /usr/local/bin/
# Required for step
ENV STEPPATH=$TLS_DIR/.step

# Use root to...
# ...install jq (required to discover an ACME provisioner)
# ...download and install root certificate
# ...copy root certificate to TLS_CA_CERT_FILE
# ...change owner of TLS_DIR to expected USER
USER root
RUN apt-get update; \
    apt-get install --yes --no-install-recommends jq; \
    step ca bootstrap --ca-url=$TLS_CA_URL --fingerprint=$TLS_CA_FINGERPRINT --install; \
    cp $STEPPATH/certs/root_ca.crt $TLS_CA_CERT_FILE; \
    chown -R 1001:1001 $TLS_DIR;

# ...install certbot
# https://certbot.eff.org/instructions?ws=other&os=pip&tab=wildcard
# NOTE: libaugeas0 is ommitted as Apache plugin is not required
RUN apt-get install --yes --no-install-recommends python3 python3-venv; \
    python3 -m venv /opt/certbot/; \
    /opt/certbot/bin/pip install --upgrade pip; \
    /opt/certbot/bin/pip install certbot; \
    ln --symbolic /opt/certbot/bin/certbot /usr/bin/certbot; \
    /opt/certbot/bin/pip install certbot-dns-rfc2136
# Required for certbot
ENV REQUESTS_CA_BUNDLE=$TLS_CA_CERT_FILE
ENV CERTBOT_DIR=$TLS_DIR/.letsencrypt
ENV CERTBOT_CONFIG_DIR=$CERTBOT_DIR/config
ENV CERTBOT_WORK_DIR=$CERTBOT_DIR/work
ENV CERTBOT_LOGS_DIR=$CERTBOT_DIR/logs

# Revert to USER from parent Dockerfile
USER 1001

COPY entrypoint-shim.sh cert-*.sh /usr/local/bin/
ENTRYPOINT ["entrypoint-shim.sh"]
# Copy CMD from parent Dockerfile
CMD ["/opt/bitnami/scripts/redis/run.sh"]
