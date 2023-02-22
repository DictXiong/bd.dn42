ARG THIS_ARCH_ALT=amd64
FROM multiarch/alpine:${THIS_ARCH_ALT}-edge
LABEL org.opencontainers.image.authors="me@beardic.cn" version="0.1"

RUN sh -c "echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories" \
    && apk --no-cache add curl bird supervisor dnsmasq net-tools iproute2 git bash zsh tcpdump tmux vim
#    && (curl dotfiles.cn | bash -s - -al)
COPY supervisord.conf /etc/supervisord.conf
COPY bird.conf /etc/bird.conf
COPY dnsmasq.conf /etc/dnsmasq.conf
RUN mkdir -p /opt && cd /opt && git clone https://github.com/DictXiong/bd.dn42

ENTRYPOINT ["/usr/bin/supervisord", "-n"]
