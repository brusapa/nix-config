{ inputs, ... }:
{
  flake-file.inputs.comin = {
    url = "github:nlewo/comin";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      treefmt-nix.follows = "treefmt-nix";
    };
  };

  # GitOps: the host deploys its own configuration from the `deploy` branch,
  # which CI only advances once every host has built and been cached.
  den.aspects.comin.includes = [
    (
      { host, ... }:
      let
        isWorkstation = host.role == "workstation";
      in
      {
        nixos =
          { config, pkgs, ... }:
          {
            imports = [ inputs.comin.nixosModules.comin ];

            services.comin = {
              enable = true;
              package = inputs.comin.packages.${pkgs.stdenv.hostPlatform.system}.comin;
              remotes = [
                {
                  name = "origin";
                  url = "https://github.com/brusapa/nix-config.git";
                  branches = {
                    # Workstations apply changes on the next boot instead of
                    # switching under the running session
                    main = {
                      name = "deploy";
                      operation = if isWorkstation then "boot" else "switch";
                    };
                    # comin always deploys a testing branch too. Keep it under
                    # `deploy*` so the same GitHub ruleset protects it.
                    testing.name = "deploy-testing-${config.services.comin.hostname}";
                  };
                }
              ];
              # Notify the desktop session when a new configuration is ready
              desktop.enable = isWorkstation;
            };
          };
      }
    )
  ];
}
