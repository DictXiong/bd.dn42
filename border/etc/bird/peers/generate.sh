#!/bin/bash
set -e
THIS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]:-${(%):-%x}}" )" && pwd )
THIS_FILE=$(basename "${BASH_SOURCE}")

read -p "External or internal? [ei] "
if [[ "$REPLY" == "e" ]]; then
    TEMPLATE="$THIS_DIR/dn42e.conf.dis"
    read -p "Peer's ASN suffix: "
    if [[ ${#REPLY} != 4 ]]; then
        echo "Invalid ASN suffix" >&2
        exit
    fi
    export PEER_ASN_SUFFIX=$REPLY
    TARGET=/etc/bird/peers/dn42e-${PEER_ASN_SUFFIX}.conf
else
    TEMPLATE="$THIS_DIR/dn42i.conf.dis"
    read -p "Peer's name: "
    if [[ -z "$REPLY" ]]; then
        echo "Please provide the peer name" >&2
        exit
    fi
    export PEER_NAME=$REPLY
    TARGET=/etc/bird/peers/dn42i-${PEER_NAME}.conf
fi

if [[ -f $TARGET ]]; then
    echo "Target file $TARGET already exists"
    exit
fi

read -p "Peer's link-local address suffix: "
REPLY=${REPLY,,}
if [[ -z "$REPLY" ]]; then
    echo "Please provide the address" >&2
    exit
fi
export PEER_LA_SUFFIX=$REPLY

OUTPUT=$(envsubst < "$TEMPLATE")
echo "target file: $TARGET"
echo "file content: "
echo "====="
echo "$OUTPUT"
echo "====="
read -p "Press any key to continue"
printf "%s\n" "$OUTPUT" > "$TARGET"