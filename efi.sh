#!/usr/bin/env bash

set -eo pipefail

if [[ -z "$1" ]]; then
    echo "id thing not specified (e.g. a595e96f-12a7-11f0-9d92-6c2f8049ca27)"
    exit 1
fi

id_thing="$1"

raw="$(sudo efibootmgr -v | grep "$id_thing")"
readarray entries <<< "$raw"

echo "result for id $id_thing :"
echo "$raw"
read -p "you sure this is correct? this action is (probably) irreversible (y/n/ctrl+c) : " desire

# https://www.cyberciti.biz/faq/linux-unix-shell-programming-converting-lowercase-uppercase/
if [[ "${desire,,}" != "y" ]]; then
    echo "cancelled operation"
    exit 0
fi

for x in "${entries[@]}"; do
    # https://stackoverflow.com/a/16485044
    sanitized="$(echo "$x" | xargs)"
    id="${sanitized:4:4}"
    # dangerous
    sudo efibootmgr -B -b "$id"
done
