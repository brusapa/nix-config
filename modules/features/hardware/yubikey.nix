{
  den.aspects.yubikey.nixos = {

    services.pcscd.enable = true;

    programs.yubikey-manager.enable = true;

    # Get a notification when the yubikey is waiting for a touch
    programs.yubikey-touch-detector = {
      enable = true;
    };

    # Allow use of sudo with yubikey
    security.pam.services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
    };
  };
}
