#!/usr/bin/env sh

set -o errexit -o nounset

initialize=./scripts/initialize.sh
if [ ! -f $initialize ]; then
    echo $initialize not found: re-execute in root of the repository
    exit 1
fi
# shellcheck source=./scripts/initialize.sh
. $initialize

old_vault_password_file=./vault-password-file
new_vault_password_file=./new-vault-password-file

touch $new_vault_password_file
chmod 600 $new_vault_password_file
echo "##########################################"
echo What should be the ansible-vault password?
stty -echo
read -r ANSIBLE_VAULT_PASSWORD
printf %s "$ANSIBLE_VAULT_PASSWORD" >$new_vault_password_file
unset ANSIBLE_VAULT_PASSWORD
stty echo
echo

# Loop through a list of files that are not ignored by git
(git status --short | grep '^?' | cut --delimiter=" " -f2- && git ls-files) | while read -r vault_file; do
    # Ignore files that do not start with $ANSIBLE_VAULT;
    # shellcheck disable=SC2016
    if ! head --lines 1 "$vault_file" | grep --quiet '^\$ANSIBLE_VAULT;'; then
        continue
    fi
    echo "Attempting to rekey $vault_file"
    # Ignore files that are not viewable with ansible-vault
    if ! ansible-vault view --vault-password-file $old_vault_password_file "$vault_file" >/dev/null; then
        continue
    fi
    ansible-vault rekey --vault-password-file $old_vault_password_file --new-vault-password-file $new_vault_password_file "$vault_file"
done

rm $old_vault_password_file
mv $new_vault_password_file $old_vault_password_file
