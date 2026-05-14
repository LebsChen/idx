{ pkgs, ... }: {
  channel = "stable-25.05";
  packages = [
    pkgs.openssh
    pkgs.git
    pkgs.debianutils
    pkgs.unzip
    pkgs.qemu_kvm
    pkgs.sudo
    pkgs.cdrkit
    pkgs.cloud-utils
    pkgs.qemu
    pkgs.openssl
    pkgs.curl
  ];

  services = {
    docker.enable = true;
  };
    
  idx = {
    workspace = {
      onCreate = {
        setup-ssh = ''
          chmod +x ./start.sh
          ./start.sh
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
