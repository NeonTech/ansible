#!/usr/bin/env sh

set -o errexit -o nounset

if [ ! -d ./ssh ]; then
    echo "ssh directory not found: re-execute in root of the repository"
    exit 1
fi

mkdir -p ./.ssh
chmod 700 ./ssh ./.ssh

if [ ! -f ./vault-password-file ]; then
    echo "What is the ansible-vault password?"
    stty -echo
    read -r ANSIBLE_VAULT_PASSWORD
    stty echo
    echo "$ANSIBLE_VAULT_PASSWORD" >./vault-password-file
    unset ANSIBLE_VAULT_PASSWORD
    echo
fi

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
