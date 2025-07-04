{
  inputs,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    devenv
  ];

  programs.direnv.enable = true;

  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];
}
