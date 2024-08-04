{ inputs, lib, config, pkgs, ... }:

{

  # Virtualbox
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  users.extraGroups.vboxusers.members = [ "bruno" ];
  
  # Docker
  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "bruno" ];

}