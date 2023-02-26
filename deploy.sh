#!/bin/bash
set -e
THIS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]:-${(%):-%x}}" )" && pwd )
THIS_FILE=$(basename "${BASH_SOURCE}")

help() {
    echo type service that you want do deploy
}

rpki() {
    docker run --name dn42-rpki -p 8282:8282 --restart=always -d cloudflare/gortr -verify=false -checktime=false -cache=https://dn42.burble.com/roa/dn42_roa_46.json
}

border() {
    rsync -rv --exclude "bird.conf" "$THIS_DIR"/border/etc/ /etc/
    if [[ ! -f /etc/bird/bird.conf ]]; then
        cp "$THIS_DIR"/border/etc/bird.conf /etc/bird.conf
    fi
}

$1
