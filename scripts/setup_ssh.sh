#!/usr/bin/env sh

set -o errexit -o nounset

public_ssh_dir=./ssh
if [ ! -d $public_ssh_dir ]; then
    echo $public_ssh_dir not found: re-execute in root of the repository
    exit 1
fi
chmod 755 $public_ssh_dir

private_ssh_dir=./.ssh
mkdir -p $private_ssh_dir
chmod 700 $private_ssh_dir

vault_password_file=./vault-password-file
if [ ! -f $vault_password_file ]; then
    touch $vault_password_file
    chmod 600 $vault_password_file
    echo "###################################"
    echo What is the ansible-vault password?
    stty -echo
    read -r ANSIBLE_VAULT_PASSWORD
    printf %s "$ANSIBLE_VAULT_PASSWORD" >$vault_password_file
    unset ANSIBLE_VAULT_PASSWORD
    stty echo
    echo
fi

for file in "$public_ssh_dir"/*; do
    if [ "$(basename "$file")" = known_hosts ]; then
        chmod 644 "$file"
        continue
    fi
    if [ "${file##*.}" = pub ]; then
        chmod 644 "$file"
        continue
    fi
    chmod 600 "$file"

    decrypt_file=$private_ssh_dir/${file##*/}
    rm -f "$decrypt_file"
    touch "$decrypt_file"
    chmod 600 "$decrypt_file"
    ansible-vault decrypt --vault-password-file $vault_password_file --output - "$file" >"$decrypt_file"
done
