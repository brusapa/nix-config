{ inputs, lib, config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [ 
    devenv
  ];

  programs.direnv.enable = true;
}