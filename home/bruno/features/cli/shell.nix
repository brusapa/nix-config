{ lib, pkgs, ... }:

{

  programs.bash = {
    enable = true;
    shellAliases = {
      la = "ls -la";
    };
  };

  programs.starship = {
    enable = true;
  };

}
