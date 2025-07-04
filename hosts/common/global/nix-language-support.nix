{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.nixfmt-rfc-style
    pkgs.nixd
    pkgs.alejandra
  ];
}