{ lib, pkgs, ... }:

{

  programs.git = {
    enable = true;
    userName = "Bruno Santamaria";
    lfs.enable = true;
    userEmail = "30648587+brusapa@users.noreply.github.com";
    signing = {
      signByDefault = true;
      key = "BD6743DAE6ABDF36";
    };
  };

  programs.lazygit = {
    enable = true;
  };

}
