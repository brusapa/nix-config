{ pkgs, ... }:

{
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
