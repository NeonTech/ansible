#!/usr/bin/env sh

set -o errexit

# This unique non-standard shim is required because the Certificate Authority
# depends on PostgreSQL. PostgreSQL must temporarily run with TLS disabled to
# allow the Certificate Authority to enroll a certificate.

export POSTGRESQL_ENABLE_TLS=no
# Copy ENTRYPOINT from parent Dockerfile
/opt/bitnami/scripts/postgresql/entrypoint.sh "$@" &

retries=0
max_retries=6
while
    rc=0
    cert-enroller.sh || rc=$?
    [ $rc -ne 0 ]
do
    if [ $retries -eq $max_retries ]; then
        echo >&2 "Failed enrollment...exiting..."
        exit 1
    fi

    echo >&2 "Failed enrollment...waiting..."
    sleep 10s

    retries=$((retries + 1))
    echo >&2 "Retrying ($retries / $max_retries) enrollment..."
done

cert-renewer.sh

pg_ctl --pgdata=/bitnami/postgresql/data stop
echo "Waiting for PostgreSQL to shutdown..."
sleep 10s

export POSTGRESQL_ENABLE_TLS=yes
# Copy ENTRYPOINT from parent Dockerfile
/opt/bitnami/scripts/postgresql/entrypoint.sh "$@"
