{ pkgs, ... }:

{

  services = {
    pcscd.enable = true;
    udev.packages = [ pkgs.yubikey-personalization ];
  };

  environment.systemPackages = with pkgs; [
    yubikey-touch-detector
    yubikey-manager
  ];

  # Get a notification when the yubikey is waiting for a touch
  systemd.user.services.yubikey-touch-detector = {
    description = "Yubikey touch detector";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.yubikey-touch-detector}/bin/yubikey-touch-detector --libnotify";
    };
  };

  # Allow use of sudo with yubikey
  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

}
