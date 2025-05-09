{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    pinentry-curses
    pinentry-tty
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    enableExtraSocket = true;
    pinentryPackage = pkgs.pinentry-tty;
    settings = {
      default-cache-ttl = 60;
      max-cache-ttl = 120;
    };
  };

}
