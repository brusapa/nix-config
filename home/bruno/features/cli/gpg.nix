{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (writeShellScriptBin "fixgpg" ''
    #!/bin/sh
    gpgconf --kill gpg-agent
    echo "GPG agent restarted. Please, re-establish the SSH connection."
    '')
  ];

  programs.gpg = {
    enable = true;

    # https://support.yubico.com/hc/en-us/articles/4819584884124-Resolving-GPG-s-CCID-conflicts
    scdaemonSettings = {
      disable-ccid = true;
    };

    publicKeys = [
      {
        source = ../../GPGPublicKey.asc;
        trust = "ultimate";
      }
    ];
  };
}
