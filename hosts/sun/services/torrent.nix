{ inputs, pkgs, config, ... }:

{
  imports = [
    inputs.vpn-confinement.nixosModules.default 
  ];

  # Create a user for the torrent service
  users.users.torrent = {
    uid = 3000;
    group = "downloads";
    isSystemUser = true;
    createHome = false;
  };

  # Define VPN network namespace
  sops.secrets.torrent-wireguard-config = {
    sopsFile = ../secrets.yaml;
  };

  vpnNamespaces.downloads = {
    enable = true;
    wireguardConfigFile = config.sops.secrets.torrent-wireguard-config.path;
    accessibleFrom = [
      "10.80.0.0/24"
    ];
    portMappings = [
      { from = 9091; to = 9091; }
    ];
  };

  # Add systemd service to VPN network namespace
  systemd.services.transmission.vpnConfinement = {
    enable = true;
    vpnNamespace = "downloads";
  };

  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    user = "torrent";
    group = "downloads";
    openFirewall = true;
    openRPCPort = true;
    settings = {
      download-dir = "/mnt/torrent/completed";
      incomplete-dir = "/mnt/torrent/incompleted";
      rpc-bind-address = "0.0.0.0";
      rpc-host-whitelist-enabled = false;
      rpc-whitelist-enabled = false;
    };
  };
}
