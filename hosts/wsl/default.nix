{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ../common/global
    ../common/users/bruno
  ];

  wsl.enable = true;
  wsl.defaultUser = "bruno";

  # Allow VSCode remote server
  programs.nix-ld.package = pkgs.nix-ld-rs;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}