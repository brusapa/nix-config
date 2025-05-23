{ pkgs, config, ... }:

{
  # Create a user for the usenet service
  users.users.usenet = {
    uid = 3001;
    group = "downloads";
    isSystemUser = true;
    createHome = false;
  };

  # Add systemd service to VPN network namespace
  systemd.services.sabnzbd.vpnConfinement = {
    enable = true;
    vpnNamespace = "downl";
  };

  services.sabnzbd = {
    enable = true;
    openFirewall = true;
    user = "usenet";
    group = "downloads";
  };
}
