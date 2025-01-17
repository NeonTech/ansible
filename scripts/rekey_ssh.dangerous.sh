#!/usr/bin/env sh

set -o errexit -o nounset

setup_ssh=./scripts/setup_ssh.sh
if [ ! -f $setup_ssh ]; then
    echo $setup_ssh not found: re-execute in root of the repository
    exit 1
fi
# shellcheck source=./scripts/setup_ssh.sh
. $setup_ssh

ssh_dir=./ssh
for file in "$ssh_dir"/*; do
    if [ "$(basename "$file")" = known_hosts ]; then
        continue
    fi
    if [ "${file##*.}" = pub ]; then
        continue
    fi

    filename=$(basename "$file")
    new_filename=_new_$filename
    new_file=$ssh_dir/$new_filename
    # Set $hostname and $user
    for token in $(echo "$filename" | tr _ "\n"); do
        if [ -z "${hostname:-}" ]; then
            hostname=$token
        elif [ -z "${user:-}" ]; then
            user=$token
        fi
    done
    host=$hostname.host.neontech.dev
    known_hosts=$ssh_dir/known_hosts

    # Create new SSH public/private key pair
    ssh-keygen -t ed25519 -a 100 -C ansible -f "$new_file" -N ''
    # Copy new SSH public key to host
    ssh-copy-id -f -i "$new_file" -o "UserKnownHostsFile $known_hosts" -o "IdentityFile ./.ssh/$filename" "$user@$host"
    # Remove old SSH public key from host
    ssh -i "$new_file" -o "UserKnownHostsFile $known_hosts" "$user@$host" "sed -i '\|$(xargs -a "$file.pub")|d' ~/.ssh/authorized_keys"
    # Commit changed files on host
    ssh -i "$new_file" -o "UserKnownHostsFile $known_hosts" "$user@$host" 'if [ -n "$(command -v lbu)" ]; then lbu commit -d; fi'
    # Encrypt new SSH private key
    ansible-vault encrypt --vault-password-file ./vault-password-file "$new_file"
    # Remove old SSH public/private key pair
    rm "$file"
    rm "$file.pub"
    # Rename new SSH public/private key pair to "old"
    mv "$new_file" "$file"
    mv "$new_file.pub" "$file.pub"

    unset hostname
    unset user
done

echo Waiting 10 seconds...
sleep 10s
# shellcheck source=./scripts/setup_ssh.sh
. $setup_ssh
