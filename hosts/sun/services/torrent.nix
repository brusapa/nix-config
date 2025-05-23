{ pkgs, config, ... }:

{
  # Create a user for the torrent service
  users.users.torrent = {
    uid = 3000;
    group = "downloads";
    isSystemUser = true;
    createHome = false;
  };

  # Add systemd service to VPN network namespace
  systemd.services.transmission.vpnConfinement = {
    enable = true;
    vpnNamespace = "downl";
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
