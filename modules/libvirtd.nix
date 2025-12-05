{ pkgs, ... }:

{
  # Libvirt
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      vhostUserPackages = [ pkgs.virtiofsd ];
    };
  };

  # Enable nested virtualization
  # boot.extraModprobeConfig = "options kvm_intel nested=1";

  programs.virt-manager.enable = true;

}
