#!/usr/bin/env sh

set -o errexit -o nounset

setup_ssh=./scripts/setup_ssh.sh
if [ ! -f $setup_ssh ]; then
    echo $setup_ssh not found: re-execute in root of the repository
    exit 1
fi
# shellcheck source=./scripts/setup_ssh.sh
. $setup_ssh

venv_dir=./.venv
python -m venv $venv_dir
# shellcheck source=./.venv/bin/activate
. $venv_dir/bin/activate
pip install --requirement ./requirements.txt
