{ hostname, users }:
{ inputs, ... }:

let 
  userModules = builtins.listToAttrs (builtins.map (user:
    let
      hostPath = ../home + "/${user}/hosts/${hostname}.nix";
      fallbackPath = ../home + "/${user}/generic-cli.nix";
      resolvedPath = if builtins.pathExists hostPath then hostPath else fallbackPath;
    in {
      name = user;
      value = {
        imports = [ resolvedPath ];
      };
    }
  ) users);
in 
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  # Home Manager global configuration
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";

  home-manager.users = userModules;
}