#!/bin/bash
set -e
THIS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]:-${(%):-%x}}" )" && pwd )
THIS_FILE=$(basename "${BASH_SOURCE}")

test_not_empty()
{
    if [[ -z "$1" ]]; then
        echo $2 >&2
        exit
    fi
}

read -p "External or internal? [ei] "
if [[ "$REPLY" == "e" ]]; then
    TYPE=e
    TEMPLATE="$THIS_DIR/dn42e.conf.dis"
    read -p "Peer's ASN suffix: "
    if [[ ${#REPLY} != 4 ]]; then
        echo "Invalid ASN suffix" >&2
        exit
    fi
    export PEER_ASN_SUFFIX=$REPLY
    TARGET=/etc/bird/peers/dn42e-${PEER_ASN_SUFFIX}.conf
else
    TYPE=i
    TEMPLATE="$THIS_DIR/dn42i.conf.dis"
    read -p "Peer's name: "
    test_not_empty "$REPLY" "Please provide the peer name"
    export PEER_NAME=$REPLY
    TARGET=/etc/bird/peers/dn42i-${PEER_NAME}.conf
fi

if [[ -f $TARGET ]]; then
    echo "Target file $TARGET already exists"
    exit
fi

if [[ "$TYPE" == "e" ]]; then
    read -p "Peer's link-local address suffix: "
    test_not_empty "$REPLY" "Please provide the address"
    export PEER_LA_SUFFIX=${REPLY,,}
else
    read -p "Peer's GUA (in dn42, it's a ULA) suffix: "
    test_not_empty "$REPLY" "Please provide the address"
    export PEER_GUA_SUFFIX=${REPLY,,}
fi

OUTPUT=$(envsubst < "$TEMPLATE")
echo "target file: $TARGET"
echo "file content: "
echo "====="
echo "$OUTPUT"
echo "====="
read -p "Press any key to continue"
printf "%s\n" "$OUTPUT" > "$TARGET"