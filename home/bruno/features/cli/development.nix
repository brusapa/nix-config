{ pkgs, ... }:
{
  
  home.packages = with pkgs; [
    devenv
    # Nix related packages
    nixfmt-rfc-style
    nixd
    alejandra
  ];

  programs.direnv = {
    enable = true;
  };
}