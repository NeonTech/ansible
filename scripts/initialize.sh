#!/usr/bin/env sh

set -o errexit -o nounset

requirements=./requirements.txt
if [ ! -f $requirements ]; then
    echo $requirements not found: re-execute in root of the repository
    exit 1
fi

venv_dir=./.venv
python -m venv $venv_dir
# shellcheck source=./.venv/bin/activate
. $venv_dir/bin/activate

pip install --requirement $requirements
