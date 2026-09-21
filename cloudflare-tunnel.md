# Cloudflare Tunnel: Adding a New Subdomain

Steps to expose a local service through an existing `cloudflared` tunnel via a new subdomain.

## 1. Confirm the service is reachable locally

```bash
curl -sS -o /dev/null -w '%{http_code}\n' http://localhost:<PORT>
```

Expect `200` (or another valid HTTP status) before wiring up the tunnel.

## 2. Find your tunnel's config file and name

Typical location: `~/.cloudflared/config.yml`

```yaml
tunnel: <TUNNEL_NAME>
credentials-file: ~/.cloudflared/<TUNNEL_ID>.json

ingress:
  - hostname: existing.example.com
    service: http://localhost:<OTHER_PORT>
  - service: http_status:404
```

The last rule (`http_status:404`) must always stay last — it's the catch-all.

## 3. Add an ingress rule for the new subdomain

Insert a new entry **above** the catch-all rule:

```yaml
  - hostname: newsubdomain.example.com
    service: http://localhost:<PORT>
```

Back up the config first:

```bash
cp ~/.cloudflared/config.yml ~/.cloudflared/config.yml.bak
```

## 4. Create the DNS route

```bash
cloudflared tunnel route dns <TUNNEL_NAME> newsubdomain.example.com
```

If this fails with `Tunnel not found`, the local `cert.pem` (from `cloudflared tunnel login`) is likely scoped to a different Cloudflare account/zone than the one that owns the tunnel. In that case, add the DNS record manually instead:

- Go to the Cloudflare dashboard → DNS for the zone
- Add a **CNAME** record:
  - Name: `newsubdomain`
  - Target: `<TUNNEL_ID>.cfargotunnel.com`
  - Proxy status: Proxied (orange cloud)

## 5. Restart the tunnel service

```bash
sudo systemctl restart cloudflared
sudo systemctl status cloudflared --no-pager
```

## 6. Verify

```bash
curl -sS -o /dev/null -w '%{http_code}\n' https://newsubdomain.example.com
```

Check logs if something's wrong:

```bash
journalctl -u cloudflared -n 50 --no-pager
```

## Notes

- One tunnel can serve multiple hostnames — you don't need a new tunnel per subdomain, just a new ingress rule + DNS record.
- If `cloudflared tunnel list` doesn't show a tunnel you know exists, it usually means your local login cert belongs to a different account than the one that created that tunnel.
