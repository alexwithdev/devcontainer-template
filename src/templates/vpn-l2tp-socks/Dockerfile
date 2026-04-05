FROM ghcr.io/alexwithdev/devcontainer-template/base:latest

USER root

RUN apk add --no-cache \
  bash \
  tini \
  su-exec \
  libcap-utils \
  iproute2 \
  iptables \
  ppp \
  xl2tpd \
  dante-server

RUN mkdir -p /etc/ppp/peers && \
  touch /etc/ppp/options

RUN chmod u+s /usr/sbin/pppd && \
  setcap cap_net_admin,cap_net_raw+ep /usr/sbin/xl2tpd || true

RUN mkdir -p /home/developer/.config/vpn-l2tp-socks /home/developer/.local/run/xl2tpd /home/developer/.cache/vpn-l2tp-socks && \
  chown -R developer:developer /home/developer/.config /home/developer/.local /home/developer/.cache

COPY scripts/vpn-socks-entrypoint.sh /usr/local/bin/vpn-socks-entrypoint.sh
RUN chmod +x /usr/local/bin/vpn-socks-entrypoint.sh

USER root

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/vpn-socks-entrypoint.sh"]
