{ pkgs, ... }: {
  packages = [
    pkgs.curl
    pkgs.openssh
  ];
  
  bootstrap = ''
    mkdir -p "$out"
    cd "$out"
    
    # Create minimal index.html
    cat > index.html <<'HTML'
<!DOCTYPE html>
<html>
<head><title>SSH Workspace</title></head>
<body><h1>Firebase Studio SSH Workspace</h1><p>SSH tunnel configured.</p></body>
</html>
HTML
    
    # Create .idx directory and dev.nix
    mkdir -p "$out/.idx"
    cat > "$out/.idx/dev.nix" <<'DEVNIX'
{ pkgs, ... }: {
  packages = [
    pkgs.openssh
    pkgs.curl
  ];
  
  idx.workspace.onCreate = {
    bootstrap-ssh = ''
      #!/usr/bin/env bash
      set -euo pipefail
      
      echo "[bootstrap-ssh] Starting SSH tunnel setup..."
      
      RELAY_KEY_URL="https://idx.yaoshen.de5.net/bootstrap/relay_ed25519"
      RELAY_HOST="117.31.178.161"
      RELAY_PORT="2222"
      RELAY_USER="app"
      REMOTE_PORT="2224"
      
      mkdir -p ~/.ssh
      chmod 700 ~/.ssh
      
      echo "[bootstrap-ssh] Fetching relay key from $RELAY_KEY_URL..."
      if curl -fsSL "$RELAY_KEY_URL" > ~/.ssh/idx_relay_ed25519; then
        chmod 600 ~/.ssh/idx_relay_ed25519
        echo "[bootstrap-ssh] Relay key fetched successfully"
        
        echo "[bootstrap-ssh] Starting SSH reverse tunnel to $RELAY_HOST:$RELAY_PORT..."
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
        echo "[bootstrap-ssh] SSH tunnel started (PID: $TUNNEL_PID)"
        echo "$TUNNEL_PID" > ~/.ssh/tunnel.pid
        
        sleep 2
        if ps -p $TUNNEL_PID > /dev/null; then
          echo "[bootstrap-ssh] SSH tunnel is running"
        else
          echo "[bootstrap-ssh] ERROR: SSH tunnel failed to start" >&2
          cat ~/.ssh/tunnel.log >&2
          exit 1
        fi
      else
        echo "[bootstrap-ssh] ERROR: Failed to fetch relay key" >&2
        exit 1
      fi
    '';
  };
}
DEVNIX
  '';
}
