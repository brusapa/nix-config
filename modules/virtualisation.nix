{ inputs, lib, config, pkgs, ... }:

{

  # Distrobox
  environment.systemPackages = with pkgs; [
    distrobox
  ];

  # Virtualbox
  virtualisation.virtualbox.host = 
  {
    enable = true;
    enableKvm = true;
    addNetworkInterface = false;
  };
  
  users.extraGroups.vboxusers.members = [ "bruno" ];
  
  # Docker
  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "bruno" ];

  # Libvirt
  # virtualisation.libvirtd = {
  #   enable = true;
  #   qemu = {
  #     package = pkgs.qemu_kvm;
  #     runAsRoot = true;
  #     swtpm.enable = true;
  #     ovmf = {
  #       enable = true;
  #       packages = [(pkgs.OVMF.override {
  #         secureBoot = true;
  #         tpmSupport = true;
  #       }).fd];
  #     };
  #   };
  # };
  # users.extraGroups.libvirtd.members = [ "bruno" ];

  # programs.virt-manager.enable = true;

}