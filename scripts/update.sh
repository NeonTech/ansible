#!/usr/bin/env sh

set -o errexit -o nounset

requirements=requirements.txt
if [ ! -f $requirements ]; then
    printf "%s not found: re-execute in root of the repository\n" $requirements
    exit 1
fi

# https://pypi.org/project/pip-review
pip-review --interactive
pip freeze >$requirements

ansible-galaxy install --role-file requirements.yml
