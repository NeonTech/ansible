#!/usr/bin/env sh

set -o errexit

# Copy certs to standardized paths
cert-post-enroll-hook.sh

pg_ctl --pgdata=/bitnami/postgresql/data reload
