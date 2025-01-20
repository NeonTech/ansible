#!/usr/bin/env sh

set -o errexit

cert-enroller.sh
cert-renewer.sh

# Copy ENTRYPOINT from parent Dockerfile
exec /opt/bitnami/scripts/mysql/entrypoint.sh "$@"
