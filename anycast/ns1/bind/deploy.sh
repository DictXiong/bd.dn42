#!/bin/bash
set -e
THIS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]:-${(%):-%x}}" )" && pwd )
THIS_FILE=$(basename "${BASH_SOURCE}")

cd "$THIS_DIR"
for file in "$THIS_DIR"/*; do
    if [ ! "$file" -ef "$THIS_FILE" ]; then
        echo cp $file /etc/bind/
    fi
done

