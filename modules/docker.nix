{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    ctop
    lazydocker
    dive
  ];

  virtualisation.docker.enable = true;
}