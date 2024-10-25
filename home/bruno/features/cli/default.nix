{ pkgs, ... }:

{

  imports = [
    ./locale.nix
    ./unfree.nix
    ./git.nix
    ./gpg.nix
    ./shell.nix
    ./neovim.nix
  ];

}