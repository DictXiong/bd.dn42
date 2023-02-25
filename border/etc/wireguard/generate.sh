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
    TARGET=/etc/wireguard/dn42e-${PEER_ASN_SUFFIX}.conf
    export MY_PORT=$((PEER_ASN_SUFFIX+48000))
else
    TYPE=i
    TEMPLATE="$THIS_DIR/dn42i.conf.dis"
    read -p "Peer's name: "
    test_not_empty "$REPLY" "Please provide the peer name"
    export PEER_NAME=$REPLY
    TARGET=/etc/wireguard/dn42i-${PEER_NAME}.conf
    read -p "Your port: "
    if [[ $REPLY > 65535 || $REPLY < 1 ]]; then
        echo "Invalid port number"
        exit
    fi
    export MY_PORT=$REPLY
fi
if [[ -f $TARGET ]]; then
    echo "Target file $TARGET already exists"
    exit
fi
read -p "Your private key (leave blank to generate): "
if [[ -z "$REPLY" ]]; then
    export MY_PRIVATE_KEY=$(wg genkey)
    echo generated private/public key:
    echo $MY_PRIVATE_KEY
    echo $MY_PRIVATE_KEY | wg pubkey
else
    export MY_PRIVATE_KEY="$REPLY"
fi
read -p "Your link-local address suffix (leave blank to auto-detect): "
if [[ -z "$REPLY" ]]; then
    if [[ "$TYPE" == "e" ]]; then
        export MY_LA_SUFFIX=1366
    else
        tmp=$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | sha256sum | tr '[A-Z]' '[a-z]' | head -c 8)
        export MY_LA_SUFFIX=${tmp:0:4}:${tmp:4:4}
    fi
    echo "Use suffix: $MY_LA_SUFFIX"
else
    export MY_LA_SUFFIX=${REPLY,,}
fi
read -p "Your GUA (in dn42, it's a ULA) suffix: "
test_not_empty "$REPLY" "Please provide GUA suffix"
export MY_GUA_SUFFIX=${REPLY,,}
read -p "Your IPv4 address: "
test_not_empty "$REPLY" "Please provide your IPv4 address"
export MY_ADDR=$REPLY
read -p "Peer IPv4 address: "
test_not_empty "$REPLY" "Please provide peer's IPv4 address"
export PEER_ADDR=$REPLY
read -p "Peer pubkey: "
test_not_empty "$REPLY" "Please provide peer's pubkey"
export PEER_PUBLIC_KEY=$REPLY
read -p "Peer endpoint: "
test_not_empty "$REPLY" "Please provide peer's endpoint"
export PEER_ENDPOINT=$REPLY

OUTPUT=$(envsubst < "$TEMPLATE")
echo "target file: $TARGET"
echo "file content: "
echo "====="
echo "$OUTPUT"
echo "====="
read -p "Press any key to continue"
printf "%s\n" "$OUTPUT" > "$TARGET"

SERVICE="wg-quick@$(basename $TARGET .conf)"
echo "start the service with: systemctl start $SERVICE"
echo "stop the service with: systemctl stop $SERVICE"
