#!/usr/bin/env sh

set -o errexit

cert-enroller.sh
cert-renewer.sh

# Copy ENTRYPOINT from parent Dockerfile
/opt/bitnami/scripts/redis/entrypoint.sh "$@"
