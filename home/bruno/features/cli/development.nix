{ pkgs, ... }:
{
  
  home.packages = with pkgs; [
    devenv
    # Nix related packages
    nixfmt
    nixd
    alejandra
  ];

  programs.direnv = {
    enable = true;
  };
}