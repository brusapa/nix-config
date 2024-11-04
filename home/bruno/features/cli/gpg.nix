{ lib, pkgs, ... }:

{
  programs.gpg = {
    enable = true;
    publicKeys = [
      {
        source = ../../GPGPublicKey.asc;
        trust = "ultimate";
      }
    ];
  };

  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt;
    defaultCacheTtl = 60; # https://github.com/drduh/config/blob/master/gpg-agent.conf
    maxCacheTtl = 120; # https://github.com/drduh/config/blob/master/gpg-agent.conf
  };
}