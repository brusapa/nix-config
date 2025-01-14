{ pkgs, ... }:

{

  imports = [
    ./locale.nix
    ./unfree.nix
    ./git.nix
    #./gpg.nix
    ./shell.nix
    ./ssh.nix
    ./nvf.nix
  ];

  catppuccin = {
    enable = true;
    flavor = "latte";
  };

}
