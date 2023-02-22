ARG THIS_ARCH_ALT=amd64
FROM multiarch/alpine:${THIS_ARCH_ALT}-edge

RUN sh -c "echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories" \
    && apk --no-cache add bird supervisor dnsmasq net-tools iproute2 git bash
COPY supervisord.conf /etc/supervisord.conf
COPY bird.conf /etc/bird.conf
RUN mkdir -p /opt && cd /opt && git clone https://github.com/DictXiong/bd.dn42 && cd bd.dn42/ns/dnsmasq && bash deploy.sh

ENTRYPOINT ["/usr/bin/supervisord", "-n"]
