# VPN L2TP + SOCKS5 (independent template)

This template is separate from base and runs as non-root user (uid 1000).

Includes:
- L2TP client via xl2tpd + ppp
- SOCKS5 proxy via dante-server

## 1) Prepare env file

```bash
cp .env.example .env
```

Edit `.env` with your VPN credentials.

## 2) Start with docker compose (recommended)

```bash
docker compose up -d --build
```

It starts:
- `vpn-socks` (L2TP + SOCKS5 on port 1080)
- `http-client-example` (example container using `ALL_PROXY=socks5h://vpn-socks:1080`)

## 3) Check logs

```bash
docker compose logs -f vpn-socks
```

## 4) Make your own HTTP service use proxy

Set env in your service/container:

```bash
ALL_PROXY=socks5h://vpn-socks:1080
```

## Notes

- Current setup targets your no-PSK L2TP case (`VPN_ENABLE_IPSEC=false`).
- IPsec+PSK mode is intentionally disabled in non-root runtime.
- SOCKS username/password mode is also disabled in this non-root variant.
- If logs show `pppd: Can't open options file /etc/ppp/options`, rebuild image to pick up the Dockerfile that creates this file.
- `pppd ... plugin option requires root privilege` means L2TP dialing must start as root. This template now starts container as root for dialing, then runs `sockd` as `developer`.
- If SOCKS connects but target private IP times out, set `VPN_ROUTE_CIDRS` in `.env` to force routes through PPP (example: `VPN_ROUTE_CIDRS=192.168.1.0/24`).
