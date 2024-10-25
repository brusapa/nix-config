{ lib, pkgs, ... }:

{

  programs.bash = {
    enable = true;
    shellAliases = {
      la = "ls -la";
    };
    initExtra = ''
      gpgconf --create-socketdir
    '';
  };

  programs.starship = {
    enable = true;
  };

}
