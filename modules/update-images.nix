{
  # `nix run .#update-images` bumps the annotated container image versions
  # (see scripts/update-images.sh). The flake-update workflow runs it weekly.
  perSystem =
    { pkgs, ... }:
    {
      packages.update-images = pkgs.writeShellApplication {
        name = "update-images";
        runtimeInputs = with pkgs; [
          coreutils
          crane
          gawk
          gnugrep
          gnused
        ];
        text = builtins.readFile ../scripts/update-images.sh;
      };
    };
}
