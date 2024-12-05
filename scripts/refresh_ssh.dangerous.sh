#!/usr/bin/env sh

setup_ssh() {
    # "source" relative to the location of this script
    # https://stackoverflow.com/a/1638397/5302085
    . "$(dirname "$0")/setup_ssh.sh"
}

setup_ssh

for file in ./ssh/*; do
    if [ "$(basename "$file")" = "known_hosts" ]; then
        continue
    fi
    if [ "${file##*.}" = "pub" ]; then
        continue
    fi

    filename=$(basename "$file")
    new_filename="_new_$filename"
    new_file="./ssh/$new_filename"
    # Set $hostname and $user
    for token in $(echo "$filename" | tr "_" "\n"); do
        if [ -z "${hostname:-}" ]; then
            hostname="$token"
        elif [ -z "${user:-}" ]; then
            user="$token"
        fi
    done
    host="$hostname.host.neontech.dev"

    # Create new SSH public/private key pair
    ssh-keygen -t ed25519 -a 100 -C ansible -f "$new_file" -N ''
    # Copy new SSH public key to host
    ssh-copy-id -f -i "$new_file" -o "IdentityFile ./.ssh/$filename" "$user@$host"
    # Remove old SSH public key from host
    ssh -i "$new_file" "$user@$host" "sed -i '\|$(xargs -a "$file.pub")|d' ~/.ssh/authorized_keys"
    # Commit changed files on host
    ssh -i "$new_file" "$user@$host" 'if [ -n "$(command -v lbu)" ]; then lbu commit -d; fi'
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

echo "Waiting 10 seconds..."
sleep 10s
setup_ssh
