{ inputs, den, ... }:
{
  den.aspects.bruno.desktop = {
    includes = [
      den.aspects.flatpak
    ];

    homeManager = {
      imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];

      services.flatpak = {
        enable = true;
        packages = [
          "com.bambulab.BambuStudio"
        ];
      };
    };
  };
}