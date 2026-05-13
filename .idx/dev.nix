{ pkgs, ... }: {
  channel = "stable-25.05";
  packages = [
    pkgs.openssh
    pkgs.git
  ];
  
  idx = {
    workspace = {
      onCreate = {
        setup-ssh = ''
          chmod +x ./start.sh
        '';
      };
      onStart = {
        setup-ssh = ''
          echo "[onStart] Starting SSH tunnel..."
          ./start.sh
        '';
      };
    };
  };
}
