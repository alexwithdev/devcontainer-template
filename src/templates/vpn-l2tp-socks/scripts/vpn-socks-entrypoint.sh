#!/usr/bin/env bash
set -euo pipefail

# Required
: "${VPN_SERVER:?missing VPN_SERVER}"
: "${VPN_USER:?missing VPN_USER}"
: "${VPN_PASSWORD:?missing VPN_PASSWORD}"

# Optional
VPN_LNS_NAME="${VPN_LNS_NAME:-vpn}"
SOCKS_PORT="${SOCKS_PORT:-1080}"
SOCKS_USER="${SOCKS_USER:-}"
SOCKS_PASS="${SOCKS_PASS:-}"
VPN_ENABLE_IPSEC="${VPN_ENABLE_IPSEC:-false}"   # true/false
VPN_PSK="${VPN_PSK:-}"
VPN_ROUTE_CIDRS="${VPN_ROUTE_CIDRS:-}"
RUNTIME_DIR="${RUNTIME_DIR:-/home/developer/.local/run/xl2tpd}"
CONFIG_DIR="${CONFIG_DIR:-/home/developer/.config/vpn-l2tp-socks}"
CACHE_DIR="${CACHE_DIR:-/home/developer/.cache/vpn-l2tp-socks}"

find_ppp_if_with_ipv4() {
  local dev
  for dev in $(ip -o link show | awk -F': ' '/ppp[0-9]+/ {print $2}'); do
    if ip -4 -o addr show dev "${dev}" scope global | grep -q 'inet '; then
      echo "${dev}"
      return 0
    fi
  done
  return 1
}

setup_l2tp_no_ipsec() {
  mkdir -p "${CONFIG_DIR}" "${RUNTIME_DIR}" "${CACHE_DIR}"

  cat > "${CONFIG_DIR}/xl2tpd.conf" <<EOF
[global]
port = 1701

[lac ${VPN_LNS_NAME}]
lns = ${VPN_SERVER}
pppoptfile = ${CONFIG_DIR}/options.l2tpd.client
length bit = yes
EOF

  cat > "${CONFIG_DIR}/options.l2tpd.client" <<EOF
ipcp-accept-local
ipcp-accept-remote
refuse-eap
refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
require-mppe-128
noccp
noauth
mtu 1410
mru 1410
nodefaultroute
usepeerdns
connect-delay 5000
debug
lcp-echo-interval 30
lcp-echo-failure 4
name "${VPN_USER}"
password "${VPN_PASSWORD}"
logfile ${CACHE_DIR}/ppp.log
EOF

  xl2tpd -D -c "${CONFIG_DIR}/xl2tpd.conf" -p "${RUNTIME_DIR}/xl2tpd.pid" -C "${RUNTIME_DIR}/l2tp-control" &
  sleep 2
  echo "c ${VPN_LNS_NAME}" > "${RUNTIME_DIR}/l2tp-control"

  # Ensure PPP interface has a usable IPv4 before exposing SOCKS.
  for _i in $(seq 1 25); do
    if find_ppp_if_with_ipv4 >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done

  echo "[ERR] PPP interface with IPv4 was not established. L2TP negotiation failed; check VPN credentials/server policy." >&2
  if [ -f "${CACHE_DIR}/ppp.log" ]; then
    echo "[ERR] ---- ppp.log (tail) ----" >&2
    tail -n 120 "${CACHE_DIR}/ppp.log" >&2 || true
    echo "[ERR] ------------------------" >&2
  fi
  echo "[ERR] If tunnel is established then immediately closed, server may require L2TP/IPsec (cert/PSK) instead of plain L2TP." >&2
  exit 1
}

setup_l2tp_ipsec_psk() {
  echo "[ERR] VPN_ENABLE_IPSEC=true requires root-managed IPsec. Current image is configured for non-root runtime." >&2
  echo "[ERR] Keep VPN_ENABLE_IPSEC=false for your no-PSK L2TP setup." >&2
  exit 1
}

start_socks() {
  local ext_if
  local cidr
  ext_if="$(find_ppp_if_with_ipv4 || true)"
  if [ -z "${ext_if}" ]; then
    echo "[ERR] No PPP interface with IPv4 is available for SOCKS external interface." >&2
    exit 1
  fi

  if [ -n "${VPN_ROUTE_CIDRS}" ]; then
    echo "[INFO] Applying static routes via ${ext_if}: ${VPN_ROUTE_CIDRS}"
    for cidr in $(echo "${VPN_ROUTE_CIDRS}" | tr ',' ' '); do
      ip route replace "${cidr}" dev "${ext_if}" || true
    done
  fi

  echo "[INFO] Using PPP interface ${ext_if}"
  ip -4 -o addr show dev "${ext_if}" || true
  ip route show || true

  if [ -n "${SOCKS_USER}" ] && [ -n "${SOCKS_PASS}" ]; then
    echo "[ERR] SOCKS username/password mode needs root-level account provisioning in this image." >&2
    echo "[ERR] Leave SOCKS_USER/SOCKS_PASS empty for non-root mode." >&2
    exit 1
  else
    method_line="socksmethod: none"
    rule_method="socksmethod: none"
  fi

  cat > "${CONFIG_DIR}/sockd.conf" <<EOF
logoutput: stderr
internal: 0.0.0.0 port = ${SOCKS_PORT}
external: ${ext_if}
${method_line}
user.privileged: developer
user.notprivileged: developer

client pass {
  from: 0.0.0.0/0 to: 0.0.0.0/0
  log: connect disconnect error
}
socks pass {
  from: 0.0.0.0/0 to: 0.0.0.0/0
  command: bind connect udpassociate
  log: connect disconnect error
  ${rule_method}
}
EOF

  if [ "$(id -u)" -eq 0 ]; then
    echo "Running with non-root privileges via su-exec developer"
    exec su-exec developer sockd -p "${RUNTIME_DIR}/sockd.pid" -f "${CONFIG_DIR}/sockd.conf"
  else
    echo "Running with current user privileges"
    exec sockd -p "${RUNTIME_DIR}/sockd.pid" -f "${CONFIG_DIR}/sockd.conf"
  fi

}

if [ "${VPN_ENABLE_IPSEC}" = "true" ]; then
  setup_l2tp_ipsec_psk
else
  setup_l2tp_no_ipsec
fi

start_socks
