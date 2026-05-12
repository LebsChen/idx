{ pkgs, ... }: {
  channel = "stable-25.05";
  packages = [
    pkgs.openssh
    pkgs.curl
    pkgs.ttyd
  ];
  env = {};
  idx = {
    previews = {
      previews = {
        web = {
          command = [ "ttyd" "-p" "$PORT" "bash" ];
          manager = "web";
        };
      };
    };
    workspace = {
      onCreate = {
        setup-ssh-tunnel = "chmod +x ./start-ssh-tunnel.sh && ./start-ssh-tunnel.sh";
        default.openFiles = [ "README.md" "index.html" ];
      };
    };
  };
}
