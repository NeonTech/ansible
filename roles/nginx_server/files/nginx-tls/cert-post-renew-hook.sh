#!/usr/bin/env sh

set -o errexit

# Copy certs to standardized paths
cert-post-enroll-hook.sh

nginx -s reload
