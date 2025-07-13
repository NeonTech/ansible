#!/usr/bin/env sh

set -o errexit -o nounset

requirements=requirements.txt
if [ ! -f $requirements ]; then
    printf "%s not found: re-execute in root of the repository\n" $requirements
    exit 1
fi

venv_dir=.venv
python -m venv $venv_dir
# shellcheck source=.venv/bin/activate
. $venv_dir/bin/activate

pip install --requirement $requirements
ansible-galaxy collection install --requirements-file collections.txt

vault_password_file=vault-password-file
if [ ! -f $vault_password_file ]; then
    printf "\n"
    stty -echo
    printf "Paste or type Ansible vault password: "
    read -r VAULT_PASSWORD
    stty echo
    printf "\n"

    touch $vault_password_file
    chmod 600 $vault_password_file
    printf %s "$VAULT_PASSWORD" >$vault_password_file
fi

#region SSH
private_ssh_dir=.ssh
if [ -d $private_ssh_dir ]; then
    rm --recursive $private_ssh_dir
fi
mkdir $private_ssh_dir
chmod 700 $private_ssh_dir

public_ssh_dir=ssh
for public_environment_dir in "$public_ssh_dir"/*; do
    environment=$(basename "$public_environment_dir")
    private_environment_dir=$private_ssh_dir/$environment
    mkdir "$private_environment_dir"
    chmod 700 "$private_environment_dir"

    for public_file in "$public_environment_dir"/*; do
        file=$(basename "$public_file")
        # Ignore known_hosts and .pub files
        if [ "$file" = known_hosts ]; then
            continue
        fi
        if [ "${file##*.}" = pub ]; then
            continue
        fi

        private_file=$private_environment_dir/$file
        touch "$private_file"
        chmod 600 "$private_file"
        ansible-vault decrypt --vault-password-file $vault_password_file --output - "$public_file" >"$private_file"
    done
done
#endregion
