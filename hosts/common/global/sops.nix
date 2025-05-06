{ inputs, pkgs, ... }:

{

  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  environment.systemPackages = [
    pkgs.age
    pkgs.ssh-to-age
    pkgs.sops
  ];


  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}

