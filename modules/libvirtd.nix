{ pkgs, ... }:

{
  # Libvirt
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [(pkgs.OVMF.override {
          secureBoot = true;
          tpmSupport = true;
        }).fd];
      };
      vhostUserPackages = [ pkgs.virtiofsd ];
    };
  };

  # Enable nested virtualization
  boot.extraModprobeConfig = "options kvm_intel nested=1";

  programs.virt-manager.enable = true;

}