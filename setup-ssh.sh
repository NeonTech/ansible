#!/usr/bin/env sh

set -o errexit -o nounset

mkdir -p ./.ssh
chmod 700 ./ssh ./.ssh
chmod 600 ./vault-password-file

for file in ./ssh/*; do
    if [ "${file##*.}" = "pub" ]; then
        chmod 644 "$file"
        continue
    fi

    decrypt_file="./.ssh/${file##*/}"
    rm -f "$decrypt_file"
    ansible-vault decrypt --vault-password-file ./vault-password-file --output - "$file" >"$decrypt_file"

    chmod 600 "$file"
    chmod 600 "$decrypt_file"
done
