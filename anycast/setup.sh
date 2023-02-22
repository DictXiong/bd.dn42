#!/bin/bash
set -e

setup_network()
{
    docker network create -d macvlan --internal --subnet 172.21.123.72/29 --ipv6 --subnet fda5:adba:5953:53::0/64 --attachable dn42-anycast
    docker network create -d bridge --subnet 172.18.53.1/24 --ipv6 --subnet fd5f:1867:ac9e:63ab::1/64 dn42-nat
    echo please add \" -A POSTROUTING -s fd5f:1867:ac9e:63ab::1/64 -j MASQUERADE \" to /etc/ufw/before6.rules
}

rm_network()
{
    docker network rm dn42-anycast
    docker network rm dn42-nat
    echo "remember to remove your nat6 settings"
}


setup_ns1()
{
    docker run --cap-add NET_ADMIN --cap-add NET_RAW --cap-add NET_BROADCAST \
        --network dn42-anycast --ip 172.21.123.78 --ip6 fda5:adba:5953:53::53 \
        --name dn42-ns1 --restart always -d dictxiong/ns1.bd.dn42
    docker network connect --ip 172.18.53.2 --ip6 fd5f:1867:ac9e:63ab::2 dn42-nat dn42-ns1
}

func=$1
shift
$func "$@"
