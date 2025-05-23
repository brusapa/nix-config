{ inputs, pkgs, config, ... }:

{
  imports = [
    inputs.vpn-confinement.nixosModules.default 
  ];

  # Define VPN network namespace
  sops.secrets.torrent-wireguard-config = {
    sopsFile = ../secrets.yaml;
  };

  vpnNamespaces.downl = {
    enable = true;
    wireguardConfigFile = config.sops.secrets.torrent-wireguard-config.path;
    accessibleFrom = [
      "10.80.0.0/24"
    ];
    portMappings = [
      { from = 9091; to = 9091; } # Transmission
      { from = 8080; to = 8080; } # Sabnzbd
    ];
  };
}
