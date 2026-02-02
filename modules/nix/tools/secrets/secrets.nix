{
  inputs,
  self,
  ...
}:
{
  flake.modules.nixos.secrets =
    { pkgs, ... }:
    {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];
      environment.systemPackages = [ 
        pkgs.age
        pkgs.ssh-to-age
        pkgs.sops
      ];

      sops = {
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
    };

  flake.modules.homeManager.secrets =
    { pkgs, ... }:
    {
      imports = [
        inputs.sops-nix.homeManagerModules.sops
      ];
    };

}