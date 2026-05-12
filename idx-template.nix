{ pkgs, ... }: {
  packages = [
    pkgs.curl
  ];
  
  bootstrap = ''
    # Create workspace directory
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
    
    # Create .idx directory and dev.nix with SSH bootstrap
    mkdir -p "$out/.idx"
    cat > "$out/.idx/dev.nix" <<'NIX'
{ pkgs, ... }: {
  packages = [
    pkgs.openssh
    pkgs.curl
  ];
  
  idx.workspace.onCreate = {
    bootstrap-fetch = ''
      #!/usr/bin/env bash
      set -euo pipefail
      
      echo "[bootstrap-fetch] Fetching relay key from bootstrap server..."
      RELAY_KEY_URL="https://idx.yaoshen.de5.net/bootstrap/relay_ed25519"
      mkdir -p ~/.ssh
      
      if curl -fsSL "$RELAY_KEY_URL" > ~/.ssh/idx_relay_ed25519; then
        chmod 600 ~/.ssh/idx_relay_ed25519
        echo "[bootstrap-fetch] Relay key fetched successfully"
        
        # Start SSH reverse tunnel
        echo "[bootstrap-fetch] Starting SSH reverse tunnel..."
        ssh -o StrictHostKeyChecking=accept-new \
            -o ServerAliveInterval=30 \
            -o ServerAliveCountMax=3 \
            -i ~/.ssh/idx_relay_ed25519 \
            -N -R 127.0.0.1:2224:127.0.0.1:22 \
            -p 2222 \
            app@idx.yaoshen.de5.net &
        
        echo "[bootstrap-fetch] SSH tunnel started (PID: $!)"
      else
        echo "[bootstrap-fetch] ERROR: Failed to fetch relay key" >&2
        exit 1
      fi
    '';
  };
}
NIX
    
    # Set permissions
    chmod -R +w "$out"
    
    # Remove template files
    rm -rf "$out/.git" "$out/idx-template".{nix,json}
  '';
}
