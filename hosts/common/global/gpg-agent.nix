{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    pinentry-curses
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    enableExtraSocket = true;
    pinentryPackage = pkgs.pinentry-curses;
    settings = {
      default-cache-ttl = 60;
      max-cache-ttl = 120;
    };
  };

}