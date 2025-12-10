#!/usr/bin/env sh

set -o errexit -o nounset

export PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1

venv_dir=./.venv
python -m venv $venv_dir
# shellcheck source=./.venv/bin/activate
. $venv_dir/bin/activate
pip install --requirement ./requirements.txt

setup_ssh=./scripts/setup_ssh.sh
if [ ! -f $setup_ssh ]; then
    echo $setup_ssh not found: re-execute in root of the repository
    exit 1
fi
# shellcheck source=./scripts/setup_ssh.sh
. $setup_ssh
