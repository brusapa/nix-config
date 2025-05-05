{ pkgs, ... }:

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

  home.packages = [
    pkgs.pinentry-curses
  ];

  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true;
    enableFishIntegration = true;
    pinentryPackage = pkgs.pinentry-curses;
    defaultCacheTtl = 60; # https://github.com/drduh/config/blob/master/gpg-agent.conf
    maxCacheTtl = 120; # https://github.com/drduh/config/blob/master/gpg-agent.conf
  };
}
