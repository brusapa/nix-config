{ inputs, lib, config, ... }:

let
  inherit (inputs) nixpkgs home-manager;

  mkHomeManagerUsers = { hostname, users }:
    builtins.listToAttrs (builtins.map (user:
      let
        hostPath = ../home + "/${user}/hosts/${hostname}.nix";
        fallbackPath = ../home + "/${user}/generic-cli.nix";
        resolvedPath =
          if builtins.pathExists hostPath
          then hostPath
          else fallbackPath;
      in {
        name = user;
        value = {
          imports = [ resolvedPath ];
        };
      }
    ) users);

  mkSystem = hostName: hostCfg:
    nixpkgs.lib.nixosSystem {
      system = hostCfg.system;
      specialArgs = { inherit inputs; };

      modules = [
        ../hosts/${hostName}

        home-manager.nixosModules.home-manager
        ({ ... }: {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = { inherit inputs; };

            users = mkHomeManagerUsers {
              hostname = hostName;
              users = hostCfg.users;
            };
          };
        })
      ];
    };
in
{
  flake.nixosConfigurations =
    lib.mapAttrs mkSystem config.hosts;
}