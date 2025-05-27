{ pkgs, ... }:
{

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    enableExtraSocket = true;
    pinentryPackage = pkgs.pinentry-qt;
    settings = {
      default-cache-ttl = 60;
      max-cache-ttl = 120;
    };
  };

}
